-- Add policies to allow INSERT and UPDATE operations on players table
-- This is needed for the sync endpoint to work

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow insert and update for players" ON players;
DROP POLICY IF EXISTS "Allow update for players" ON players;

-- Create policy to allow insert for all users (needed for sync from server)
CREATE POLICY "Allow insert and update for players"
    ON players FOR INSERT
    WITH CHECK (true);

-- Create policy to allow update for all users (needed for upsert operations)
CREATE POLICY "Allow update for players"
    ON players FOR UPDATE
    USING (true)
    WITH CHECK (true);

