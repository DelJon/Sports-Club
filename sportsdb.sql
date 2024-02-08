DROP VIEW IF EXISTS members_of_team;
DROP VIEW IF EXISTS teams_of_member;
DROP TABLE IF EXISTS TEAM_MEMBERS;
DROP TABLE IF EXISTS MATCHES;
DROP TABLE IF EXISTS PRACTICES;
DROP TABLE IF EXISTS MEMBERS;
DROP TABLE IF EXISTS FACILITIES;
DROP TABLE IF EXISTS TEAMS;
DROP TABLE IF EXISTS SPORTS;
DROP TABLE IF EXISTS LOGS;


CREATE TABLE SPORTS
(
	sport_id integer NOT NULL DEFAULT 100,
	sport_name varchar(20),
	sport_sex varchar(10),	--if NULL no restrictons
	sport_age integer,		--if NULL no restrictons
	CONSTRAINT "SPORTS_pkey" PRIMARY KEY (sport_id),
	CONSTRAINT "SPORTS_sex" CHECK (sport_sex IN('Male','Female'))
);

CREATE TABLE FACILITIES
(
	facility_id integer NOT NULL DEFAULT 200,
	facility_size integer, --in square meters
	facility_desc varchar(30),
	facility_location varchar(10),
	facility_active bit NOT NULL DEFAULT '1', --0 if inactive 1 if active
	CONSTRAINT "FACILITIES_location" CHECK (facility_location IN('Indoors','Outdoors')),
	CONSTRAINT "FACILITIES_pkey" PRIMARY KEY (facility_id)
);

CREATE TABLE TEAMS
(
	team_id integer NOT NULL DEFAULT 300,
	sport_id integer,
	team_name varchar(20),
	team_active bit NOT NULL DEFAULT '1', --0 if inactive 1 if active
	CONSTRAINT "TEAMS_pkey" PRIMARY KEY (team_id),
	CONSTRAINT "TEAMS_sport_id" FOREIGN KEY (sport_id) REFERENCES SPORTS
);

CREATE TABLE MEMBERS
(
	member_id integer NOT NULL DEFAULT 200000,
	member_first_name varchar(20),
	member_last_name varchar(20),
	member_birth date,
	member_joined date,
	member_active bit NOT NULL DEFAULT '1', --0 if inactive 1 if active
	member_sex varchar(10),
	CONSTRAINT "MEMBERS_pkey" PRIMARY KEY (member_id),
	CONSTRAINT "MEMBERS_sex" CHECK (member_sex IN('Male','Female'))
);

CREATE TABLE TEAM_MEMBERS
(
	member_id integer NOT NULL,
	team_id integer NOT NULL,
	team_joined date,
	team_role varchar(20),
	CONSTRAINT "TEAM_MEMBERS_member_id" FOREIGN KEY (member_id) REFERENCES MEMBERS,
	CONSTRAINT "TEAM_MEMBERS_team_id" FOREIGN KEY (team_id) REFERENCES TEAMS,
	CONSTRAINT "TEAM_MEMBERS_pkey" PRIMARY KEY (team_id, member_id)
);
--VIEWS
CREATE OR REPLACE VIEW members_of_team AS 
SELECT members.member_id, members.member_first_name, members.member_last_name, team_members.team_joined, teams.team_id FROM members 
JOIN team_members ON members.member_id=team_members.member_id
JOIN teams ON teams.team_id=team_members.team_id;
--
CREATE OR REPLACE VIEW teams_of_member AS 
SELECT teams.team_name, teams.team_id, team_members.team_joined, members.member_id FROM teams 
JOIN team_members ON teams.team_id=team_members.team_id
JOIN members ON members.member_id=team_members.member_id;

CREATE TABLE PRACTICES
(
	team_id integer NOT NULL,
	practice_day varchar(10) NOT NULL,	--Monday to Sunday
	practice_time time NOT NULL,		--8:00 to 22:00 
	facility_id integer,
	CONSTRAINT "PRACTICES_day" CHECK (practice_day IN('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),
	CONSTRAINT "PRACTICES_pkey" PRIMARY KEY (team_id,practice_day,practice_time),
	CONSTRAINT "PRACTICES_team_id" FOREIGN KEY (team_id) REFERENCES TEAMS,
	CONSTRAINT "PRACTICES_facility_id" FOREIGN KEY (facility_id) REFERENCES FACILITIES
);

CREATE TABLE MATCHES
(
	team_id integer NOT NULL,
	match_date date NOT NULL,
	match_time time NOT NULL,
	match_opponent varchar(20),
	facility_id integer,		--if NULL then playing away
	match_placement integer DEFAULT NULL,	--if 1 then WIN NULL for upcoming games
	match_canceled bit DEFAULT '0',			--if 0 not cancelled if 1 CANCELLED
	CONSTRAINT "MATCHES_team_id" FOREIGN KEY (team_id) REFERENCES TEAMS,
	CONSTRAINT "MATCHES_facility_id" FOREIGN KEY (facility_id) REFERENCES FACILITIES,
	CONSTRAINT "MATCHES_pkey" PRIMARY KEY (team_id,match_date,match_time)
);
--Test sports
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (100, 'Football Men', 'Male',NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (101, 'Football Women', 'Female',NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (102, 'Football Teen', NULL,18);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (103, 'Basketball Men', 'Male',NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (104, 'Basketball Teen', NULL,18);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (105, 'Handball', NULL,NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (106, 'Handball Teen', NULL,18);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (107, 'Volleyball', NULL,NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (108, 'Athletics Men', 'Male',NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (109, 'Athletics Women', 'Female',NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (110, 'Athletics Teen', NULL,18);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (111, 'Swimming', NULL,NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (112, 'Water Polo', NULL,NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (113, 'Tennis', NULL,NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (114, 'Boxing Men', 'Male',NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (115, 'Boxing Women', 'Female',NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (116, 'Weightlifting', NULL,NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (117, 'Fencing', NULL,NULL);
INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (118, 'Football Kid', NULL,12);
--Test facilities
INSERT INTO FACILITIES (facility_id, facility_size, facility_desc, facility_location, facility_active) VALUES (200, 4800, 'Decomissioned Field',  'Outdoors','0');
INSERT INTO FACILITIES (facility_id, facility_size, facility_desc, facility_location) VALUES (201, 7000, 'Emilios Main Football Field',  'Outdoors');
INSERT INTO FACILITIES (facility_id, facility_size, facility_desc, facility_location) VALUES (202, 5000, 'Sindos Athletics Pitch',  'Outdoors');
INSERT INTO FACILITIES (facility_id, facility_size, facility_desc, facility_location) VALUES (203, 1500, 'Practice Pool',  'Indoors');
INSERT INTO FACILITIES (facility_id, facility_size, facility_desc, facility_location) VALUES (204, 3000, 'Sports Court',  'Indoors');
--Test teams
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (300, 100, 'Aetoi');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (301, 100, 'Football Amateurs');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (302, 101, 'Aetines');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (303, 102, 'Gerakia');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (304, 102, 'Gerakia 2');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (305, 118, 'Peristeria');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (306, 118, 'Peristeria 2');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (307, 103, 'Basket Stars');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (308, 104, 'Basket Boys');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (309, 105, 'Keravnos');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (310, 106, 'Astrapi');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (311, 107, 'Volley Stars');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (312, 107, 'Volley Amateurs');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (313, 108, 'Stivos for Men');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (314, 109, 'Stivos for Women');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (315, 110, 'Stivos for Teens');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (316, 111, 'Swimming Squad');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (317, 112, 'Polo Squad');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (318, 112, 'Polo Amateurs');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (319, 114, 'Boxing Boys');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (320, 115, 'Boxing Girls');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (321, 116, 'Weightlifting Squad');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (322, 117, 'Fencing Squad');
INSERT INTO TEAMS (team_id, sport_id, team_name) VALUES (323, 113, 'Tennis Stars');
INSERT INTO TEAMS (team_id, sport_id, team_name, team_active) VALUES (324, 113, 'Tennis Amateurs','0');
--Test members
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200000, 'George', 'Papas', '1990-06-15', '2020-1-5', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200001, 'John', 'Oliver', '1991-06-15', '2020-1-20', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200002, 'Mary', 'Anagnostou', '1995-06-15', '2020-1-22', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200003, 'Agatha', 'Marinou', '1995-06-15', '2020-1-26', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200004, 'Paul', 'Sidera', '1993-06-15', '2020-2-4', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200005, 'George', 'Anthopoulos', '1992-06-15', '2020-2-6', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200006, 'Anna', 'Nikolaou', '1988-06-15', '2020-2-25', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex,member_active) VALUES (200007, 'John', 'Psarras', '1997-06-15', '2020-3-1', 'Male','0');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200008, 'Robert', 'Psarras', '2005-06-15', '2020-3-2', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200009, 'Michael', 'Andrioti', '1998-06-15', '2020-3-11', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200010, 'Sarah', 'Kalousiou', '1987-06-15', '2020-3-15', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200011, 'Lisa', 'Kalousiou', '2002-06-15', '2020-4-1', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200012, 'Mark', 'Palioura', '2012-06-15', '2020-4-11', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200013, 'Anthony', 'Matira', '2013-06-15', '2020-4-24', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200014, 'Jessica', 'Smith', '2006-06-15', '2020-4-25', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200015, 'Charles', 'Blackburn', '2008-06-15', '2020-5-16', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200016, 'Mary', 'Devon', '2007-06-15', '2020-5-21', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200017, 'Steven', 'Queen', '1999-06-15', '2020-6-13', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200018, 'Matt', 'Vasiliou', '2000-06-15', '2020-6-25', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200019, 'John', 'Xatzi', '2014-06-15', '2020-7-14', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200020, 'Andrew', 'Xatzi', '2004-06-15', '2020-7-14', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex,member_active) VALUES (200021, 'Eric', 'Kano', '1998-06-15', '2020-8-16', 'Male','0');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200022, 'Amy', 'Emilou', '1998-06-15', '2020-8-20', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200023, 'Anne', 'Andrioti', '1990-06-15', '2020-9-19', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200024, 'George', 'Sanchez', '2011-06-15', '2020-9-19', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200025, 'Carol', 'Brown', '2016-06-15', '2020-9-20', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200026, 'Jeff', 'Green', '2014-06-15', '2020-9-24', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200027, 'John', 'Hernandez', '2015-06-15', '2020-10-10', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200028, 'George', 'Davis', '2007-06-15', '2020-12-15', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (200029, 'Mary', 'Freeman', '2008-06-15', '2020-12-19', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210000, 'Cynthia', 'Garcia', '2008-06-15', '2021-1-15', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210001, 'Sam', 'Taylor', '1996-06-15', '2021-1-25', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210002, 'Greg', 'Taylor', '1995-06-15', '2021-2-14', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210003, 'Alex', 'Miller', '2007-06-15', '2021-2-25', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210004, 'Ryan', 'Anderson', '2005-06-15', '2021-2-26', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210005, 'Paul', 'Thompson', '2007-06-15', '2021-3-4', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210006, 'Michael', 'Stuart', '2008-06-15', '2021-3-27', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210007, 'Steven', 'Jones', '2000-06-15', '2021-4-13', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210008, 'Alex', 'Garcia', '2001-06-15', '2021-4-23', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210009, 'George', 'Johnson', '2008-06-15', '2021-4-25', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210010, 'Ryan', 'Mariolou', '2011-06-15', '2021-5-8', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210011, 'Nicole', 'Petit', '1981-06-15', '2021-5-12', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210012, 'Sarah', 'Moore', '1993-06-15', '2021-6-4', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210013, 'Kathy', 'Yound', '1985-06-15', '2021-7-17', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210014, 'Helen', 'Clark', '2004-06-15', '2021-8-3', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210015, 'Bob', 'Papadopoulou', '2005-06-15', '2021-9-12', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210016, 'Alex', 'Scott', '2006-06-15', '2021-11-2', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210017, 'Lisa', 'Torres', '2000-06-15', '2021-11-14', 'Female');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210018, 'Sam', 'Carter', '2001-06-15', '2021-11-16', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210019, 'Andrew', 'Andrews', '1999-06-15', '2021-12-8', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210020, 'George', 'Georgiou', '2005-06-15', '2021-12-10', 'Male');
INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (210021, 'Paul', 'Papas', '2014-06-15', '2021-12-12', 'Male');
--team members test
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (300,200000,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (300,200009,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (300,210001,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (300,210002,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (300,210007,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (323,210007,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (323,210020,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (323,210013,'2022-1-5');
INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES (323,200014,'2022-1-5');
--Practice test
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (300, 'Monday', '10:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (300, 'Tuesday', '08:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (300, 'Friday', '08:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (301, 'Monday', '14:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (301, 'Wednesday', '12:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (302, 'Tuesday', '12:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (302, 'Friday', '16:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (303, 'Monday', '16:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (303, 'Wednesday', '18:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (304, 'Tuesday', '20:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (304, 'Saturday', '12:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (305, 'Monday', '18:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (305, 'Saturday', '12:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (306, 'Tuesday', '18:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (306, 'Sunday', '10:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (307, 'Monday', '08:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (307, 'Tuesday', '10:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (307, 'Friday', '10:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (308, 'Tuesday', '16:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (308, 'Sunday', '10:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (309, 'Monday', '20:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (309, 'Saturday', '16:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (310, 'Wednesday', '16:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (310, 'Sunday', '10:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (311, 'Tuesday', '10:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (311, 'Wednesday', '08:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (311, 'Friday', '10:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (312, 'Tuesday', '16:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (312, 'Saturday', '14:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (313, 'Tuesday', '16:00:00', 202);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (313, 'Thursday', '18:00:00', 202);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (314, 'Thursday', '16:00:00', 202);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (314, 'Saturday', '14:00:00', 202);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (315, 'Sunday', '14:00:00', 202);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (315, 'Wednesday', '16:00:00', 202);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (316, 'Monday', '18:00:00', 203);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (316, 'Wednesday', '18:00:00', 203);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (317, 'Tuesday', '18:00:00', 203);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (317, 'Friday', '18:00:00', 203);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (318, 'Thursday', '20:00:00', 203);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (318, 'Saturday', '18:00:00', 203);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (319, 'Tuesday', '16:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (319, 'Saturday', '12:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (320, 'Monday', '18:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (320, 'Sunday', '12:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (321, 'Monday', '16:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (321, 'Friday', '18:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (322, 'Monday', '18:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (322, 'Wednesday', '20:00:00', 204);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (323, 'Thursday', '10:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (323, 'Wednesday', '08:00:00', 201);
INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES (323, 'Friday', '10:00:00', 201);
--Match test
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (300, '2022-10-10', '18:00:00', 'Thermaikos', 201, 1);
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (300, '2022-10-12', '19:30:00', 'Lagkadas', NULL, 1);
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (300, '2022-10-20', '18:00:00', 'Katerini', NULL, 2);
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (300, '2022-11-30', '19:30:00', 'Mesimeri', 201, NULL);
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (323, '2022-10-12', '16:30:00', 'Tennis Serres', NULL, 1);
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (323, '2022-10-14', '15:00:00', 'Tennis Halkidiki', NULL, 2);
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (323, '2022-10-20', '16:30:00', 'Tennis Kilkis', NULL, 2);
INSERT INTO MATCHES (team_id, match_date, match_time, match_opponent, facility_id, match_placement) VALUES (323, '2022-11-30', '15:00:00', 'Tennis Club', NULL, NULL);
--LOGS
CREATE TABLE LOGS
(
	log_id integer NOT NULL,
	log_time timestamp,
	log_user varchar(20),
	log_table varchar(20),
	log_action char(1),
	log_old varchar(100),
	log_new varchar(100),
	CONSTRAINT "LOGS_pkey" PRIMARY KEY (log_id)
);