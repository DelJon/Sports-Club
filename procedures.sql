
--sports functions									sex			age		name
CREATE OR REPLACE FUNCTION select_sports(integer, varchar(10), integer, varchar) 
RETURNS TABLE  ( sportid integer, sportname varchar, sportsex varchar, sportage integer )
AS $$ -- integer determines value to sort by 0 for default, 1 for id, 2 for name
	DECLARE sql varchar := 'SELECT * FROM sports ';
	BEGIN
		IF ($2 IS NOT NULL) THEN
			sql = CONCAT(sql, 'WHERE sport_sex = ''', $2,'''');
			IF ($3 IS NOT NULL) THEN
				sql = CONCAT(sql, ' AND sport_age <= ', $3);
				IF ($4 IS NOT NULL) THEN
					sql = CONCAT (sql, CONCAT('  AND UPPER(sport_name) LIKE UPPER(''','%',$4,'%','''',')'));
				END IF;
			ELSIF ($4 IS NOT NULL) THEN
				sql = CONCAT (sql, CONCAT('  AND UPPER(sport_name) LIKE UPPER(''','%',$4,'%','''',')'));
			END IF;
		ELSIF ($3 IS NOT NULL) THEN 
			sql = CONCAT(sql, 'WHERE sport_age <= ', $3);
			IF ($4 IS NOT NULL) THEN
				sql = CONCAT (sql, CONCAT('  AND UPPER(sport_name) LIKE UPPER(''','%',$4,'%','''',')'));
			END IF;
		ELSIF ($4 IS NOT NULL) THEN
			sql = CONCAT (sql, CONCAT('  WHERE UPPER(sport_name) LIKE UPPER(''','%',$4,'%','''',')'));
		END IF;
		IF ($1 = 1) THEN
			sql = CONCAT(sql, ' ORDER BY sport_id');
		ELSIF ($1 = 2) THEN
			sql = CONCAT(sql, ' ORDER BY sport_name');
		END IF;

		sql = CONCAT(sql, ';');
		RETURN QUERY EXECUTE sql;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION insert_sports(varchar, varchar, integer) RETURNS VOID AS $$ --name, sex, age
	DECLARE new_id INTEGER;
	BEGIN
	IF (SELECT(SELECT COUNT(*) FROM sports) = 0) THEN
		new_id := 100;
	ELSE
		new_id := (SELECT sport_id FROM sports ORDER BY sport_id DESC LIMIT 1);
		new_id = new_id + 1;
	END IF;
	INSERT INTO SPORTS (sport_id, sport_name, sport_sex, sport_age) VALUES (new_id, $1, $2, $3);
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION edit_sports(integer, varchar(20), varchar(10), integer) RETURNS VOID AS $$ -- id, name, sex, age
	UPDATE sports SET sport_name = $2, sport_sex = $3, sport_age = $4 WHERE sport_id = $1;
$$ LANGUAGE SQL;
--facilities functions							sort	name		locat	active
CREATE OR REPLACE FUNCTION select_facilities(integer, varchar(30), varchar(10), bool) 
RETURNS TABLE (faid integer, fasize integer, faname varchar, falocation varchar, faactive bit) 
AS $$ -- integer determines value to sort by 0 for default, 1 for id, 2 for size, 3 for description
	BEGIN
		CREATE TEMP TABLE sfacilities (fid integer, fsize integer, fname varchar, flocation varchar, factive bit);
		CREATE TEMP TABLE tfacilities (fid integer, fsize integer, fname varchar, flocation varchar, factive bit);
		INSERT INTO sfacilities SELECT facility_id, facility_size, facility_desc, facility_location, facility_active FROM facilities;
		
		IF($4) THEN
			INSERT INTO tfacilities SELECT fid, fsize, fname, flocation, factive FROM sfacilities WHERE factive=1::bit;
			TRUNCATE TABLE sfacilities;
			INSERT INTO sfacilities SELECT * FROM tfacilities;
			TRUNCATE TABLE tfacilities;
		END IF;
		IF($2 IS NOT NULL) THEN
			INSERT INTO tfacilities SELECT fid, fsize, fname, flocation, factive FROM sfacilities WHERE UPPER(fname)LIKE UPPER(CONCAT('%',$2,'%'));
			TRUNCATE TABLE sfacilities;
			INSERT INTO sfacilities SELECT * FROM tfacilities;
			TRUNCATE TABLE tfacilities;
		END IF;
		IF($3 IS NOT NULL) THEN 
			INSERT INTO tfacilities SELECT fid, fsize, fname, flocation, factive FROM sfacilities WHERE flocation=$3;
			TRUNCATE TABLE sfacilities;
			INSERT INTO sfacilities SELECT * FROM tfacilities;
			TRUNCATE TABLE tfacilities;
		END IF;
		
		IF($1 = 1) THEN
			INSERT INTO tfacilities SELECT fid, fsize, fname, flocation, factive FROM sfacilities ORDER BY fid;
			TRUNCATE TABLE sfacilities;
			INSERT INTO sfacilities SELECT * FROM tfacilities;
			TRUNCATE TABLE tfacilities;
		ELSIF($1 = 2) THEN
			INSERT INTO tfacilities SELECT fid, fsize, fname, flocation, factive FROM sfacilities ORDER BY fsize DESC;
			TRUNCATE TABLE sfacilities;
			INSERT INTO sfacilities SELECT * FROM tfacilities;
			TRUNCATE TABLE tfacilities;
		ELSIF($1 = 3) THEN
			INSERT INTO tfacilities SELECT fid, fsize, fname, flocation, factive FROM sfacilities ORDER BY fname;
			TRUNCATE TABLE sfacilities;
			INSERT INTO sfacilities SELECT * FROM tfacilities;
			TRUNCATE TABLE tfacilities;
		END IF;
		RETURN QUERY SELECT * FROM sfacilities;
		DROP TABLE sfacilities;
		DROP TABLE tfacilities;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION insert_facilities(integer, varchar(30), varchar(10)) RETURNS VOID AS $$ --size, description, location
	DECLARE new_id INTEGER;
	BEGIN
	IF (SELECT(SELECT COUNT(*) FROM facilities) = 0) THEN
		new_id := 200;
	ELSE
		new_id := (SELECT facility_id FROM facilities ORDER BY facility_id DESC LIMIT 1);
		new_id = new_id + 1;
	END IF;
	INSERT INTO facilities (facility_id, facility_size, facility_desc, facility_location, facility_active) VALUES (new_id, $1, $2, $3, 1::bit);
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION edit_facilities(integer, integer, varchar(30), varchar(10)) RETURNS VOID AS $$ -- id, size, description, location
	UPDATE facilities SET facility_size = $2, facility_desc = $3, facility_location = $4 WHERE facility_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION active_facilities(integer) RETURNS VOID AS $$
	UPDATE facilities SET facility_active = ~facility_active WHERE facility_id = $1;
$$ LANGUAGE SQL;

--teams functions						sort		sport	name	active	member
CREATE OR REPLACE FUNCTION select_teams(integer, integer, varchar, bool, integer) 
RETURNS TABLE (tid integer, sname varchar, tname varchar, tactive bit)
AS $$ -- 1 id, 2 sport, 3 name, 4 active TO DO
	BEGIN
		CREATE TEMP TABLE steams( stid integer, ssname varchar, stname varchar, stactive bit);
		CREATE TEMP TABLE tteams( stid integer, ssname varchar, stname varchar, stactive bit);
		
		IF($2 IS NOT NULL) THEN
			INSERT INTO steams SELECT team_id, sport_name, team_name, team_active FROM TEAMS JOIN SPORTS ON TEAMS.sport_id=SPORTS.sport_id AND TEAMS.sport_id=$2;
		ELSE
			INSERT INTO steams SELECT team_id, sport_name, team_name, team_active FROM TEAMS JOIN SPORTS ON TEAMS.sport_id=SPORTS.sport_id;
		END IF;	

		IF($4) THEN
			INSERT INTO tteams SELECT stid, ssname, stname, stactive FROM steams WHERE stactive=1::bit;
			TRUNCATE TABLE steams;
			INSERT INTO steams SELECT * FROM tteams;
			TRUNCATE TABLE tteams;
		END IF;
		
		IF($3 IS NOT NULL) THEN
			INSERT INTO tteams SELECT stid, ssname, stname, stactive FROM steams WHERE UPPER(stname)LIKE UPPER(CONCAT('%',$3,'%'));
			TRUNCATE TABLE steams;
			INSERT INTO steams SELECT * FROM tteams;
			TRUNCATE TABLE tteams;
		END IF;
		
		IF($5 IS NOT NULL) THEN
			INSERT INTO tteams SELECT stid, ssname, stname, stactive FROM steams JOIN teams_of_member on stname=teams_of_member.team_name AND teams_of_member.member_id=$5;
			TRUNCATE TABLE steams;
			INSERT INTO steams SELECT * FROM tteams;
			TRUNCATE TABLE tteams;
		END IF;
		
		IF($1 = 1) THEN
			INSERT INTO tteams SELECT stid, ssname, stname, stactive FROM steams ORDER BY stid;
			TRUNCATE TABLE steams;
			INSERT INTO steams SELECT * FROM tteams;
			TRUNCATE TABLE tteams;
		ELSIF($1 = 2) THEN
			INSERT INTO tteams SELECT stid, ssname, stname, stactive FROM steams ORDER BY ssname;
			TRUNCATE TABLE steams;
			INSERT INTO steams SELECT * FROM tteams;
			TRUNCATE TABLE tteams;
		ELSIF($1 = 3) THEN
			INSERT INTO tteams SELECT stid, ssname, stname, stactive FROM steams ORDER BY stname;
			TRUNCATE TABLE steams;
			INSERT INTO steams SELECT * FROM tteams;
			TRUNCATE TABLE tteams;
		END IF;
		RETURN QUERY SELECT * FROM steams;
		DROP TABLE steams;
		DROP TABLE tteams;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION insert_teams(integer, varchar(20)) RETURNS VOID AS $$ --size, description, location
	DECLARE new_id INTEGER;
	BEGIN
	IF (SELECT(SELECT COUNT(*) FROM teams) = 0) THEN
		new_id := 300;
	ELSE
		new_id := (SELECT team_id FROM teams ORDER BY team_id DESC LIMIT 1);
		new_id = new_id + 1;
	END IF;
	INSERT INTO teams (team_id, sport_id, team_name, team_active) VALUES (new_id, $1, $2, 1::bit);
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION edit_teams(integer, integer, varchar(20)) RETURNS VOID AS $$ -- id, sport, name
	UPDATE teams SET sport_id = $2, team_name = $3 WHERE team_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION active_teams(integer) RETURNS VOID AS $$
	UPDATE teams SET team_active = ~team_active WHERE team_id = $1;
$$ LANGUAGE SQL;

--members functions 			
-- 											sort	name 		surname			sex		age	from 	to	   memberid joined from-to	team  active
CREATE OR REPLACE FUNCTION select_members(integer, varchar(20), varchar(20), varchar(10), integer, integer, integer, date, date, integer, bool) 
RETURNS TABLE (meid integer, mfname varchar, mlname varchar, mbirth date, mjoined date, mactive bit, msex varchar, mage integer)
AS $$ 

	BEGIN
		CREATE TEMP TABLE smembers (smeid integer, smfname varchar, smlname varchar, smbirth date, smjoined date, smactive bit, smsex varchar, smage integer);
		CREATE TEMP TABLE tmembers (smeid integer, smfname varchar, smlname varchar, smbirth date, smjoined date, smactive bit, smsex varchar, smage integer);
		INSERT INTO smembers SELECT member_id, member_first_name, member_last_name, member_birth, member_joined, member_active, member_sex,  ((NOW()::date-member_birth)/365) FROM MEMBERS;
		
		IF($2 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE UPPER(smfname)LIKE UPPER(CONCAT('%',$2,'%'));
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($3 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex,smage FROM smembers WHERE UPPER(smlname)LIKE UPPER(CONCAT('%',$3,'%'));
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($4 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE smsex = $4;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($5 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE ((NOW()::date-smbirth)/365) >= $5;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($6 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE ((NOW()::date-smbirth)/365) <= $6;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($7 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE smeid = $7;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($8 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE smjoined >= $8;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($9 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE smjoined <= $9;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($10 IS NOT NULL) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers JOIN members_of_team ON smeid=members_of_team.member_id WHERE members_of_team.team_id = $10;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($11) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers WHERE smactive = 1::bit;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		IF($1=1) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers ORDER BY smeid;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		ELSIF ($1=2) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers ORDER BY smfname;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		ELSIF ($1=3) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers ORDER BY smlname;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		ELSIF ($1=4) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers ORDER BY ((NOW()::date-smbirth)/365) DESC;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		ELSIF ($1=5) THEN
			INSERT INTO tmembers SELECT smeid, smfname, smlname, smbirth, smjoined, smactive, smsex, smage FROM smembers ORDER BY ((NOW()::date-smjoined)/365) DESC;
			TRUNCATE TABLE smembers;
			INSERT INTO smembers SELECT * FROM tmembers;
			TRUNCATE TABLE tmembers;
		END IF;
		
		RETURN QUERY SELECT * FROM smembers;
		DROP TABLE smembers;
		DROP TABLE tmembers;
		
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION insert_members(varchar(20), varchar(20), date, varchar(10)) RETURNS VOID AS $$ --first name, last name, birth, sex, compare current year and latest member's year to create ID
	DECLARE new_id INTEGER;
	DECLARE currentyear INTEGER;
	DECLARE latestyear INTEGER;
	BEGIN
	IF (SELECT(SELECT COUNT(*) FROM members) = 0) THEN
		new_id := (SELECT (SUBSTRING((DATE_PART('year',NOW())::varchar) FROM 3 for 2)||'0000')::INTEGER);
	ELSE
		currentyear := (SELECT (DATE_PART('year',NOW()))::integer);
		latestyear := (SELECT DATE_PART('year',member_joined)::integer FROM MEMBERS ORDER BY member_joined DESC LIMIT 1);
		IF(currentyear = latestyear) THEN
			new_id := (SELECT member_id FROM members ORDER BY member_id DESC LIMIT 1);
			new_id = new_id+1;
		ELSE
			new_id := (SELECT (SUBSTRING((DATE_PART('year',NOW())::varchar) FROM 3 for 2)||'0000')::INTEGER);
		END IF;
	END IF;
	INSERT INTO MEMBERS (member_id, member_first_name, member_last_name, member_birth, member_joined, member_sex) VALUES (new_id, $1, $2, $3, NOW()::date, $4);
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION edit_members(integer, varchar(20), varchar(20)) RETURNS VOID AS $$ -- ID, first name, last name, sex
	UPDATE members SET member_first_name = $2, member_last_name = $3 WHERE member_id = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION active_members(integer) RETURNS VOID AS $$
	UPDATE members SET member_active = ~member_active WHERE member_id = $1;
$$ LANGUAGE SQL;

--team members functions
CREATE OR REPLACE FUNCTION member_teams(integer) 
RETURNS TABLE (meid integer, mfname varchar, mlname varchar, mjoined date, tid integer)
AS $$ --returns the members that are part of a team(team_id)
	BEGIN
		CREATE TEMP TABLE mot (smeid integer, smfname varchar, smlname varchar, smjoined date, stid integer);
		INSERT INTO mot SELECT * FROM members_of_team WHERE team_id=$1;
		RETURN QUERY SELECT * FROM mot;
		DROP TABLE mot;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION team_of_member(integer) 
RETURNS TABLE (tname varchar, tid integer, mjoined date, meid integer)
AS $$ -- returns the teams a member is part of (member_id)
	BEGIN
		CREATE TEMP TABLE mot (stname varchar, stid integer, smjoined date, smeid integer);
		INSERT INTO mot SELECT * FROM teams_of_member WHERE member_id=$1;
		RETURN QUERY SELECT * FROM mot;
		DROP TABLE mot;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION insert_team_member(integer, integer) RETURNS VOID AS $$ --team id, member id
	INSERT INTO TEAM_MEMBERS (team_id, member_id, team_joined) VALUES ($1,$2,NOW()::date);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION remove_team_member(integer, integer) RETURNS VOID AS $$ --team id, member id
	DELETE FROM TEAM_MEMBERS WHERE team_id = $1 AND member_id = $2;
$$ LANGUAGE SQL;

--practices functions
CREATE OR REPLACE FUNCTION insert_practice(integer, varchar, time, integer) RETURNS VOID AS $$ --team id, day, time, facility id
	INSERT INTO PRACTICES (team_id, practice_day, practice_time, facility_id) VALUES ($1, $2, $3, $4);
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION delete_practice(integer, varchar, time) RETURNS VOID AS $$  --team id, day, time
	DELETE FROM PRACTICES WHERE team_id = $1 AND practice_day = $2 AND practice_time = $3;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION team_schedule(varchar) 
RETURNS TABLE (tid integer, pday varchar, ptime time, fid integer, tname varchar) 
AS $$
	BEGIN
		CREATE TEMP TABLE prac (stid integer, spday varchar, sptime time, sfid integer, stname varchar);
		INSERT INTO prac SELECT practices.team_id, practice_day, practice_time, facility_id, teams.team_name FROM practices JOIN teams ON teams.team_id=practices.team_id WHERE UPPER(team_name)=UPPER($1);
		RETURN QUERY SELECT * FROM prac;
		DROP TABLE PRAC;
	END;
$$ LANGUAGE PLPGSQL;
--matches functions

--LOG functions
CREATE OR REPLACE FUNCTION sport_log_function() RETURNS TRIGGER AS $$
	DECLARE new_id integer;
	DECLARE sport_old varchar(100) := 'N/A';
	DECLARE sport_new varchar(100) := 'N/A';
	BEGIN
		IF (OLD.sport_id IS NOT NULL) THEN
			sport_old = CONCAT('Old values: ', OLD.sport_id::varchar, ' | ', OLD.sport_name, ' | ', OLD.sport_sex, ' | ', OLD.sport_age, ' | ');
		END IF;
			
		IF (NEW.sport_id IS NOT NULL) THEN
			sport_new = CONCAT('New values: ', NEW.sport_id::varchar, ' | ', NEW.sport_name, ' | ', NEW.sport_sex, ' | ', NEW.sport_age, ' | ');
		END IF;
		IF (SELECT(SELECT COUNT(*) FROM logs) = 0) THEN
			new_id := 1;
		ELSE 
			new_id := (SELECT log_id FROM logs ORDER BY log_id DESC LIMIT 1);
			new_id := new_id+1;
		END IF;
		IF (TG_OP = 'DELETE') THEN		
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'SPORTS','D',sport_old, sport_new;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'SPORTS','U',sport_old, sport_new;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'SPORTS','I',sport_old, sport_new;
			RETURN NEW;
		END IF;
		RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION facility_log_function() RETURNS TRIGGER AS $$
	DECLARE new_id integer;
	DECLARE facility_old varchar(100) := 'N/A';
	DECLARE facility_new varchar(100) := 'N/A';
	BEGIN
		IF (OLD.facility_id IS NOT NULL) THEN
			facility_old = CONCAT('Old values: ', OLD.facility_id::varchar, ' | ', OLD.facility_desc, ' | ', OLD.facility_location, ' | ', OLD.facility_size::varchar, ' | ',OLD.facility_active::varchar,' | ');
		END IF;
			
		IF (NEW.facility_id IS NOT NULL) THEN
			facility_new = CONCAT('New values: ', NEW.facility_id::varchar, ' | ', NEW.facility_desc, ' | ', NEW.facility_location, ' | ', NEW.facility_size::varchar, ' | ',NEW.facility_active::varchar,' | ');
		END IF;
		IF (SELECT(SELECT COUNT(*) FROM logs) = 0) THEN
			new_id := 1;
		ELSE 
			new_id := (SELECT log_id FROM logs ORDER BY log_id DESC LIMIT 1);
			new_id := new_id+1;
		END IF;
		IF (TG_OP = 'DELETE') THEN		
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'FACILITIES','D',facility_old, facility_new;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'FACILITIES','U',facility_old, facility_new;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'FACILITIES','I',facility_old, facility_new;
			RETURN NEW;
		END IF;
		RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION team_log_function() RETURNS TRIGGER AS $$
	DECLARE new_id integer;
	DECLARE team_old varchar(100) := 'N/A';
	DECLARE team_new varchar(100) := 'N/A';
	BEGIN
		IF (OLD.team_id IS NOT NULL) THEN
			team_old = CONCAT('Old values: ', OLD.team_id::varchar, ' | ', OLD.team_name, ' | ', OLD.sport_id::varchar, ' | ', OLD.team_active::varchar, ' | ');
		END IF;
			
		IF (NEW.team_id IS NOT NULL) THEN
			team_new = CONCAT('New values: ', NEW.team_id::varchar, ' | ', NEW.team_name, ' | ', NEW.sport_id::varchar, ' | ', NEW.team_active::varchar, ' | ');
		END IF;
		IF (SELECT(SELECT COUNT(*) FROM logs) = 0) THEN
			new_id := 1;
		ELSE 
			new_id := (SELECT log_id FROM logs ORDER BY log_id DESC LIMIT 1);
			new_id := new_id+1;
		END IF;
		IF (TG_OP = 'DELETE') THEN		
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'TEAMS','D',team_old, team_new;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'TEAMS','U',team_old, team_new;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'TEAMS','I',team_old, team_new;
			RETURN NEW;
		END IF;
		RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION member_log_function() RETURNS TRIGGER AS $$
	DECLARE new_id integer;
	DECLARE member_old varchar(100) := 'N/A';
	DECLARE member_new varchar(100) := 'N/A';
	BEGIN
		IF (OLD.member_id IS NOT NULL) THEN
			member_old = CONCAT('Old values: ', OLD.member_id::varchar, ' | ', OLD.member_first_name, ' | ', OLD.member_last_name, ' | ', OLD.member_birth::varchar, ' | ',OLD.member_joined::varchar,' | ',OLD.member_sex,' | ',OLD.member_active::varchar,' | ');
		END IF;
			
		IF (NEW.member_id IS NOT NULL) THEN
			member_new = CONCAT('New values: ', NEW.member_id::varchar, ' | ', NEW.member_first_name, ' | ', NEW.member_last_name, ' | ', NEW.member_birth::varchar, ' | ',NEW.member_joined::varchar,' | ',NEW.member_sex,' | ',NEW.member_active::varchar,' | ');
		END IF;
		IF (SELECT(SELECT COUNT(*) FROM logs) = 0) THEN
			new_id := 1;
		ELSE 
			new_id := (SELECT log_id FROM logs ORDER BY log_id DESC LIMIT 1);
			new_id := new_id+1;
		END IF;
		IF (TG_OP = 'DELETE') THEN		
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'MEMBERS','D',member_old, member_new;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'MEMBERS','U',member_old, member_new;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'MEMBERS','I',member_old, member_new;
			RETURN NEW;
		END IF;
		RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION team_member_log_function() RETURNS TRIGGER AS $$
	DECLARE new_id integer;
	DECLARE team_member_old varchar(100) := 'N/A';
	DECLARE team_member_new varchar(100) := 'N/A';
	BEGIN
		IF (OLD.team_id IS NOT NULL) THEN
			team_member_old = CONCAT('Old values: ', OLD.team_id::varchar, ' | ', OLD.member_id::varchar, ' | ', OLD.team_joined::varchar, ' | ');
		END IF;
			
		IF (NEW.team_id IS NOT NULL) THEN
			team_member_new = CONCAT('New values: ', NEW.team_id::varchar, ' | ', NEW.member_id::varchar, ' | ', NEW.team_joined::varchar, ' | ');
		END IF;
		IF (SELECT(SELECT COUNT(*) FROM logs) = 0) THEN
			new_id := 1;
		ELSE 
			new_id := (SELECT log_id FROM logs ORDER BY log_id DESC LIMIT 1);
			new_id := new_id+1;
		END IF;
		IF (TG_OP = 'DELETE') THEN		
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'TEAM_MEMBERS','D',team_member_old, team_member_new;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'TEAM_MEMBERS','U',team_member_old, team_member_new;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'TEAM_MEMBERS','I',team_member_old, team_member_new;
			RETURN NEW;
		END IF;
		RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION practice_log_function() RETURNS TRIGGER AS $$
	DECLARE new_id integer;
	DECLARE practice_old varchar(100) := 'N/A';
	DECLARE practice_new varchar(100) := 'N/A';
	BEGIN
		IF (OLD.team_id IS NOT NULL) THEN
			practice_old = CONCAT('Old values: ', OLD.team_id::varchar, ' | ', OLD.practice_day::varchar, ' | ', OLD.practice_time::varchar, ' | ',OLD.facility_ID::varchar, ' | ');
		END IF;
			
		IF (NEW.team_id IS NOT NULL) THEN
			practice_new = CONCAT('New values: ', NEW.team_id::varchar, ' | ', NEW.practice_day::varchar, ' | ', NEW.practice_time::varchar, ' | ',NEW.facility_ID::varchar, ' | ');
		END IF;
		IF (SELECT(SELECT COUNT(*) FROM logs) = 0) THEN
			new_id := 1;
		ELSE 
			new_id := (SELECT log_id FROM logs ORDER BY log_id DESC LIMIT 1);
			new_id := new_id+1;
		END IF;
		IF (TG_OP = 'DELETE') THEN		
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'PRACTICES','D',practice_old, practice_new;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'PRACTICES','U',practice_old, practice_new;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO LOGS SELECT new_id, now(), USER::varchar(20),'PRACTICES','I',practice_old, practice_new;
			RETURN NEW;
		END IF;
		RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION select_logs() 
RETURNS TABLE (lid integer, ltime varchar, luser varchar, ltable varchar, laction varchar, lold varchar, lnew varchar)
AS $$
	BEGIN
		CREATE TEMP TABLE tlogs (tid integer, ttime varchar, tuser varchar, ttable varchar, taction varchar, told varchar, tnew varchar);
		INSERT INTO tlogs SELECT log_id, log_time::varchar, log_user, log_table, log_action::varchar, log_old, log_new FROM LOGS;
		RETURN QUERY SELECT * FROM tlogs;
		DROP TABLE tlogs;
	END;
$$ LANGUAGE PLPGSQL;
--TRIGGERS
CREATE TRIGGER sport_log
AFTER INSERT OR UPDATE OR DELETE ON SPORTS
	FOR EACH ROW EXECUTE PROCEDURE sport_log_function();
	
CREATE TRIGGER facility_log
AFTER INSERT OR UPDATE OR DELETE ON FACILITIES
	FOR EACH ROW EXECUTE PROCEDURE facility_log_function();
	
CREATE TRIGGER team_log
AFTER INSERT OR UPDATE OR DELETE ON TEAMS
	FOR EACH ROW EXECUTE PROCEDURE team_log_function();
	
CREATE TRIGGER member_log
AFTER INSERT OR UPDATE OR DELETE ON MEMBERS
	FOR EACH ROW EXECUTE PROCEDURE member_log_function();
	
CREATE TRIGGER team_member_log
AFTER INSERT OR UPDATE OR DELETE ON TEAM_MEMBERS
	FOR EACH ROW EXECUTE PROCEDURE team_member_log_function();
	
CREATE TRIGGER practice_log
AFTER INSERT OR UPDATE OR DELETE ON PRACTICES
	FOR EACH ROW EXECUTE PROCEDURE practice_log_function();