DELIMITER $$

DROP PROCEDURE IF EXISTS `getScaleDisByMeasuredinId`$$

CREATE PROCEDURE `getScaleDisByMeasuredinId`(IN p_measuredinid int)

BEGIN

--  SELECT 
--    obj.cvterm_id AS tmsscaledisid
--    , cvr.subject_id AS measuredinid
--    , obj.name AS valuename
--    , obj.definition AS valuedesc
--  FROM
--    cvterm obj
--    JOIN cvterm_relationship cvr ON cvr.type_id = 1190 AND cvr.object_id = obj.cvterm_id
--    WHERE cvr.subject_id = p_measuredinid
--  ;

  SELECT 
    obj.cvterm_id AS tmsscaledisid
    , cv.name AS measuredinid
    , obj.name AS value
    , obj.definition AS valdesc
  FROM
    cvterm obj
    INNER JOIN cv ON cv.cv_id = obj.cv_id
  WHERE
    cv.name = p_measuredinid
  ;


END$$

DELIMITER ;
