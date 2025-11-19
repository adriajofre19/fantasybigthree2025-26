-- ============================================================================
-- COMPLETE DATABASE SETUP - ALL MIGRATIONS IN ONE FILE
-- ============================================================================
-- Executa aquest fitxer per configurar tota la base de dades d'una vegada
-- Inclou totes les taules, polítiques, funcions i dades de mostra
-- ============================================================================

-- ============================================================================
-- 1. CREATE PLAYERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS players (
    id BIGSERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL,
    full_name TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    team_id INTEGER,
    team_name TEXT,
    position TEXT,
    photo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    season TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT players_player_id_season_unique UNIQUE(player_id, season)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_players_season ON players(season);
CREATE INDEX IF NOT EXISTS idx_players_team_id ON players(team_id);
CREATE INDEX IF NOT EXISTS idx_players_is_active ON players(is_active);
CREATE INDEX IF NOT EXISTS idx_players_full_name ON players(full_name);
CREATE INDEX IF NOT EXISTS idx_players_photo_url ON players(photo_url) WHERE photo_url IS NOT NULL;

-- Enable Row Level Security (RLS)
ALTER TABLE players ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow public read access to players" ON players;
DROP POLICY IF EXISTS "Allow insert and update for players" ON players;
DROP POLICY IF EXISTS "Allow update for players" ON players;

-- Create policy to allow all users to read players
CREATE POLICY "Allow public read access to players"
    ON players FOR SELECT
    USING (true);

-- Create policy to allow insert/update for authenticated users or service role
-- IMPORTANT: These policies allow INSERT/UPDATE for all users (needed for sync endpoint)
CREATE POLICY "Allow insert and update for players"
    ON players FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow update for players"
    ON players FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- 2. CREATE USER_PLAYERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_players (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    purchase_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    sale_date TIMESTAMP WITH TIME ZONE,
    total_points DECIMAL(10, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_starter BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Note: We allow multiple entries for the same user+player combination
    -- because a user can buy the same player multiple times (after selling)
    -- The is_active flag helps identify current ownership
    -- is_starter indicates if the player is a starter (titular) or bench (suplent)
    CONSTRAINT user_players_sale_after_purchase CHECK (
        sale_date IS NULL OR sale_date >= purchase_date
    )
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_user_players_user_id ON user_players(user_id);
CREATE INDEX IF NOT EXISTS idx_user_players_player_id ON user_players(player_id);
CREATE INDEX IF NOT EXISTS idx_user_players_is_active ON user_players(is_active);
CREATE INDEX IF NOT EXISTS idx_user_players_purchase_date ON user_players(purchase_date);
CREATE INDEX IF NOT EXISTS idx_user_players_sale_date ON user_players(sale_date);
CREATE INDEX IF NOT EXISTS idx_user_players_user_active ON user_players(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_user_players_is_starter ON user_players(user_id, is_starter) WHERE is_starter = true;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_players_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_user_players_updated_at ON user_players;
CREATE TRIGGER update_user_players_updated_at
    BEFORE UPDATE ON user_players
    FOR EACH ROW
    EXECUTE FUNCTION update_user_players_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE user_players ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read their own player purchases" ON user_players;
DROP POLICY IF EXISTS "Users can insert their own player purchases" ON user_players;
DROP POLICY IF EXISTS "Users can update their own player purchases" ON user_players;
DROP POLICY IF EXISTS "Users can delete their own player purchases" ON user_players;

-- Create policy to allow users to read their own player purchases
CREATE POLICY "Users can read their own player purchases"
    ON user_players FOR SELECT
    USING (auth.uid() = user_id);

-- Create policy to allow users to insert their own player purchases
CREATE POLICY "Users can insert their own player purchases"
    ON user_players FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to update their own player purchases
CREATE POLICY "Users can update their own player purchases"
    ON user_players FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Create policy to allow users to delete their own player purchases
CREATE POLICY "Users can delete their own player purchases"
    ON user_players FOR DELETE
    USING (auth.uid() = user_id);

-- Add comment to table
COMMENT ON TABLE user_players IS 'Tracks which players each user has purchased and sold, including dates and accumulated points';
COMMENT ON COLUMN user_players.is_starter IS 'Indicates if the player is a starter (titular) or bench (suplent) for the user';

-- Create function to ensure max 5 starters per user
CREATE OR REPLACE FUNCTION check_max_starters()
RETURNS TRIGGER AS $$
DECLARE
    starter_count INTEGER;
BEGIN
    -- Only check if this player is being set as a starter
    IF NEW.is_starter = true AND (OLD.is_starter IS NULL OR OLD.is_starter = false) THEN
        SELECT COUNT(*)
        INTO starter_count
        FROM user_players
        WHERE user_id = NEW.user_id
            AND is_starter = true
            AND is_active = true
            AND sale_date IS NULL
            AND id != NEW.id;
        
        -- Maximum 5 starters allowed
        IF starter_count >= 5 THEN
            RAISE EXCEPTION 'Maximum 5 starters allowed per user. Current starters: %', starter_count;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to enforce max 5 starters
DROP TRIGGER IF EXISTS enforce_max_starters ON user_players;
CREATE TRIGGER enforce_max_starters
    BEFORE INSERT OR UPDATE OF is_starter ON user_players
    FOR EACH ROW
    WHEN (NEW.is_starter = true)
    EXECUTE FUNCTION check_max_starters();

-- ============================================================================
-- 3. CREATE PLAYER_STATS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_stats (
    id BIGSERIAL PRIMARY KEY,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    game_date DATE NOT NULL,
    points DECIMAL(10, 2) DEFAULT 0,
    rebounds DECIMAL(10, 2) DEFAULT 0,
    assists DECIMAL(10, 2) DEFAULT 0,
    steals DECIMAL(10, 2) DEFAULT 0,
    blocks DECIMAL(10, 2) DEFAULT 0,
    turnovers DECIMAL(10, 2) DEFAULT 0,
    field_goals_made DECIMAL(10, 2) DEFAULT 0,
    field_goals_attempted DECIMAL(10, 2) DEFAULT 0,
    three_pointers_made DECIMAL(10, 2) DEFAULT 0,
    free_throws_made DECIMAL(10, 2) DEFAULT 0,
    minutes_played DECIMAL(10, 2) DEFAULT 0,
    -- Calculated fantasy points based on your scoring system
    fantasy_points DECIMAL(10, 2) DEFAULT 0,
    season TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT player_stats_player_date_season_unique UNIQUE(player_id, game_date, season)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_player_stats_player_id ON player_stats(player_id);
CREATE INDEX IF NOT EXISTS idx_player_stats_game_date ON player_stats(game_date);
CREATE INDEX IF NOT EXISTS idx_player_stats_season ON player_stats(season);
CREATE INDEX IF NOT EXISTS idx_player_stats_player_date ON player_stats(player_id, game_date);
CREATE INDEX IF NOT EXISTS idx_player_stats_date_range ON player_stats(game_date, season);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_player_stats_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_player_stats_updated_at ON player_stats;
CREATE TRIGGER update_player_stats_updated_at
    BEFORE UPDATE ON player_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_player_stats_updated_at();

-- Create function to calculate fantasy points
-- Adjust the formula based on your scoring system
CREATE OR REPLACE FUNCTION calculate_fantasy_points(
    p_points DECIMAL,
    p_rebounds DECIMAL,
    p_assists DECIMAL,
    p_steals DECIMAL,
    p_blocks DECIMAL,
    p_turnovers DECIMAL,
    p_field_goals_made DECIMAL,
    p_field_goals_attempted DECIMAL,
    p_three_pointers_made DECIMAL,
    p_free_throws_made DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    fantasy_pts DECIMAL;
BEGIN
    -- Example scoring system (adjust based on your rules):
    -- Points: 1 point per point scored
    -- Rebounds: 1.2 points per rebound
    -- Assists: 1.5 points per assist
    -- Steals: 3 points per steal
    -- Blocks: 3 points per block
    -- Turnovers: -1 point per turnover
    -- Field Goal % bonus/penalty
    -- Three pointers: 0.5 bonus per made
    -- Free throws: 0.5 bonus per made
    
    fantasy_pts := 
        COALESCE(p_points, 0) * 1.0 +
        COALESCE(p_rebounds, 0) * 1.2 +
        COALESCE(p_assists, 0) * 1.5 +
        COALESCE(p_steals, 0) * 3.0 +
        COALESCE(p_blocks, 0) * 3.0 +
        COALESCE(p_turnovers, 0) * -1.0 +
        COALESCE(p_three_pointers_made, 0) * 0.5 +
        COALESCE(p_free_throws_made, 0) * 0.5;
    
    -- Field goal percentage bonus/penalty (if attempted > 0)
    IF COALESCE(p_field_goals_attempted, 0) > 0 THEN
        DECLARE
            fg_percentage DECIMAL;
        BEGIN
            fg_percentage := (COALESCE(p_field_goals_made, 0) / p_field_goals_attempted) * 100;
            -- Bonus for FG% > 50%, penalty for < 40%
            IF fg_percentage >= 50 THEN
                fantasy_pts := fantasy_pts + 2.0;
            ELSIF fg_percentage < 40 AND p_field_goals_attempted >= 5 THEN
                fantasy_pts := fantasy_pts - 1.0;
            END IF;
        END;
    END IF;
    
    RETURN ROUND(fantasy_pts, 2);
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically calculate fantasy points when stats are inserted/updated
CREATE OR REPLACE FUNCTION update_fantasy_points()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fantasy_points := calculate_fantasy_points(
        NEW.points,
        NEW.rebounds,
        NEW.assists,
        NEW.steals,
        NEW.blocks,
        NEW.turnovers,
        NEW.field_goals_made,
        NEW.field_goals_attempted,
        NEW.three_pointers_made,
        NEW.free_throws_made
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS calculate_fantasy_points_trigger ON player_stats;
CREATE TRIGGER calculate_fantasy_points_trigger
    BEFORE INSERT OR UPDATE ON player_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_fantasy_points();

-- Enable Row Level Security (RLS)
ALTER TABLE player_stats ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow authenticated users to read player stats" ON player_stats;
DROP POLICY IF EXISTS "Allow service role to manage player stats" ON player_stats;

-- Create policy to allow all authenticated users to read player stats
CREATE POLICY "Allow authenticated users to read player stats"
    ON player_stats FOR SELECT
    USING (auth.role() = 'authenticated');

-- Create policy to allow service role to insert/update stats (for sync operations)
-- Note: Service role key bypasses RLS automatically, but we keep this for clarity
-- Also allow authenticated users to insert stats (for sync operations)
CREATE POLICY "Allow service role to manage player stats"
    ON player_stats FOR ALL
    USING (auth.role() = 'service_role' OR auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'service_role' OR auth.role() = 'authenticated');

-- Add comment to table
COMMENT ON TABLE player_stats IS 'Stores daily game statistics for each player, used to calculate fantasy points';

-- ============================================================================
-- 4. CREATE FUNCTIONS FOR USER_PLAYER POINTS CALCULATION
-- ============================================================================
-- Create function to calculate total points for a user_player relationship
CREATE OR REPLACE FUNCTION calculate_user_player_points(
    p_user_player_id BIGINT
) RETURNS DECIMAL AS $$
DECLARE
    v_purchase_date TIMESTAMP WITH TIME ZONE;
    v_sale_date TIMESTAMP WITH TIME ZONE;
    v_player_id BIGINT;
    v_total_points DECIMAL := 0;
BEGIN
    -- Get purchase and sale dates, and player_id
    SELECT purchase_date, sale_date, player_id
    INTO v_purchase_date, v_sale_date, v_player_id
    FROM user_players
    WHERE id = p_user_player_id;
    
    IF v_purchase_date IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Calculate points from player_stats between purchase_date and sale_date (or current date)
    SELECT COALESCE(SUM(fantasy_points), 0)
    INTO v_total_points
    FROM player_stats
    WHERE player_id = v_player_id
        AND game_date >= DATE(v_purchase_date)
        AND (v_sale_date IS NULL OR game_date <= DATE(v_sale_date));
    
    RETURN ROUND(v_total_points, 2);
END;
$$ LANGUAGE plpgsql;

-- Create function to update total_points for a user_player
CREATE OR REPLACE FUNCTION update_user_player_total_points()
RETURNS TRIGGER AS $$
DECLARE
    v_total_points DECIMAL;
    v_purchase_date TIMESTAMP WITH TIME ZONE;
    v_sale_date TIMESTAMP WITH TIME ZONE;
    v_player_id BIGINT;
BEGIN
    -- For INSERT, use NEW values directly
    -- For UPDATE, use NEW values
    v_purchase_date := NEW.purchase_date;
    v_sale_date := NEW.sale_date;
    v_player_id := NEW.player_id;
    
    -- Calculate points from player_stats between purchase_date and sale_date (or current date)
    SELECT COALESCE(SUM(fantasy_points), 0)
    INTO v_total_points
    FROM player_stats
    WHERE player_id = v_player_id
        AND game_date >= DATE(v_purchase_date)
        AND (v_sale_date IS NULL OR game_date <= DATE(v_sale_date));
    
    NEW.total_points := ROUND(v_total_points, 2);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_user_player_total_points_trigger ON user_players;

-- Create trigger to automatically update total_points when purchase_date or sale_date changes
CREATE TRIGGER update_user_player_total_points_trigger
    BEFORE INSERT OR UPDATE OF purchase_date, sale_date, player_id ON user_players
    FOR EACH ROW
    EXECUTE FUNCTION update_user_player_total_points();

-- Create function to recalculate all user_player points (useful for batch updates)
CREATE OR REPLACE FUNCTION recalculate_all_user_player_points()
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER := 0;
    v_user_player RECORD;
BEGIN
    FOR v_user_player IN SELECT id FROM user_players LOOP
        UPDATE user_players
        SET total_points = calculate_user_player_points(v_user_player.id)
        WHERE id = v_user_player.id;
        v_count := v_count + 1;
    END LOOP;
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Drop existing function if it exists (to allow changing return type)
DROP FUNCTION IF EXISTS get_user_active_players(UUID);

-- Create function to get user's active players with current total points
CREATE OR REPLACE FUNCTION get_user_active_players(p_user_id UUID)
RETURNS TABLE (
    user_player_id BIGINT,
    player_id BIGINT,
    player_name TEXT,
    "position" TEXT,
    purchase_date TIMESTAMP WITH TIME ZONE,
    total_points DECIMAL,
    team_name TEXT,
    is_starter BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.id AS user_player_id,
        p.id AS player_id,
        p.full_name AS player_name,
        p.position,
        up.purchase_date,
        up.total_points,
        p.team_name,
        up.is_starter
    FROM user_players up
    INNER JOIN players p ON up.player_id = p.id
    WHERE up.user_id = p_user_id
        AND up.is_active = true
        AND up.sale_date IS NULL
    ORDER BY up.is_starter DESC, up.purchase_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Add comments to functions
COMMENT ON FUNCTION calculate_user_player_points(BIGINT) IS 'Calculates total fantasy points accumulated by a player for a specific user between purchase and sale dates';
COMMENT ON FUNCTION update_user_player_total_points() IS 'Trigger function to automatically update total_points when purchase_date or sale_date changes';
COMMENT ON FUNCTION recalculate_all_user_player_points() IS 'Recalculates total_points for all user_players (useful after syncing player stats)';
COMMENT ON FUNCTION get_user_active_players(UUID) IS 'Returns all active players owned by a user with their current total points';

-- ============================================================================
-- 5. CREATE USER_PROFILES TABLE (Balance/Money System)
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    balance DECIMAL(12, 2) DEFAULT 5000000.00 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_balance ON user_profiles(balance);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_user_profiles_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;

-- Create policy to allow users to read their own profile
CREATE POLICY "Users can read their own profile"
    ON user_profiles FOR SELECT
    USING (auth.uid() = id);

-- Create policy to allow users to insert their own profile
CREATE POLICY "Users can insert their own profile"
    ON user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Create policy to allow users to update their own profile
CREATE POLICY "Users can update their own profile"
    ON user_profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Create function to initialize user profile when a user is created
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (id, balance)
    VALUES (NEW.id, 5000000.00)
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_user_profile();

-- Create function to get user balance
CREATE OR REPLACE FUNCTION get_user_balance(p_user_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_balance DECIMAL;
BEGIN
    SELECT balance INTO v_balance
    FROM user_profiles
    WHERE id = p_user_id;
    
    RETURN COALESCE(v_balance, 5000000.00);
END;
$$ LANGUAGE plpgsql;

-- Add comments
COMMENT ON TABLE user_profiles IS 'Stores user profile information including balance/money';
COMMENT ON COLUMN user_profiles.balance IS 'User balance in currency (default: 5,000,000)';
COMMENT ON FUNCTION get_user_balance(UUID) IS 'Returns the current balance for a user';

-- ============================================================================
-- SETUP COMPLETE
-- ============================================================================
-- Totes les taules, polítiques, funcions i triggers han estat creades
-- Ara pots començar a usar l'aplicació!
-- 
-- IMPORTANT: Per sincronitzar jugadors, assegura't que tens configurat:
-- 1. SUPABASE_SERVICE_ROLE_KEY al teu fitxer .env (recomanat per bypassar RLS)
-- 2. O les polítiques RLS permeten INSERT/UPDATE per a usuaris autenticats
-- 
-- Les polítiques actuals permeten INSERT/UPDATE per a tots els usuaris a la taula players,
-- així que el sync hauria de funcionar amb la clau anònima també.
-- ============================================================================
