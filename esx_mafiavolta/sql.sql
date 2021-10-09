INSERT INTO `addon_account` (name, label, shared) VALUES 
('society_mafia','Mafia',1);

INSERT INTO `datastore` (name, label, shared) VALUES 
('society_mafia','Mafia',1);

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
('society_mafia', 'Mafia', 1);

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
('mafia', 'Mafia', 1);

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('mafia', 0, 'recrut', 'Recruit', 1000, '{}', '{}'),
('mafia', 1, 'member', 'Member', 1500, '{}', '{}'),
('mafia', 2, 'capo', 'Experienced', 1800, '{}', '{}'),
('mafia', 3, 'consigliere', 'Counselor', 2100, '{}', '{}'),
('mafia', 4, 'boss', 'Boss', 2700, '{}', '{}');
