delimiter $$

drop procedure if EXISTS getVariateById$$

CREATE PROCEDURE getVariateById(IN v_variatid int)
begin

	SELECT variatid, vname 
	,studyid 
	,GROUP_CONCAT(if(relationship = 1200, ontology_id, NULL)) AS 'traitid' 
	,GROUP_CONCAT(if(relationship = 1220, ontology_id, NULL)) AS 'scaleid' 
	,GROUP_CONCAT(if(relationship = 1210, ontology_id, NULL)) AS 'tmethid' 
	,GROUP_CONCAT(if(relationship = 1225, ontology_id, NULL)) AS 'vtype' 
	,GROUP_CONCAT(if(relationship = 1105, IF(ontology_id IN (1120, 1125, 1128, 1130), 'C', 'N'), NULL)) AS 'dtype' 
	,GROUP_CONCAT(if(relationship = 1044, ontology_id, NULL)) AS 'tid' 
        ,GROUP_CONCAT(if(relationship = 1105, ontology_id, NULL)) AS 'dtypeId'
	FROM 
	(SELECT pp.projectprop_id as variatid 
	,label.value as vname 
	,cvtr.type_id as relationship 
	,cvtr.object_id as ontology_id 
	,pr.object_project_id as studyid 
	FROM cvterm_relationship cvtr 
	INNER JOIN projectprop pp ON pp.value = cvtr.subject_id 
	INNER JOIN projectprop label ON label.project_id = pp.project_id AND label.rank = pp.rank 
	INNER JOIN project_relationship pr ON pr.subject_project_id = pp.project_id AND pr.type_id = 1150
	WHERE pp.type_id = 1070 AND label.type_id in (1043,1048) AND pp.projectprop_id = v_variatid 
	AND EXISTS ( SELECT 1 FROM phenotype ph WHERE ph.observable_id = pp.value ) 
	GROUP BY variatid, cvtr.type_id, cvtr.object_id, pp.project_id
	) as variate;
	
end$$

drop procedure if EXISTS addVariate$$

CREATE PROCEDURE addVariate(
IN v_studyid int,
IN v_vname varchar(255),
IN v_traitid int,
IN v_scaleid int,
IN v_tmethid int,
IN v_dtype varchar(1),
IN v_vtype varchar(10),
IN v_tid int,
IN v_description varchar(255))
begin

DECLARE v_project_id int;
DECLARE v_projectprop_id int;
DECLARE v_rank int;
DECLARE v_type_id int;


-- START TRANSACTION;

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
		VALUES(v_projectprop_id,v_project_id,v_tid,v_vname,v_rank);
	END IF;

	CALL getNextMinReturn('projectprop',v_projectprop_id);
	
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
	
	IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_project_id AND type_id=1070 AND rank=v_rank) THEN
		INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
		VALUES(v_projectprop_id,v_project_id,1070,v_type_id,v_rank);
	END IF;

	SELECT v_projectprop_id;

-- COMMIT;	
	
end$$




DROP PROCEDURE IF EXISTS `getVarieteFromVeffects`$$

CREATE PROCEDURE `getVarieteFromVeffects`(IN p_represno int, IN v_isLocal int)

BEGIN

  SET @sql := "SELECT
        pp.projectprop_id AS variatid
        , pr.object_project_id AS studyid
        , term.value AS vname
        , cvr.subject_id AS measuredinid
        , GROUP_CONCAT(IF(cvr.type_id = 1200, cvr.object_id, NULL)) AS traitid
        , GROUP_CONCAT(IF(cvr.type_id = 1220, cvr.object_id, NULL)) AS scaleid
        , GROUP_CONCAT(IF(cvr.type_id = 1210, cvr.object_id, NULL)) AS tmethid
        , GROUP_CONCAT(IF(cvr.type_id = 1105, IF(cvr.object_id IN (1120, 1125, 1128, 1130), 'C', 'N'), NULL)) AS dtype
        , GROUP_CONCAT(IF(cvr.type_id = 1225, obj.name, NULL)) AS vtype
        , GROUP_CONCAT(IF(cvr.type_id = 1044, cvr.object_id, NULL)) AS tid
        , vdesc.value AS description
        , GROUP_CONCAT(IF(cvr.type_id = 1105, cvr.object_id, NULL)) AS dtypeId
        FROM
        projectprop pp
        INNER JOIN project_relationship pr ON pr.type_id = 1150 AND pr.subject_project_id = pp.project_id
        INNER JOIN cvterm_relationship cvr ON cvr.subject_id = pp.value
        LEFT JOIN cvterm obj ON obj.cvterm_id = cvr.object_id
        INNER JOIN projectprop term ON term.project_id = pp.project_id AND term.rank = pp.rank AND term.type_id IN (1043, 1048)
        INNER JOIN projectprop vdesc ON vdesc.project_id = pp.project_id AND vdesc.rank = pp.rank AND vdesc.type_id = 1060
        WHERE
        pp.type_id = 1070 
        AND pp.project_id = ?
        GROUP BY
        pp.projectprop_id "
  ;

    
    IF(v_isLocal = 1) THEN
        SET @sql = CONCAT(@sql,"ORDER BY variatid DESC");
    ELSE
        SET @sql = CONCAT(@sql,"ORDER BY variatid ASC");
    END IF;

    PREPARE stmt FROM @sql;
    SET @effectid = p_represno;
    EXECUTE stmt USING @effectid;

END$$


DROP PROCEDURE IF EXISTS `getVarieteFromStudyId`$$

CREATE PROCEDURE `getVarieteFromStudyId`(IN p_studyid int, IN v_isLocal int)

BEGIN

  SET @sql := "SELECT
        pp.projectprop_id AS variatid
        , pp.project_id AS studyid
        , term.value AS vname
        , GROUP_CONCAT(IF(cvr.type_id = 1200, cvr.object_id, NULL)) AS traitid
        , GROUP_CONCAT(IF(cvr.type_id = 1220, cvr.object_id, NULL)) AS scaleid
        , GROUP_CONCAT(IF(cvr.type_id = 1210, cvr.object_id, NULL)) AS tmethid
        , GROUP_CONCAT(IF(cvr.type_id = 1105, IF(cvr.object_id IN (1120, 1125, 1128, 1130), 'C', 'N'), NULL)) AS dtype
        , GROUP_CONCAT(IF(cvr.type_id = 1225, obj.name, NULL)) AS vtype
        , GROUP_CONCAT(IF(cvr.type_id = 1044, cvr.object_id, NULL)) AS tid
        , vdesc.value AS description
        , GROUP_CONCAT(IF(cvr.type_id = 1105, cvr.object_id, NULL)) AS dtypeId
      FROM
        projectprop pp
        INNER JOIN cvterm_relationship cvr ON cvr.subject_id = pp.value
        LEFT JOIN cvterm obj ON obj.cvterm_id = cvr.object_id
        INNER JOIN projectprop term ON term.project_id = pp.project_id AND term.rank = pp.rank AND term.type_id IN (1043, 1048)
        INNER JOIN projectprop vdesc ON vdesc.project_id = pp.project_id AND vdesc.rank = pp.rank AND vdesc.type_id = 1060
      WHERE
        pp.type_id = 1070 
        AND pp.project_id = ?
      GROUP BY
        pp.projectprop_id "
      ;

    IF(v_isLocal = 1) THEN
        SET @sql = CONCAT(@sql,"ORDER BY variatid DESC");
    ELSE
        SET @sql = CONCAT(@sql,"ORDER BY variatid ASC");
    END IF;

    PREPARE stmt FROM @sql;
    SET @studyid = p_studyid;
    EXECUTE stmt USING @studyid;

END$$

delimiter ;