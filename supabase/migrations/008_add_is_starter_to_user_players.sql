-- Add is_starter field to user_players table
-- This indicates if the player is a starter (titular) or bench (suplent) for the user

ALTER TABLE user_players 
ADD COLUMN IF NOT EXISTS is_starter BOOLEAN DEFAULT false;

-- Drop and recreate get_user_active_players function to include is_starter field
DROP FUNCTION IF EXISTS get_user_active_players(UUID);

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

-- Create index for faster queries on starters
CREATE INDEX IF NOT EXISTS idx_user_players_is_starter ON user_players(user_id, is_starter) WHERE is_starter = true;

-- Add comment
COMMENT ON COLUMN user_players.is_starter IS 'Indicates if the player is a starter (titular) or bench (suplent) for the user';

-- Optional: Create a function to ensure max 5 starters per user
-- This can be enforced at application level or via trigger
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

