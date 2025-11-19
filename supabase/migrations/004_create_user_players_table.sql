-- Create user_players table to track which players each user owns
CREATE TABLE IF NOT EXISTS user_players (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    player_id BIGINT NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    purchase_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    sale_date TIMESTAMP WITH TIME ZONE,
    total_points DECIMAL(10, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    -- Note: We allow multiple entries for the same user+player combination
    -- because a user can buy the same player multiple times (after selling)
    -- The is_active flag helps identify current ownership
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

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_players_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_user_players_updated_at
    BEFORE UPDATE ON user_players
    FOR EACH ROW
    EXECUTE FUNCTION update_user_players_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE user_players ENABLE ROW LEVEL SECURITY;

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

