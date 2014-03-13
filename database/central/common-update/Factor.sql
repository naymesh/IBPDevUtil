delimiter $$

drop procedure if exists `getMainFactorsByStudyid`$$

CREATE PROCEDURE `getMainFactorsByStudyid`(IN v_studyid int, IN v_islocal int)
begin

    SET @sql := CONCAT("SELECT MIN(labelid) AS labelid ", 
    " , MIN(studyid) AS studyid  ",
    " , fname ",
    " , MIN(factorid) AS factorid ",
    " , traitid ",
    " , scaleid ",
    " , MIN(tmethid) AS tmethid ",
    " , ltype ",
    " , MIN(tid) AS tid ",
    " , fdesc AS description ", 
    " FROM ( ",
    " SELECT ",
    "  f.projectprop_id AS labelid ",
    "  , f.project_id AS studyid ",
    "  , fname.value AS fname ",
    "  , f.factorid AS factorid ",
    "  , f.traitid AS traitid ",
    "  , scalerel.object_id AS scaleid ",
    "  , methrel.object_id AS tmethid ",
    "  , IF(f.dtypeid IN (1120, 1125, 1128, 1130), 'C', 'N') AS ltype ",
    "  , f.storedinid AS tid ",
    "  , fdesc.value AS fdesc ",
    " FROM ",
    "  v_factor f ",
    "  INNER JOIN projectprop fname ON fname.project_id = f.project_id AND fname.rank = f.rank ",
    "    AND fname.type_id NOT IN (1070, 1060, f.varid, 1100) ",
    "  INNER JOIN cvterm_relationship scalerel ON scalerel.subject_id = f.varid AND scalerel.type_id = 1220 ",
    "  INNER JOIN cvterm_relationship methrel ON methrel.subject_id = f.varid AND methrel.type_id = 1210 ",
    "  INNER JOIN project_relationship pr ON pr.type_id = 1145 AND pr.subject_project_id = f.project_id ",
    "  INNER JOIN projectprop fdesc ON fdesc.project_id = f.project_id AND fdesc.rank = f.rank ",
    "    AND fdesc.type_id = 1060 ",
    " WHERE ",
    "  f.project_id =  ", v_studyid, 
    "  AND f.factorid = f.projectprop_id ",
    " UNION ",
    " SELECT  ",
    "  f.projectprop_id AS labelid ",
    "  , f.project_id AS studyid ",
    "  , fname.value AS fname ",
    "  , f.factorid AS factorid ",
    "  , f.traitid AS traitid ",
    "  , scalerel.object_id AS scaleid ",
    "  , methrel.object_id AS tmethid ",
    "  , IF(f.dtypeid IN (1120, 1125, 1128, 1130), 'C', 'N') AS ltype ",
    "  , f.storedinid AS tid ",
    "  , fdesc.value AS fdesc ",
    " FROM ",
    "  v_factor f ",
    "  INNER JOIN projectprop fname ON fname.project_id = f.project_id AND fname.rank = f.rank ",
    "    AND fname.type_id NOT IN (1070, 1060, f.varid, 1100) ",
    "  INNER JOIN cvterm_relationship scalerel ON scalerel.subject_id = f.varid AND scalerel.type_id = 1220 ",
    "  INNER JOIN cvterm_relationship methrel ON methrel.subject_id = f.varid AND methrel.type_id = 1210 ",
    "  INNER JOIN project_relationship pr ON pr.type_id = 1150 AND pr.subject_project_id = f.project_id ",
    "  INNER JOIN projectprop fdesc ON fdesc.project_id = f.project_id AND fdesc.rank = f.rank ",
    "    AND fdesc.type_id = 1060 ",
    " WHERE ",
    "  pr.object_project_id = ", v_studyid, 
    "  AND f.varid NOT IN (SELECT varid FROM v_factor WHERE project_id = ", v_studyid, ") ",
    "  AND f.factorid = f.projectprop_id ",
    ") AS x ",
    " GROUP BY traitid, scaleid, fname, ltype, fdesc ");

    IF(v_islocal = 1) THEN
            SET @sql = CONCAT(@sql,"ORDER BY labelid DESC");
    ELSE
            SET @sql = CONCAT(@sql,"ORDER BY labelid ASC");
    END IF;

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
	
end$$ 

drop procedure if exists `getFactorByStudyidAndFname`$$

CREATE PROCEDURE `getFactorByStudyidAndFname`(IN p_studyid int, IN p_fname varchar(255))
begin

SET @sql := CONCAT("select labelid, studyid, fname, factorid ",
",GROUP_CONCAT(if(relationship = 1200, ontology_id, NULL)) AS 'traitid' ", 
",GROUP_CONCAT(if(relationship = 1220, ontology_id, NULL)) AS 'scaleid' ",
",GROUP_CONCAT(if(relationship = 1210, ontology_id, NULL)) AS 'tmethid' ",
",GROUP_CONCAT(if(relationship = 1105, if(ontology_id IN (1120,1125,1128,1130), 'C', 'N') , NULL)) AS 'ltype' ", 
",GROUP_CONCAT(if(relationship = 1044, ontology_id, NULL)) AS 'tid' ", 
"FROM ", 
"(SELECT pp.projectprop_id as labelid  ",
",label.value as fname ", 
",cvtr.type_id as relationship ",
",cvtr.object_id as ontology_id  ",
",pp.project_id as studyid ", 
"FROM cvterm_relationship cvtr ",
"INNER JOIN projectprop pp ON pp.value = cvtr.subject_id ", 
"INNER JOIN projectprop label ON label.project_id = pp.project_id AND label.rank = pp.rank  ",
"WHERE pp.type_id = 1070 ", 
"and label.type_id in (1010, 1011, 1012, 1015, 1016, 1017, 1020, 1021, 1022, 1023, 1024, 1025, 1030, 1040, 1041, 1042, 1046, 1047)  ",
"and pp.project_id = ? ",
"AND NOT EXISTS ( select 1 from phenotype ph where ph.observable_id = pp.value )  ",
") factor left join v_factor v on factor.labelid = v.projectprop_id ",
"WHERE fname = ? ",
"GROUP BY labelid  ",
"LIMIT 1 ");

PREPARE stmt FROM @sql;
SET @studyid = p_studyid;
SET @fname = p_fname;
EXECUTE stmt USING @studyid, @fname;
	
end$$ 

drop procedure if exists `getFactorsByFactorIds`$$

CREATE PROCEDURE `getFactorsByFactorIds`(IN v_factorids varchar(1000))
begin

SET @sql := CONCAT("select labelid, studyid, fname, factorid ",
",GROUP_CONCAT(if(relationship = 1200, ontology_id, NULL)) AS 'traitid' ", 
",GROUP_CONCAT(if(relationship = 1220, ontology_id, NULL)) AS 'scaleid' ",
",GROUP_CONCAT(if(relationship = 1210, ontology_id, NULL)) AS 'tmethid' ",
",GROUP_CONCAT(if(relationship = 1105, if(ontology_id IN (1120,1125,1128,1130), 'C', 'N') , NULL)) AS 'ltype' ", 
",GROUP_CONCAT(if(relationship = 1044, ontology_id, NULL)) AS 'tid' ", 
"FROM ", 
"(SELECT pp.projectprop_id as labelid  ",
",label.value as fname ", 
",cvtr.type_id as relationship ",
",cvtr.object_id as ontology_id  ",
",pp.project_id as studyid ", 
"FROM cvterm_relationship cvtr  ",
"INNER JOIN projectprop pp ON pp.value = cvtr.subject_id ", 
"INNER JOIN projectprop label ON label.project_id = pp.project_id AND label.rank = pp.rank  ",
"WHERE pp.type_id = 1070 ", 
"and label.type_id in (1010, 1011, 1012, 1015, 1016, 1017, 1020, 1021, 1022, 1023, 1024, 1025, 1030, 1040, 1041, 1042, 1046, 1047)  ",
"AND NOT EXISTS ( select 1 from phenotype ph where ph.observable_id = pp.value )  ",
") factor left join v_factor v on factor.labelid = v.projectprop_id ",
"WHERE factorid IN ( ", v_factorids, ") ",
"GROUP BY labelid  ");

PREPARE stmt FROM @sql;
EXECUTE stmt;
	
end$$ 


drop procedure if exists `getGroupFactorsByStudyidAndFactorid`$$

CREATE PROCEDURE `getGroupFactorsByStudyidAndFactorid`(IN p_studyid int, IN p_factorid int)
begin

SET @sql := CONCAT("select labelid, studyid, fname, factorid ",
",GROUP_CONCAT(if(relationship = 1200, ontology_id, NULL)) AS 'traitid' ", 
",GROUP_CONCAT(if(relationship = 1220, ontology_id, NULL)) AS 'scaleid' ",
",GROUP_CONCAT(if(relationship = 1210, ontology_id, NULL)) AS 'tmethid' ",
",GROUP_CONCAT(if(relationship = 1105, if(ontology_id IN (1120,1125,1128,1130), 'C', 'N') , NULL)) AS 'ltype' ", 
",GROUP_CONCAT(if(relationship = 1044, ontology_id, NULL)) AS 'tid' ", 
"FROM ", 
"(SELECT pp.projectprop_id as labelid  ",
",label.value as fname ", 
",cvtr.type_id as relationship ",
",cvtr.object_id as ontology_id  ",
",pp.project_id as studyid ", 
"FROM cvterm_relationship cvtr ",
"INNER JOIN projectprop pp ON pp.value = cvtr.subject_id ", 
"INNER JOIN projectprop label ON label.project_id = pp.project_id AND label.rank = pp.rank  ",
"WHERE pp.type_id = 1070 ", 
"and label.type_id in (1010, 1011, 1012, 1015, 1016, 1017, 1020, 1021, 1022, 1023, 1024, 1025, 1030, 1040, 1041, 1042, 1046, 1047)  ",
"and pp.project_id = ? ",
"AND NOT EXISTS ( select 1 from phenotype ph where ph.observable_id = pp.value )  ",
") factor inner join v_factor v on factor.labelid = v.projectprop_id ", 
"WHERE v.factorid = ? AND relationship = 'has property' ",
"GROUP BY labelid  ");

PREPARE stmt FROM @sql;
SET @studyid = p_studyid;
SET @factorid = p_factorid;
EXECUTE stmt USING @studyid, @factorid;
	
end$$


drop procedure if EXISTS addFactor$$

CREATE PROCEDURE addFactor(
IN v_labelid int,
IN v_factorid int,
IN v_studyid int,
IN v_fname varchar(255),
IN v_traitid int,
IN v_scaleid int,
IN v_tmethid int,
IN v_ltype varchar(1),
IN v_tid int,
IN v_description varchar(255))
begin

DECLARE v_project_id int;
DECLARE v_projectprop_id int;
DECLARE v_rank int;
DECLARE v_type_id int;


/*START TRANSACTION;*/

	SELECT MAX(rank) + 1 as rank INTO v_rank 
	FROM projectprop pp
	WHERE pp.project_id = v_studyid;
	
	IF(v_rank IS NULL) THEN
	SET v_rank := 1;
	END IF;
	
	SET v_project_id := v_studyid; 
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);

        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=v_tid AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,v_tid,v_fname,v_rank);
	END IF;
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1060 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1060,v_description,v_rank);
	END IF;
	
	SELECT distinct cvttrait.subject_id into v_type_id 
    FROM cvterm_relationship cvttrait
    INNER JOIN cvterm_relationship cvtscale ON cvtscale.subject_id = cvttrait.subject_id 
    INNER JOIN cvterm_relationship cvtmethod ON cvtmethod.subject_id = cvttrait.subject_id  
	WHERE cvttrait.object_id = v_traitid AND cvttrait.type_id = 1200
	AND cvtscale.object_id = v_scaleid AND cvtscale.type_id = 1220 
	AND cvtmethod.object_id = v_tmethid AND cvtmethod.type_id = 1210
	LIMIT 1;    
    
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1070 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1070,v_type_id,v_rank);
	END IF;
	SELECT v_projectprop_id;

/* COMMIT;	*/
	
end$$

drop procedure if EXISTS addStudyCondition$$

CREATE PROCEDURE addStudyCondition(
IN v_labelid int,
IN v_factorid int,
IN v_studyid int,
IN v_fname varchar(255),
IN v_traitid int,
IN v_scaleid int,
IN v_tmethid int,
IN v_ltype varchar(1),
IN v_tid int,
IN v_description varchar(255),
IN v_value varchar(255))
begin

DECLARE v_project_id int;
DECLARE v_projectprop_id, v_return_id int;
DECLARE v_rank int;
DECLARE v_type_id int;


/*START TRANSACTION;*/

	SELECT MAX(rank) + 1 as rank INTO v_rank 
	FROM projectprop pp
	WHERE pp.project_id = v_studyid;
	
	IF(v_rank IS NULL) THEN
	SET v_rank := 1;
	END IF;
	
	SET v_project_id := v_studyid; 
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);

        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=v_tid AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,v_tid,v_fname,v_rank);
	END IF;
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1060 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1060,v_description,v_rank);
	END IF;
	
	SELECT distinct cvttrait.subject_id into v_type_id 
    FROM cvterm_relationship cvttrait
    INNER JOIN cvterm_relationship cvtscale ON cvtscale.subject_id = cvttrait.subject_id 
    INNER JOIN cvterm_relationship cvtmethod ON cvtmethod.subject_id = cvttrait.subject_id  
	WHERE cvttrait.object_id = v_traitid AND cvttrait.type_id = 1200
	AND cvtscale.object_id = v_scaleid AND cvtscale.type_id = 1220 
	AND cvtmethod.object_id = v_tmethid AND cvtmethod.type_id = 1210
	LIMIT 1;    
    
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1070 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1070,v_type_id,v_rank);
	END IF;

        SET v_return_id := v_projectprop_id;

        -- add fourth record for storing condition value
        CALL getNextMinReturn('projectprop',v_projectprop_id);
         -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=v_type_id AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,v_type_id,v_value,v_rank);
	END IF;

	SELECT v_return_id;

/* COMMIT;	*/
	
end$$

drop procedure if EXISTS addTreatmentFactor$$

CREATE PROCEDURE addTreatmentFactor(
IN v_labelid int,
IN v_factorid int,
IN v_studyid int,
IN v_fname varchar(255),
IN v_traitid int,
IN v_scaleid int,
IN v_tmethid int,
IN v_ltype varchar(1),
IN v_tid int,
IN v_description varchar(255),
IN v_label varchar(255))
begin

DECLARE v_project_id int;
DECLARE v_projectprop_id int;
DECLARE v_rank int;
DECLARE v_type_id int;


/*START TRANSACTION;*/

	SELECT MAX(rank) + 1 as rank INTO v_rank 
	FROM projectprop pp
	WHERE pp.project_id = v_studyid;
	
	IF(v_rank IS NULL) THEN
	SET v_rank := 1;
	END IF;
	
	SET v_project_id := v_studyid; 
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);

        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=v_tid AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,v_tid,v_fname,v_rank);
	END IF;
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1060 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1060,v_description,v_rank);
	END IF;
	
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1100 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1100,v_label,v_rank);
	END IF;
        


	SELECT distinct cvttrait.subject_id into v_type_id 
    FROM cvterm_relationship cvttrait
    INNER JOIN cvterm_relationship cvtscale ON cvtscale.subject_id = cvttrait.subject_id 
    INNER JOIN cvterm_relationship cvtmethod ON cvtmethod.subject_id = cvttrait.subject_id  
    INNER JOIN cvterm_relationship storedin ON storedin.subject_id = cvttrait.subject_id
        AND storedin.type_id = 1044 AND storedin.object_id NOT IN (1043, 1048)
	WHERE cvttrait.object_id = v_traitid AND cvttrait.type_id = 1200
	AND cvtscale.object_id = v_scaleid AND cvtscale.type_id = 1220 
	AND cvtmethod.object_id = v_tmethid AND cvtmethod.type_id = 1210
	LIMIT 1;    
    
	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
        -- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
        IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1070 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1070,v_type_id,v_rank);
	END IF;

	SELECT v_projectprop_id;

/* COMMIT;	*/
	
end$$

delimiter $$

drop procedure if exists `getFactoridByLabelid`$$

CREATE PROCEDURE `getFactoridByLabelid`(IN v_labelid int)
begin

	SELECT factorid
	FROM v_factor 
	WHERE projectprop_id = v_labelid;
	
end$$ 


drop procedure if EXISTS getFactorsByStudyId$$

CREATE PROCEDURE getFactorsByStudyId(IN v_studyid int, IN v_islocal int)
BEGIN

    SET @sql := "SELECT DISTINCT
      f.projectprop_id AS labelid
      , f.project_id AS studyid
      , fname.value AS fname
      , f.factorid AS factorid
      , f.traitid AS traitid
      , scalerel.object_id AS scaleid
      , methrel.object_id AS tmethid
      , IF(f.dtypeid IN (1120, 1125, 1128, 1130), 'C', 'N') AS ltype
      , f.storedinid AS tid
      , fdesc.value AS description
      , tf.value AS label
    FROM
      v_factor f
      INNER JOIN projectprop fname ON fname.project_id = f.project_id AND fname.rank = f.rank
        AND fname.type_id NOT IN (1070, 1060, f.varid, 1100)
      INNER JOIN cvterm_relationship scalerel ON scalerel.subject_id = f.varid AND scalerel.type_id = 1220
      INNER JOIN cvterm_relationship methrel ON methrel.subject_id = f.varid AND methrel.type_id = 1210
      INNER JOIN project_relationship pr ON pr.type_id = 1150 AND (f.project_id = pr.subject_project_id OR f.project_id = pr.object_project_id) 
      INNER JOIN projectprop fdesc ON fdesc.project_id = f.project_id AND fdesc.rank = f.rank AND fdesc.type_id = 1060
      LEFT JOIN projectprop tf ON tf.project_id = f.project_id and tf.rank = f.rank and tf.type_id = 1100
    WHERE
      pr.object_project_id = ? ";
    
    IF(v_isLocal = 1) THEN
            SET @sql = CONCAT(@sql,"ORDER BY labelid DESC");
    ELSE
            SET @sql = CONCAT(@sql,"ORDER BY labelid ASC");
    END IF;

    PREPARE stmt FROM @sql;
    SET @studyid = v_studyid;
    EXECUTE stmt USING @studyid;
end$$ 

delimiter ;
