delimiter $$

drop procedure if exists `addStudy`$$

CREATE PROCEDURE `addStudy`(
IN v_studyid int,
IN v_sname varchar(255) CHARACTER SET utf8, 
IN v_pmkey int,
IN v_title varchar(255) CHARACTER SET utf8, 
IN v_objectiv varchar(255) CHARACTER SET utf8,
IN v_investid int,
IN v_stype varchar(3) CHARACTER SET utf8,
IN v_sdate int,
IN v_edate int,
IN v_userid int,
IN v_sstatus int,
IN v_shierarchy int)
begin

DECLARE v_projectprop_id int;
DECLARE v_project_relationship_id int; 
-- START TRANSACTION;
	
SET foreign_key_checks = 0;

	-- PROJECT unique constraint | NAME
	IF NOT EXISTS (SELECT 1 FROM project WHERE name=v_sname) THEN
  		INSERT INTO project(project_id,name,description)
		VALUES(v_studyid,v_sname,v_title);
	END IF;
	
	CALL getNextMinReturn('project_relationship',v_project_relationship_id);
	
        -- if a study, make it a subfolder of root folder
        IF v_shierarchy > 0 THEN
            SET @relationship := 1140;
        ELSE
            SET @relationship := 1145;
        END IF;

	-- PROJECT_RELATIONSHIP unique constraint | SUBJECT_PROJECT_ID, OBJECT_PROJECT_ID, TYPE_ID
	IF NOT EXISTS (SELECT 1 FROM project_relationship WHERE subject_project_id=v_studyid AND object_project_id=v_shierarchy AND type_id=@relationship) THEN
		INSERT INTO project_relationship(project_relationship_id,type_id,object_project_id,subject_project_id)
		VALUE(v_project_relationship_id, @relationship ,v_shierarchy,v_studyid);
	END IF;
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1011 AND rank=1) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1011,'STUDY',1);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=1) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'STUDY NAME',1);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=1) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8005,1);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1012 AND rank=2) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1012,'TITLE',2);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=2) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'TITLE ASSIGNED',2);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=2) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8007,2);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1010 AND rank=3) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1010,'PMKEY',3);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=3) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'PROJECT MANAGEMENT KEY',3);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=3) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8040,3);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=8040 AND rank=3) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,8040,v_pmkey,3);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;

	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1010 AND rank=4) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1010,'OBJECTIVE',4);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=4) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'OBJECTIVE DESCRIBED',4);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=4) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8030,4);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=8030 AND rank=4) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,8030,v_objectiv,4);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;

	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1010 AND rank=5) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1010,'START DATE',5);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=5) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'STUDY START DATE',5);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=5) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8050,5);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=8050 AND rank=5) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,8050,v_sdate,5);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1010 AND rank=6) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1010,'END DATE',6);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=6) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'STUDY END DATE',6);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=6) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8060,6);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=8060 AND rank=6) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,8060,v_edate,6);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1010 AND rank=7) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1010,'STUDY TYPE',7);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=7) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'TYPE OF STUDY',7);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=7) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8070,7);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=8070 AND rank=7) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		SELECT v_projectprop_id AS projectprop_id, v_studyid AS project_id, 8070 as type_id, cvterm_id as value, 7 as rank
		FROM cvterm
		WHERE name = v_stype
	  	AND cv_id = 2010;
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1010 AND rank=8) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1010,'STUDY UID',8);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=8) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'STUDY USER ID',8);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=8) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8020,8);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=8020 AND rank=8) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,8020,v_userid,8);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1011 AND rank=9) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1011,'STUDY_STATUS',9);
	END IF;

	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1060 AND rank=9) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1060,'Study status (1=active, 2=private, 3=locked, 9=deleted)',9);	
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=1070 AND rank=9) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_studyid,1070,8006,9);
	END IF;
	
	SET v_projectprop_id := v_projectprop_id - 1;
	
	-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_studyid AND type_id=8006 AND rank=9) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		SELECT v_projectprop_id AS projectprop_id, v_studyid AS project_id, 8006 as type_id, cvterm_id as value, 9 as rank
		FROM cvterm
		WHERE name = v_sstatus
  		AND cv_id = 2005;
	END IF;
  	

-- COMMIT;

end$$

drop procedure if exists `updateStudy`$$

CREATE PROCEDURE `updateStudy`(
IN v_studyid int,
IN v_sname varchar(255) CHARACTER SET utf8, 
IN v_pmkey int,
IN v_title varchar(255) CHARACTER SET utf8, 
IN v_objectiv varchar(255) CHARACTER SET utf8,
IN v_investid int,
IN v_stype varchar(3) CHARACTER SET utf8,
IN v_sdate int,
IN v_edate int,
IN v_userid int,
IN v_sstatus int,
IN v_shierarchy int)
begin

DECLARE v_projectprop_id int;
DECLARE v_project_relationship_id int;


-- START TRANSACTION;
	
	UPDATE project
	SET name = v_sname
	,description = v_title
	WHERE project_id = v_studyid;
	
	update projectprop pp
	set value = v_sname
	where pp.project_id = v_studyid
	and pp.type_id = 8005;
	
	update projectprop pp
	set value = v_title
	where pp.project_id = v_studyid
	and pp.type_id = 8007;
	
	update projectprop pp
	set value = v_pmkey
	where pp.project_id = v_studyid
	and pp.type_id = 8040;
	
	update projectprop pp
	set value = v_objectiv
	where pp.project_id = v_studyid
	and pp.type_id = 8030;
	
	update projectprop pp
	set value = v_investid
	where pp.project_id = v_studyid
	and pp.type_id = 8110;	
	
	update projectprop pp
	set value = (select cvterm_id from cvterm where name = v_stype and cv_id = 2010) 
	where pp.project_id = v_studyid
	and pp.type_id = 8070;
	
	update projectprop pp
	set value = v_sdate  
	where pp.project_id = v_studyid
	and pp.type_id = 8050;
	
	update projectprop pp
	set value = v_edate 
	where pp.project_id = v_studyid
	and pp.type_id = 8060;
	
	update projectprop pp
	set value = v_userid 
	where pp.project_id = v_studyid
	and pp.type_id = 8020;
	
	update projectprop pp
	set value = (select cvterm_id from cvterm where name = v_sstatus and cv_id = 2005) 
	where pp.project_id = v_studyid
	and pp.type_id = 8006;
		
	update project_relationship pr
	set object_project_id = v_shierarchy 
	where pr.subject_project_id = v_studyid;
	
-- COMMIT;

end$$

drop procedure if exists `getStudyList`$$

CREATE PROCEDURE `getStudyList`()
begin
        
	SELECT distinct p.project_id as studyid, p.name as sname, p.description as title, pr.object_project_id AS shierarchy 
	,GROUP_CONCAT(if(value.type_id = 8040, value.value, NULL)) AS 'pmkey' 
	,GROUP_CONCAT(if(value.type_id = 8030, value.value, NULL)) AS 'objectiv' 
	,GROUP_CONCAT(if(value.type_id = 8110, value.value, NULL)) AS 'investid' 
	,GROUP_CONCAT(if(value.type_id = 8070, ct2.name, NULL)) AS 'stype' 
	,GROUP_CONCAT(if(value.type_id = 8050, value.value, NULL)) AS 'sdate' 
	,GROUP_CONCAT(if(value.type_id = 8060, value.value, NULL)) AS 'edate' 
	,GROUP_CONCAT(if(value.type_id = 8020, value.value, NULL)) AS 'userid' 
	,GROUP_CONCAT(if(value.type_id = 8006, ct2.name, NULL)) AS 'sstatus' 
	FROM project p 
	INNER JOIN project_relationship pr ON pr.subject_project_id = p.project_id
	,projectprop value 
	LEFT JOIN cvterm ct2 ON ct2.cvterm_id = value.value 
	WHERE value.project_id = p.project_id 
  	AND value.type_id IN (8006,8040,8030,8110,8070,8050,8060,8020) 
	GROUP BY p.project_id
	HAVING (sstatus IS NULL OR sstatus != 9);

end$$

drop procedure if exists `getStudyById`$$

CREATE PROCEDURE `getStudyById`(IN v_studyid int)
begin
        
	SELECT distinct p.project_id as studyid, p.name as sname, p.description as title, pr.object_project_id AS shierarchy
	,GROUP_CONCAT(if(value.type_id = 8040, value.value, NULL)) AS 'pmkey' 
	,GROUP_CONCAT(if(value.type_id = 8030, value.value, NULL)) AS 'objectiv' 
	,GROUP_CONCAT(if(value.type_id = 8110, value.value, NULL)) AS 'investid' 
	,GROUP_CONCAT(if(value.type_id = 8070, ct2.name, NULL)) AS 'stype' 
	,GROUP_CONCAT(if(value.type_id = 8050, value.value, NULL)) AS 'sdate' 
	,GROUP_CONCAT(if(value.type_id = 8060, value.value, NULL)) AS 'edate' 
	,GROUP_CONCAT(if(value.type_id = 8020, value.value, NULL)) AS 'userid' 
	,GROUP_CONCAT(if(value.type_id = 8006, ct2.name, NULL)) AS 'sstatus'
	FROM project p 
	INNER JOIN project_relationship pr ON pr.subject_project_id = p.project_id 
	,projectprop value 
	LEFT JOIN cvterm ct2 ON ct2.cvterm_id = value.value 
	WHERE value.project_id = p.project_id 
  	AND value.type_id IN (8006,8040,8030,8110,8070,8050,8060,8020)
	AND p.project_id = v_studyid;
	
end$$

drop procedure if exists `getStudy`$$

CREATE PROCEDURE `getStudy`(
IN v_studyid int,
IN v_sname varchar(255) CHARACTER SET utf8, 
IN v_pmkey int,
IN v_title varchar(255) CHARACTER SET utf8, 
IN v_objectiv varchar(255) CHARACTER SET utf8,
IN v_investid int,
IN v_stype varchar(3) CHARACTER SET utf8,
IN v_sdate int,
IN v_edate int,
IN v_userid int,
IN v_shierarchy int)
begin
       
	SET @sql := CONCAT("SELECT distinct p.project_id as studyid, p.name as sname, p.description as title, pr.object_project_id AS shierarchy", 
	",GROUP_CONCAT(if(pp.type_id = 8040, pp.`value`, NULL)) AS 'pmkey'", 
	",GROUP_CONCAT(if(pp.type_id = 8030, pp.`value`, NULL)) AS 'objectiv'",  
	",GROUP_CONCAT(if(pp.type_id = 8110, pp.`value`, NULL)) AS 'investid'",  
	",GROUP_CONCAT(if(pp.type_id = 8070, ct2.name, NULL)) AS 'stype'",  
	",GROUP_CONCAT(if(pp.type_id = 8050, pp.`value`, NULL)) AS 'sdate'",  
	",GROUP_CONCAT(if(pp.type_id = 8060, pp.`value`, NULL)) AS 'edate'",  
	",GROUP_CONCAT(if(pp.type_id = 8020, pp.`value`, NULL)) AS 'userid'",  
	",GROUP_CONCAT(if(pp.type_id = 8006, ct2.name, NULL)) AS 'sstatus'",  
	"FROM project p ", 
	"INNER JOIN project_relationship pr ON pr.subject_project_id = p.project_id ",  
	",projectprop pp ", 
	"LEFT JOIN cvterm ct2 ON ct2.cvterm_id = pp.`value` ",  
	"WHERE pp.project_id = p.project_id ", 
  	"AND pp.type_id IN (8006,8040,8030,8110,8070,8050,8060,8020) ",  
	"GROUP BY p.project_id HAVING (sstatus IS NULL OR sstatus != 9) ");
	IF(v_studyid IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND studyid = ",v_studyid);
	END IF;
	IF(v_sname IS NOT NULL) THEN
    SET @sql = CONCAT(@sql," AND sname = '",v_sname,"'");
    END IF;
	IF(v_title IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND title = '",v_title,"'");
	END IF;
	IF(v_shierarchy IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND shierarchy = ",v_shierarchy);
	END IF;
	IF(v_pmkey IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND pmkey = ",v_pmkey);
	END IF;
	IF(v_objectiv IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND objectiv = '",v_objectiv,"'");
	END IF;
	IF(v_investid IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND investid = ",v_investid);
	END IF;
	IF(v_stype IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND stype = '",v_stype,"'");
	END IF;
	IF(v_sdate IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND sdate = ",v_sdate);
	END IF;
	IF(v_edate IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND edate = ",v_edate);
	END IF;
	IF(v_userid IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND userid = ",v_userid);
	END IF;
	
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	
end$$

drop procedure if exists `deleteStudy`$$

CREATE PROCEDURE `deleteStudy`(IN v_studyid int)
begin

declare v_prevname varchar(50) CHARACTER SET utf8;
declare v_postfix varchar(50) CHARACTER SET utf8;

-- START TRANSACTION;

	update projectprop pp
	set value = (select cvterm_id from cvterm where name = 9 and cv_id = 2005)
	where pp.project_id = v_studyid
	and pp.type_id = 8006;

	update projectprop
	set value = (select cvterm_id from cvterm where name = 9 and cv_id = 2005)
	where type_id = 8006
	and project_id in
	( 
	  select subject_project_id
	  from project_relationship 
	  where object_project_id = v_studyid
	  union all
	  select child.subject_project_id
	  from project_relationship parent, project_relationship child 
	  where parent.object_project_id = v_studyid
	  and child.object_project_id = parent.subject_project_id
	);
	
  	select name into v_prevname 
	from project 
	where project_id = v_studyid;
	
	select UUID() into v_postfix; 

	update project
	set name = CONCAT(v_prevname,'#',v_postfix)
	where project_id = v_studyid;
	
	update project
	set name = CONCAT(name,'#',v_postfix)
	where project_id in
	( 
	  select subject_project_id
	  from project_relationship 
	  where object_project_id = v_studyid
	  union all
	  select child.subject_project_id
	  from project_relationship parent, project_relationship child 
	  where parent.object_project_id = v_studyid
	  and child.object_project_id = parent.subject_project_id
	);	
	

-- COMMIT;

end$$ 

DROP PROCEDURE IF EXISTS `checkStudyName`$$

-- unique constraint on project-name, therefore don't need to check whethere
-- it's a study or a dataset, having the same name is not allowed.
CREATE PROCEDURE `checkStudyName`(IN v_sname varchar(255) CHARACTER SET utf8)
BEGIN
    SELECT p.name AS sname
    FROM project p
    WHERE p.name = v_sname;
END$$

delimiter ;