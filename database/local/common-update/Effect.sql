delimiter $$

drop procedure if exists `getAllEffects`$$

CREATE PROCEDURE `getAllEffects`()
begin

select distinct * from (
SELECT 
        prop.project_id AS represNo,
        CASE
               WHEN cvr.object_id IN (1010, 1011, 1012) AND factor.value = '8005' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1015, 1016, 1017) AND factor.value = '8150' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1040, 1041, 1042, 1046, 1047) AND factor.value = '8230' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1020, 1021, 1022, 1023, 1024, 1025) AND factor.value = '8170' THEN factor.projectprop_id
               WHEN cvr.object_id = 1030 AND factor.value IN ('8200', '8380') THEN factor.projectprop_id
             END
          AS factorid,
        prop.project_id as effectId
     FROM projectprop prop
      INNER JOIN cvterm_relationship cvr ON cvr.subject_id = prop.value and cvr.type_id = 1044
      INNER JOIN project_relationship pr ON prop.project_id = pr.subject_project_id and pr.type_id = 1150
      LEFT JOIN projectprop factor ON factor.project_id = prop.project_id AND factor.type_id = 1070 
        AND factor.value in ('8005', '8150', '8230', '8170', '8200', '8380')
       WHERE prop.type_id = 1070) as a
where factorid is not null;
end$$

delimiter $$
drop procedure if exists getTotalEffectsByEffect$$

CREATE PROCEDURE getTotalEffectsByEffect(IN represNo int, IN factorId int, IN effectId int)
BEGIN
  SET @myQuery = 'select count(distinct *) as effectCount from(
  SELECT
        prop.project_id AS represNo,
        CASE
               WHEN cvr.object_id IN (1010, 1011, 1012) AND factor.value = \'8005\' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1015, 1016, 1017) AND factor.value = \'8150\' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1040, 1041, 1042, 1046, 1047) AND factor.value = \'8230\' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1020, 1021, 1022, 1023, 1024, 1025) AND factor.value = \'8170\' THEN factor.projectprop_id
               WHEN cvr.object_id = 1030 AND factor.value IN (\'8200\', \'8380\') THEN factor.projectprop_id
             END
          AS factorid,
        prop.project_id as effectId
     FROM projectprop prop
      INNER JOIN cvterm_relationship cvr ON cvr.subject_id = prop.value and cvr.type_id = 1044
      INNER JOIN project_relationship pr ON prop.project_id = pr.subject_project_id and pr.type_id = 1150
      LEFT JOIN projectprop factor ON factor.project_id = prop.project_id AND factor.type_id = 1070
        AND factor.value in (\'8005\', \'8150\', \'8230\', \'8170\', \'8200\', \'8380\')
       WHERE prop.type_id = 1070) as a
where factorid is not null';


  IF represNo IS NOT NULL THEN
    set @myQuery = CONCAT(@myQuery, ' and represNo = ', quote(represNo));
  END IF;
  IF factorId IS NOT NULL THEN
    set @myQuery = CONCAT(@myQuery, ' and factorId = ', quote(factorId));
  END IF;
  IF effectId IS NOT NULL THEN
    set @myQuery = CONCAT(@myQuery, ' and effectId = ', quote(effectId));
  END IF;

  PREPARE stmt FROM @myQuery;
  EXECUTE stmt;

END $$

delimiter $$

drop procedure if exists `getEffectsByEffectIdList`$$

CREATE PROCEDURE `getEffectsByEffectIdList`(IN idList varchar(200))
  begin

    SET @myQuery = 'select distinct * from (
SELECT
        prop.project_id AS represNo,
        CASE
               WHEN cvr.object_id IN (1010, 1011, 1012) AND factor.value = \'8005\' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1015, 1016, 1017) AND factor.value = \'8150\' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1040, 1041, 1042, 1046, 1047) AND factor.value = \'8230\' THEN factor.projectprop_id
               WHEN cvr.object_id IN (1020, 1021, 1022, 1023, 1024, 1025) AND factor.value = \'8170\' THEN factor.projectprop_id
               WHEN cvr.object_id = 1030 AND factor.value IN (\'8200\', \'8380\') THEN factor.projectprop_id
             END
          AS factorid,
        prop.project_id as effectId
     FROM projectprop prop
      INNER JOIN cvterm_relationship cvr ON cvr.subject_id = prop.value and cvr.type_id = 1044
      INNER JOIN project_relationship pr ON prop.project_id = pr.subject_project_id and pr.type_id = 1150
      LEFT JOIN projectprop factor ON factor.project_id = prop.project_id AND factor.type_id = 1070
        AND factor.value in (\'8005\', \'8150\', \'8230\', \'8170\', \'8200\', \'8380\')
       WHERE prop.type_id = 1070) as a where factorid is not null';

    IF (idList IS NOT NULL) THEN
      SET @myQuery = CONCAT(@myQuery, ' AND represNo in (', idList, ')');
    END IF;

    PREPARE stmt FROM @myQuery;
    EXECUTE stmt;

  end$$
  
  delimiter ;