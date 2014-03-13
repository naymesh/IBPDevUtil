delimiter $$

drop procedure if exists `getAllReprestn`$$

CREATE PROCEDURE `getAllReprestn`()
begin

select distinct p.project_id as represno,
p.project_id as effectid,
p.name as represname
from project p
inner join project_relationship pr on pr.subject_project_id = p.project_id and pr.type_id = 1150
order by p.name;
end$$

delimiter $$

drop procedure if exists `getReprestnForStudyId`$$

CREATE PROCEDURE `getReprestnForStudyId`(IN studyId int, IN represname varchar(255))
begin

SET @myQuery = 'select distinct proj.project_id as represno, proj.name as represname, proj.project_id as effectid FROM
project proj INNER JOIN project_relationship pr ON proj.project_id = pr.subject_project_id AND pr.type_id = 1150';

if (studyId IS NOT NULL AND studyId <> 0) THEN
  SET @myQuery = CONCAT(@myQuery, ' WHERE pr.object_project_id = ', studyId);
END IF;

IF (represname IS NOT NULL) THEN
  IF (studyId IS NULL) THEN
    SET @myQuery = CONCAT(@myQuery, ' WHERE ');
  ELSE
    SET @myQuery = CONCAT(@myQuery, ' AND ');
  END IF;

  SET @myQuery = CONCAT(@myQuery, ' proj.name =  ', quote(represname));
END IF;

  PREPARE stmt FROM @myQuery;
  EXECUTE stmt;
END$$

delimiter $$

drop procedure if exists `getReprestnForReprestn`$$

CREATE PROCEDURE `getReprestnForReprestn`(IN represno int, IN represname varchar(255), IN effectid int)
  begin

    SET @myQuery = 'select distinct proj.project_id as represno, proj.name as represname, proj.project_id as effectid FROM
project proj INNER JOIN project_relationship pr ON proj.project_id = pr.subject_project_id AND pr.type_id = 1150';

    if (represno IS NOT NULL AND represno <> 0) THEN
      SET @myQuery = CONCAT(@myQuery, ' WHERE proj.project_id = ', represno);
      SET @varExists = true;
    END IF;

    IF (represname IS NOT NULL) THEN
      IF (@varExists IS NOT NULL and @varExists = true) THEN
        SET @myQuery = CONCAT(@myQuery, ' AND');
      ELSE
        SET @myQuery = CONCAT(@myQuery, ' WHERE');
        SET @varExists = true;
      END IF;
      SET @myQuery = CONCAT(@myQuery, ' proj.name =  ', quote(represname));
    END IF;

    IF (effectId IS NOT NULL and effectid <> 0) THEN
      IF (@varExists IS NOT NULL and @varExists = true) THEN
        SET @myQuery = CONCAT(@myQuery, ' AND');
      ELSE
        SET @myQuery = CONCAT(@myQuery, ' WHERE');
      END IF;
      SET @myQuery = CONCAT(@myQuery, ' proj.project_id = ', effectid);
    END IF;

    PREPARE stmt FROM @myQuery;
    EXECUTE stmt;
  END$$

delimiter ;