-- Create function to calculate total points for a user_player relationship
-- This function calculates points accumulated between purchase_date and sale_date (or current date)
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

-- Add comment to functions
COMMENT ON FUNCTION calculate_user_player_points(BIGINT) IS 'Calculates total fantasy points accumulated by a player for a specific user between purchase and sale dates';
COMMENT ON FUNCTION update_user_player_total_points() IS 'Trigger function to automatically update total_points when purchase_date or sale_date changes';
COMMENT ON FUNCTION recalculate_all_user_player_points() IS 'Recalculates total_points for all user_players (useful after syncing player stats)';
COMMENT ON FUNCTION get_user_active_players(UUID) IS 'Returns all active players owned by a user with their current total points';

