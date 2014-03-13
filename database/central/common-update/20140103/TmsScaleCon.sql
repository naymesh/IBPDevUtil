DELIMITER $$

DROP PROCEDURE IF EXISTS `getScaleConByMeasuredinId`$$

CREATE PROCEDURE `getScaleConByMeasuredinId`(IN p_measuredinid int)

BEGIN

  SELECT 
    min.cvtermprop_id AS tmsscaleconid
    , min.cvterm_id AS measuredinid
    , min.value AS slevel
    , max.value AS elevel
  FROM
    cvtermprop min
    INNER JOIN cvtermprop max ON max.cvterm_id = min.cvterm_id AND max.type_id = 1115
    WHERE min.type_id = 1113 AND min.cvterm_id = p_measuredinid
  ;

END$$

DELIMITER ;
