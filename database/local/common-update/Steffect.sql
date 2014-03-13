delimiter $$

drop procedure if exists `getEffectidsByStudyid`$$

CREATE PROCEDURE `getEffectidsByStudyid`(IN studyid int, IN iscentral int)
begin



IF iscentral = 1 then

	select pr.subject_project_id as effectid
	from project_relationship pr where pr.type_id = 1150
	and pr.object_project_id = studyid
	order by effectid asc;

else

	select pr.subject_project_id as effectid
	from project_relationship pr where pr.type_id = 1150
	and pr.object_project_id = studyid
	order by effectid desc;

	
end if;
end$$

drop procedure if exists `getListSteffect`$$

CREATE PROCEDURE `getListSteffect`(IN studyid int)
begin
	select pr.subject_project_id as effectid, pr.object_project_id as studyid, "" as effectname
	from project_relationship pr where pr.type_id = 1150
	and pr.object_project_id = studyid;

end$$

drop procedure if exists addSteffect$$

CREATE PROCEDURE addSteffect(
IN v_effectid int,
IN v_studyid int,
IN v_effectname varchar(255))
begin

DECLARE v_project_relationship_id int;
DECLARE v_projectprop_id int;

-- START TRANSACTION;

CALL getNextMinReturn('project',v_effectid);


-- PROJECT unique constraint | NAME
IF NOT EXISTS (SELECT 1 FROM project WHERE name=v_effectname) THEN
  INSERT INTO project(project_id,name,description)
  VALUES(v_effectid,v_effectname,v_effectname);
END IF;

CALL getNextMinReturn('project_relationship',v_project_relationship_id);

-- PROJECT_RELATIONSHIP unique constraint | SUBJECT_PROJECT_ID, OBJECT_PROJECT_ID, TYPE_ID
IF NOT EXISTS (SELECT 1 FROM project_relationship WHERE subject_project_id=v_effectid AND object_project_id=v_studyid AND type_id=1150) THEN
  INSERT INTO project_relationship(project_relationship_id,type_id,object_project_id,subject_project_id)
  VALUE(v_project_relationship_id,1150,v_studyid,v_effectid);
END IF;

CALL getNextMinReturn('projectprop',v_projectprop_id);

-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_effectid AND type_id=1016 AND rank=1) THEN
  INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
  VALUES(v_projectprop_id,v_effectid,1016,'DATASET',1);
END IF;

SET v_projectprop_id := v_projectprop_id - 1;

-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_effectid AND type_id=1060 AND rank=1) THEN
  INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
  VALUES(v_projectprop_id,v_effectid,1060,'DATASET NAME',1);
END IF;

SET v_projectprop_id := v_projectprop_id - 1;

-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_effectid AND type_id=1070 AND rank=1) THEN
  INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
  VALUES(v_projectprop_id,v_effectid,1070,'8150',1);
END IF;

SET v_projectprop_id := v_projectprop_id - 1;

-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_effectid AND type_id=1016 AND rank=2) THEN
  INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
  VALUES(v_projectprop_id,v_effectid,1016,'DATASET TITLE',2);
END IF;

SET v_projectprop_id := v_projectprop_id - 1;

-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_effectid AND type_id=1060 AND rank=2) THEN
  INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
  VALUES(v_projectprop_id,v_effectid,1060,'DATASET TITLE',2);
END IF;

SET v_projectprop_id := v_projectprop_id - 1;

-- PROJECTPROP unique constraint | PROJECT_ID, TYPE_ID, RANK
IF NOT EXISTS (SELECT 1 FROM projectprop WHERE project_id=v_effectid AND type_id=1070 AND rank=2) THEN
  INSERT INTO projectprop(projectprop_id,project_id,type_id,value,rank)
  VALUES(v_projectprop_id,v_effectid,1070,'8155',2);
END IF;

-- COMMIT;

SELECT v_effectid;

end$$

delimiter ;