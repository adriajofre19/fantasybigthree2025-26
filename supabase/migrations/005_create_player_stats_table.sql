-- Create player_stats table to store daily/weekly statistics for each player
-- This allows us to calculate points accumulated during specific time periods
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

CREATE TRIGGER calculate_fantasy_points_trigger
    BEFORE INSERT OR UPDATE ON player_stats
    FOR EACH ROW
    EXECUTE FUNCTION update_fantasy_points();

-- Enable Row Level Security (RLS)
ALTER TABLE player_stats ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all authenticated users to read player stats
CREATE POLICY "Allow authenticated users to read player stats"
    ON player_stats FOR SELECT
    USING (auth.role() = 'authenticated');

-- Create policy to allow service role to insert/update stats (for sync operations)
-- Note: This requires service role key, regular users cannot insert stats directly
CREATE POLICY "Allow service role to manage player stats"
    ON player_stats FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Add comment to table
COMMENT ON TABLE player_stats IS 'Stores daily game statistics for each player, used to calculate fantasy points';

