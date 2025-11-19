-- Create players table
CREATE TABLE IF NOT EXISTS players (
    id BIGSERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL,
    full_name TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    team_id INTEGER,
    team_name TEXT,
    position TEXT,
    is_active BOOLEAN DEFAULT true,
    season TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT players_player_id_season_unique UNIQUE(player_id, season)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_players_season ON players(season);
CREATE INDEX IF NOT EXISTS idx_players_team_id ON players(team_id);
CREATE INDEX IF NOT EXISTS idx_players_is_active ON players(is_active);
CREATE INDEX IF NOT EXISTS idx_players_full_name ON players(full_name);

-- Enable Row Level Security (RLS)
ALTER TABLE players ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all users to read players
CREATE POLICY "Allow public read access to players"
    ON players FOR SELECT
    USING (true);

-- Create policy to allow insert/update for authenticated users or service role
-- Per a la sincronització des del servidor, necessitem permetre INSERT i UPDATE
CREATE POLICY "Allow insert and update for players"
    ON players FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow update for players"
    ON players FOR UPDATE
    USING (true)
    WITH CHECK (true);

