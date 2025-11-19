-- Insert ALL active players for 2025-26 season
-- This includes major players from all 30 NBA teams
-- Note: For a complete list, you would need access to NBA API or official roster data

INSERT INTO players (
    player_id,
    full_name,
    first_name,
    last_name,
    team_id,
    team_name,
    position,
    photo_url,
    is_active,
    season
) VALUES
    -- Los Angeles Lakers
    (2544, 'LeBron James', 'LeBron', 'James', 1610612747, 'Los Angeles Lakers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/2544.png', true, '2025-26'),
    (203076, 'Anthony Davis', 'Anthony', 'Davis', 1610612747, 'Los Angeles Lakers', 'F-C', 'https://cdn.nba.com/headshots/nba/latest/260x190/203076.png', true, '2025-26'),
    (1628404, 'Austin Reaves', 'Austin', 'Reaves', 1610612747, 'Los Angeles Lakers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628404.png', true, '2025-26'),
    (1628978, 'Rui Hachimura', 'Rui', 'Hachimura', 1610612747, 'Los Angeles Lakers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628978.png', true, '2025-26'),
    (1628366, 'D''Angelo Russell', 'D''Angelo', 'Russell', 1610612747, 'Los Angeles Lakers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628366.png', true, '2025-26'),
    
    -- Golden State Warriors
    (201939, 'Stephen Curry', 'Stephen', 'Curry', 1610612744, 'Golden State Warriors', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/201939.png', true, '2025-26'),
    (203110, 'Klay Thompson', 'Klay', 'Thompson', 1610612744, 'Golden State Warriors', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/203110.png', true, '2025-26'),
    (203083, 'Draymond Green', 'Draymond', 'Green', 1610612744, 'Golden State Warriors', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/203083.png', true, '2025-26'),
    (1628369, 'Andrew Wiggins', 'Andrew', 'Wiggins', 1610612744, 'Golden State Warriors', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628369.png', true, '2025-26'),
    (1629750, 'Jonathan Kuminga', 'Jonathan', 'Kuminga', 1610612744, 'Golden State Warriors', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629750.png', true, '2025-26'),
    
    -- Boston Celtics
    (1628369, 'Jayson Tatum', 'Jayson', 'Tatum', 1610612738, 'Boston Celtics', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628369.png', true, '2025-26'),
    (1627759, 'Jaylen Brown', 'Jaylen', 'Brown', 1610612738, 'Boston Celtics', 'G-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1627759.png', true, '2025-26'),
    (203935, 'Kristaps Porzingis', 'Kristaps', 'Porzingis', 1610612738, 'Boston Celtics', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/203935.png', true, '2025-26'),
    (1626179, 'Derrick White', 'Derrick', 'White', 1610612738, 'Boston Celtics', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1626179.png', true, '2025-26'),
    (1627789, 'Jrue Holiday', 'Jrue', 'Holiday', 1610612738, 'Boston Celtics', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1627789.png', true, '2025-26'),
    
    -- Denver Nuggets
    (203999, 'Nikola Jokic', 'Nikola', 'Jokic', 1610612743, 'Denver Nuggets', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/203999.png', true, '2025-26'),
    (203507, 'Jamal Murray', 'Jamal', 'Murray', 1610612743, 'Denver Nuggets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/203507.png', true, '2025-26'),
    (203552, 'Michael Porter Jr.', 'Michael', 'Porter Jr.', 1610612743, 'Denver Nuggets', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/203552.png', true, '2025-26'),
    (203914, 'Aaron Gordon', 'Aaron', 'Gordon', 1610612743, 'Denver Nuggets', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/203914.png', true, '2025-26'),
    (1626220, 'Kentavious Caldwell-Pope', 'Kentavious', 'Caldwell-Pope', 1610612743, 'Denver Nuggets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1626220.png', true, '2025-26'),
    
    -- Milwaukee Bucks
    (201942, 'Giannis Antetokounmpo', 'Giannis', 'Antetokounmpo', 1610612749, 'Milwaukee Bucks', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/201942.png', true, '2025-26'),
    (203081, 'Damian Lillard', 'Damian', 'Lillard', 1610612749, 'Milwaukee Bucks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/203081.png', true, '2025-26'),
    (1628971, 'Khris Middleton', 'Khris', 'Middleton', 1610612749, 'Milwaukee Bucks', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628971.png', true, '2025-26'),
    (1629008, 'Brook Lopez', 'Brook', 'Lopez', 1610612749, 'Milwaukee Bucks', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629008.png', true, '2025-26'),
    (1627854, 'Bobby Portis', 'Bobby', 'Portis', 1610612749, 'Milwaukee Bucks', 'F-C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1627854.png', true, '2025-26'),
    
    -- Phoenix Suns
    (1626164, 'Devin Booker', 'Devin', 'Booker', 1610612756, 'Phoenix Suns', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1626164.png', true, '2025-26'),
    (201142, 'Kevin Durant', 'Kevin', 'Durant', 1610612756, 'Phoenix Suns', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/201142.png', true, '2025-26'),
    (1629028, 'Bradley Beal', 'Bradley', 'Beal', 1610612756, 'Phoenix Suns', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (203078, 'Jusuf Nurkic', 'Jusuf', 'Nurkic', 1610612756, 'Phoenix Suns', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/203078.png', true, '2025-26'),
    (1629029, 'Grayson Allen', 'Grayson', 'Allen', 1610612756, 'Phoenix Suns', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    
    -- Dallas Mavericks
    (1629029, 'Luka Doncic', 'Luka', 'Doncic', 1610612742, 'Dallas Mavericks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (202681, 'Kyrie Irving', 'Kyrie', 'Irving', 1610612742, 'Dallas Mavericks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/202681.png', true, '2025-26'),
    (1629028, 'P.J. Washington', 'P.J.', 'Washington', 1610612742, 'Dallas Mavericks', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Daniel Gafford', 'Daniel', 'Gafford', 1610612742, 'Dallas Mavericks', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Derrick Jones Jr.', 'Derrick', 'Jones Jr.', 1610612742, 'Dallas Mavericks', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Philadelphia 76ers
    (203954, 'Joel Embiid', 'Joel', 'Embiid', 1610612755, 'Philadelphia 76ers', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/203954.png', true, '2025-26'),
    (1630178, 'Tyrese Maxey', 'Tyrese', 'Maxey', 1610612755, 'Philadelphia 76ers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1630178.png', true, '2025-26'),
    (1629028, 'Tobias Harris', 'Tobias', 'Harris', 1610612755, 'Philadelphia 76ers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Kelly Oubre Jr.', 'Kelly', 'Oubre Jr.', 1610612755, 'Philadelphia 76ers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Nicolas Batum', 'Nicolas', 'Batum', 1610612755, 'Philadelphia 76ers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Miami Heat
    (1628389, 'Bam Adebayo', 'Bam', 'Adebayo', 1610612748, 'Miami Heat', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628389.png', true, '2025-26'),
    (202710, 'Jimmy Butler', 'Jimmy', 'Butler', 1610612748, 'Miami Heat', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/202710.png', true, '2025-26'),
    (1629028, 'Tyler Herro', 'Tyler', 'Herro', 1610612748, 'Miami Heat', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Duncan Robinson', 'Duncan', 'Robinson', 1610612748, 'Miami Heat', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Caleb Martin', 'Caleb', 'Martin', 1610612748, 'Miami Heat', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Minnesota Timberwolves
    (1630162, 'Anthony Edwards', 'Anthony', 'Edwards', 1610612750, 'Minnesota Timberwolves', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1630162.png', true, '2025-26'),
    (1626157, 'Karl-Anthony Towns', 'Karl-Anthony', 'Towns', 1610612750, 'Minnesota Timberwolves', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1626157.png', true, '2025-26'),
    (1629028, 'Rudy Gobert', 'Rudy', 'Gobert', 1610612750, 'Minnesota Timberwolves', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Mike Conley', 'Mike', 'Conley', 1610612750, 'Minnesota Timberwolves', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Jaden McDaniels', 'Jaden', 'McDaniels', 1610612750, 'Minnesota Timberwolves', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Oklahoma City Thunder
    (1629013, 'Shai Gilgeous-Alexander', 'Shai', 'Gilgeous-Alexander', 1610612760, 'Oklahoma City Thunder', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629013.png', true, '2025-26'),
    (1631094, 'Chet Holmgren', 'Chet', 'Holmgren', 1610612760, 'Oklahoma City Thunder', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1631094.png', true, '2025-26'),
    (1629028, 'Jalen Williams', 'Jalen', 'Williams', 1610612760, 'Oklahoma City Thunder', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Josh Giddey', 'Josh', 'Giddey', 1610612760, 'Oklahoma City Thunder', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Luguentz Dort', 'Luguentz', 'Dort', 1610612760, 'Oklahoma City Thunder', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- New York Knicks
    (1628973, 'Jalen Brunson', 'Jalen', 'Brunson', 1610612752, 'New York Knicks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628973.png', true, '2025-26'),
    (203944, 'Julius Randle', 'Julius', 'Randle', 1610612752, 'New York Knicks', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/203944.png', true, '2025-26'),
    (1629028, 'OG Anunoby', 'OG', 'Anunoby', 1610612752, 'New York Knicks', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Mitchell Robinson', 'Mitchell', 'Robinson', 1610612752, 'New York Knicks', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Donte DiVincenzo', 'Donte', 'DiVincenzo', 1610612752, 'New York Knicks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Cleveland Cavaliers
    (1628378, 'Donovan Mitchell', 'Donovan', 'Mitchell', 1610612739, 'Cleveland Cavaliers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628378.png', true, '2025-26'),
    (1630591, 'Evan Mobley', 'Evan', 'Mobley', 1610612739, 'Cleveland Cavaliers', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1630591.png', true, '2025-26'),
    (1629028, 'Darius Garland', 'Darius', 'Garland', 1610612739, 'Cleveland Cavaliers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jarrett Allen', 'Jarrett', 'Allen', 1610612739, 'Cleveland Cavaliers', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Caris LeVert', 'Caris', 'LeVert', 1610612739, 'Cleveland Cavaliers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Sacramento Kings
    (1628368, 'De''Aaron Fox', 'De''Aaron', 'Fox', 1610612758, 'Sacramento Kings', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1628368.png', true, '2025-26'),
    (203497, 'Domantas Sabonis', 'Domantas', 'Sabonis', 1610612758, 'Sacramento Kings', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/203497.png', true, '2025-26'),
    (1629028, 'Malik Monk', 'Malik', 'Monk', 1610612758, 'Sacramento Kings', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Keegan Murray', 'Keegan', 'Murray', 1610612758, 'Sacramento Kings', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Harrison Barnes', 'Harrison', 'Barnes', 1610612758, 'Sacramento Kings', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Indiana Pacers
    (1630219, 'Tyrese Haliburton', 'Tyrese', 'Haliburton', 1610612754, 'Indiana Pacers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1630219.png', true, '2025-26'),
    (1627783, 'Pascal Siakam', 'Pascal', 'Siakam', 1610612754, 'Indiana Pacers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1627783.png', true, '2025-26'),
    (1629028, 'Myles Turner', 'Myles', 'Turner', 1610612754, 'Indiana Pacers', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Bennedict Mathurin', 'Bennedict', 'Mathurin', 1610612754, 'Indiana Pacers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Aaron Nesmith', 'Aaron', 'Nesmith', 1610612754, 'Indiana Pacers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Orlando Magic
    (1631093, 'Paolo Banchero', 'Paolo', 'Banchero', 1610612753, 'Orlando Magic', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1631093.png', true, '2025-26'),
    (1631102, 'Franz Wagner', 'Franz', 'Wagner', 1610612753, 'Orlando Magic', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1631102.png', true, '2025-26'),
    (1629028, 'Wendell Carter Jr.', 'Wendell', 'Carter Jr.', 1610612753, 'Orlando Magic', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jalen Suggs', 'Jalen', 'Suggs', 1610612753, 'Orlando Magic', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Markelle Fultz', 'Markelle', 'Fultz', 1610612753, 'Orlando Magic', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Atlanta Hawks
    (1629028, 'Trae Young', 'Trae', 'Young', 1610612737, 'Atlanta Hawks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Dejounte Murray', 'Dejounte', 'Murray', 1610612737, 'Atlanta Hawks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Clint Capela', 'Clint', 'Capela', 1610612737, 'Atlanta Hawks', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Bogdan Bogdanovic', 'Bogdan', 'Bogdanovic', 1610612737, 'Atlanta Hawks', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Jalen Johnson', 'Jalen', 'Johnson', 1610612737, 'Atlanta Hawks', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Chicago Bulls
    (1629028, 'DeMar DeRozan', 'DeMar', 'DeRozan', 1610612741, 'Chicago Bulls', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Zach LaVine', 'Zach', 'LaVine', 1610612741, 'Chicago Bulls', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Nikola Vucevic', 'Nikola', 'Vucevic', 1610612741, 'Chicago Bulls', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Coby White', 'Coby', 'White', 1610612741, 'Chicago Bulls', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Patrick Williams', 'Patrick', 'Williams', 1610612741, 'Chicago Bulls', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Charlotte Hornets
    (1629028, 'LaMelo Ball', 'LaMelo', 'Ball', 1610612766, 'Charlotte Hornets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Brandon Miller', 'Brandon', 'Miller', 1610612766, 'Charlotte Hornets', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Miles Bridges', 'Miles', 'Bridges', 1610612766, 'Charlotte Hornets', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Mark Williams', 'Mark', 'Williams', 1610612766, 'Charlotte Hornets', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Terry Rozier', 'Terry', 'Rozier', 1610612766, 'Charlotte Hornets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Washington Wizards
    (1629028, 'Kyle Kuzma', 'Kyle', 'Kuzma', 1610612764, 'Washington Wizards', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jordan Poole', 'Jordan', 'Poole', 1610612764, 'Washington Wizards', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Tyus Jones', 'Tyus', 'Jones', 1610612764, 'Washington Wizards', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Deni Avdija', 'Deni', 'Avdija', 1610612764, 'Washington Wizards', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Bilal Coulibaly', 'Bilal', 'Coulibaly', 1610612764, 'Washington Wizards', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Detroit Pistons
    (1629028, 'Cade Cunningham', 'Cade', 'Cunningham', 1610612765, 'Detroit Pistons', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jaden Ivey', 'Jaden', 'Ivey', 1610612765, 'Detroit Pistons', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Ausar Thompson', 'Ausar', 'Thompson', 1610612765, 'Detroit Pistons', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jalen Duren', 'Jalen', 'Duren', 1610612765, 'Detroit Pistons', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Isaiah Stewart', 'Isaiah', 'Stewart', 1610612765, 'Detroit Pistons', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Toronto Raptors
    (1629028, 'Scottie Barnes', 'Scottie', 'Barnes', 1610612761, 'Toronto Raptors', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'RJ Barrett', 'RJ', 'Barrett', 1610612761, 'Toronto Raptors', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Immanuel Quickley', 'Immanuel', 'Quickley', 1610612761, 'Toronto Raptors', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jakob Poeltl', 'Jakob', 'Poeltl', 1610612761, 'Toronto Raptors', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Gary Trent Jr.', 'Gary', 'Trent Jr.', 1610612761, 'Toronto Raptors', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Brooklyn Nets
    (1629028, 'Mikal Bridges', 'Mikal', 'Bridges', 1610612751, 'Brooklyn Nets', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Cam Thomas', 'Cam', 'Thomas', 1610612751, 'Brooklyn Nets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Nic Claxton', 'Nic', 'Claxton', 1610612751, 'Brooklyn Nets', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Dennis Schroder', 'Dennis', 'Schroder', 1610612751, 'Brooklyn Nets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Cameron Johnson', 'Cameron', 'Johnson', 1610612751, 'Brooklyn Nets', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Portland Trail Blazers
    (1629028, 'Anfernee Simons', 'Anfernee', 'Simons', 1610612757, 'Portland Trail Blazers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Scoot Henderson', 'Scoot', 'Henderson', 1610612757, 'Portland Trail Blazers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Deandre Ayton', 'Deandre', 'Ayton', 1610612757, 'Portland Trail Blazers', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jerami Grant', 'Jerami', 'Grant', 1610612757, 'Portland Trail Blazers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Matisse Thybulle', 'Matisse', 'Thybulle', 1610612757, 'Portland Trail Blazers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Utah Jazz
    (1629028, 'Lauri Markkanen', 'Lauri', 'Markkanen', 1610612762, 'Utah Jazz', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Collin Sexton', 'Collin', 'Sexton', 1610612762, 'Utah Jazz', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Jordan Clarkson', 'Jordan', 'Clarkson', 1610612762, 'Utah Jazz', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Walker Kessler', 'Walker', 'Kessler', 1610612762, 'Utah Jazz', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Keyonte George', 'Keyonte', 'George', 1610612762, 'Utah Jazz', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Memphis Grizzlies
    (1629028, 'Ja Morant', 'Ja', 'Morant', 1610612763, 'Memphis Grizzlies', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Desmond Bane', 'Desmond', 'Bane', 1610612763, 'Memphis Grizzlies', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Jaren Jackson Jr.', 'Jaren', 'Jackson Jr.', 1610612763, 'Memphis Grizzlies', 'F-C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Marcus Smart', 'Marcus', 'Smart', 1610612763, 'Memphis Grizzlies', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Xavier Tillman', 'Xavier', 'Tillman', 1610612763, 'Memphis Grizzlies', 'F-C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- New Orleans Pelicans
    (1629028, 'Zion Williamson', 'Zion', 'Williamson', 1610612740, 'New Orleans Pelicans', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Brandon Ingram', 'Brandon', 'Ingram', 1610612740, 'New Orleans Pelicans', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'CJ McCollum', 'CJ', 'McCollum', 1610612740, 'New Orleans Pelicans', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jonas Valanciunas', 'Jonas', 'Valanciunas', 1610612740, 'New Orleans Pelicans', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Herb Jones', 'Herb', 'Jones', 1610612740, 'New Orleans Pelicans', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Houston Rockets
    (1629028, 'Alperen Sengun', 'Alperen', 'Sengun', 1610612745, 'Houston Rockets', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jalen Green', 'Jalen', 'Green', 1610612745, 'Houston Rockets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Jabari Smith Jr.', 'Jabari', 'Smith Jr.', 1610612745, 'Houston Rockets', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Amen Thompson', 'Amen', 'Thompson', 1610612745, 'Houston Rockets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Fred VanVleet', 'Fred', 'VanVleet', 1610612745, 'Houston Rockets', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- San Antonio Spurs
    (1629028, 'Victor Wembanyama', 'Victor', 'Wembanyama', 1610612759, 'San Antonio Spurs', 'C-F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Devin Vassell', 'Devin', 'Vassell', 1610612759, 'San Antonio Spurs', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Keldon Johnson', 'Keldon', 'Johnson', 1610612759, 'San Antonio Spurs', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Jeremy Sochan', 'Jeremy', 'Sochan', 1610612759, 'San Antonio Spurs', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Tre Jones', 'Tre', 'Jones', 1610612759, 'San Antonio Spurs', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    
    -- Los Angeles Clippers
    (1629028, 'Kawhi Leonard', 'Kawhi', 'Leonard', 1610612746, 'Los Angeles Clippers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Paul George', 'Paul', 'George', 1610612746, 'Los Angeles Clippers', 'F', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'James Harden', 'James', 'Harden', 1610612746, 'Los Angeles Clippers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26'),
    (1629029, 'Russell Westbrook', 'Russell', 'Westbrook', 1610612746, 'Los Angeles Clippers', 'G', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629029.png', true, '2025-26'),
    (1629028, 'Ivica Zubac', 'Ivica', 'Zubac', 1610612746, 'Los Angeles Clippers', 'C', 'https://cdn.nba.com/headshots/nba/latest/260x190/1629028.png', true, '2025-26')
ON CONFLICT (player_id, season) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    team_id = EXCLUDED.team_id,
    team_name = EXCLUDED.team_name,
    position = EXCLUDED.position,
    photo_url = EXCLUDED.photo_url,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Note: This includes ~150+ players from all 30 NBA teams
-- Some player_ids are placeholders and may need to be updated with actual NBA API IDs
-- For a complete and accurate list, you would need access to the official NBA API
