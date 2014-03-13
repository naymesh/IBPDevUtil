DELIMITER $$

DROP PROCEDURE IF EXISTS `getLevelsByLabelId`$$

CREATE PROCEDURE `getLevelsByLabelId`(IN p_labelid int, IN isnumeric int, IN iscentral int, IN p_factorid INT, IN p_storedin INT)
BEGIN
IF iscentral = 1 THEN

    IF (p_storedin = 1010 or p_storedin = 1015) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, pp.project_id AS levelno, 
               IF (p.value IS NULL, IF (isnumeric, '0', '') , p.value) AS lvalue, p_storedin AS storedinid
          FROM projectprop pp
         INNER JOIN projectprop p ON p.project_id = pp.project_id AND p.rank = pp.rank AND p.type_id = pp.value
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno ASC;
       
    ELSEIF (p_storedin IN (1011, 1012, 1016, 1017)) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, pp.project_id AS levelno, 
               CASE p_storedin
                    WHEN 1011 THEN (p.name)
                    WHEN 1012 THEN (p.description)
                    WHEN 1016 THEN (p.name)
                    WHEN 1017 THEN (p.description)
               END as lvalue, p_storedin AS storedinid
          FROM project p
         INNER JOIN projectprop pp ON pp.project_id = p.project_id
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno ASC;

    
    ELSEIF (p_storedin IN (1020, 1021, 1022, 1023, 1024, 1025)) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, g.nd_geolocation_id AS levelno, 
               CASE p_storedin
                    WHEN 1020 THEN (IF(gp.value IS NULL, IF (isnumeric, '0', ''), gp.value))
                    WHEN 1021 THEN (g.description)
                    WHEN 1022 THEN (IF(g.latitude IS NULL, IF (isnumeric, '0', ''), g.latitude))
                    WHEN 1023 THEN (IF(g.longitude IS NULL, IF (isnumeric, '0', ''), g.longitude))
                    WHEN 1024 THEN (g.geodetic_datum)
                    WHEN 1025 THEN (IF(g.altitude IS NULL, IF (isnumeric, '0', ''), g.altitude))
               END as lvalue, p_storedin AS storedinid
          FROM projectprop pp
         INNER JOIN nd_experiment_project ep ON ep.project_id = pp.project_id
         INNER JOIN nd_experiment e ON e.nd_experiment_id = ep.nd_experiment_id
         INNER JOIN nd_geolocation g ON g.nd_geolocation_id = e.nd_geolocation_id
          LEFT JOIN nd_geolocationprop gp ON gp.nd_geolocation_id = g.nd_geolocation_id AND gp.type_id = pp.value        
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno ASC;

    ELSEIF (p_storedin = 1030) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, ep.nd_experiment_id AS levelno, 
               IF(e.value IS NULL, IF (isnumeric, '0', ''), e.value) AS lvalue, p_storedin AS storedinid
          FROM nd_experimentprop e
         INNER JOIN nd_experiment_project ep ON ep.nd_experiment_id = e.nd_experiment_id
         INNER JOIN projectprop pp ON pp.project_id = ep.project_id
         WHERE pp.projectprop_id = p_labelid AND e.type_id = pp.value
         ORDER BY levelno ASC;

    ELSEIF (p_storedin IN (1040, 1041, 1042, 1046, 1047)) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, s.stock_id AS levelno, 
               CASE p_storedin
                    WHEN 1040 THEN (IF(sP.value IS NULL, IF (isnumeric, '0', ''), sp.value))
                    WHEN 1041 THEN (s.uniquename)
                    WHEN 1042 THEN (IF(s.dbxref_id IS NULL, IF (isnumeric, '0', ''), s.dbxref_id))
                    WHEN 1046 THEN (s.name)
                    WHEN 1047 THEN (IF(s.value IS NULL, IF (isnumeric, '0', ''), s.value))
               END as lvalue, p_storedin AS storedinid
          FROM projectprop pp 
         INNER JOIN nd_experiment_project ep ON ep.project_id = pp.project_id
         INNER JOIN nd_experiment_stock es ON es.nd_experiment_id = ep.nd_experiment_id
         INNER JOIN stock s ON s.stock_id = es.stock_id
          LEFT JOIN stockprop sp ON sp.stock_id = s.stock_id AND sp.type_id = pp.value
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno ASC;
    END IF;

    
    

ELSE

    IF (p_storedin = 1010 or p_storedin = 1015) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, pp.project_id AS levelno, 
               IF (p.value IS NULL, IF (isnumeric, '0', '') , p.value) AS lvalue, p_storedin AS storedinid
          FROM projectprop pp
         INNER JOIN projectprop p ON p.project_id = pp.project_id AND p.rank = pp.rank AND p.type_id = pp.value
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno DESC;
       
    ELSEIF (p_storedin IN (1011, 1012, 1016, 1017)) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, pp.project_id AS levelno, 
               CASE p_storedin
                    WHEN 1011 THEN (p.name)
                    WHEN 1012 THEN (p.description)
                    WHEN 1016 THEN (p.name)
                    WHEN 1017 THEN (p.description)
               END as lvalue, p_storedin AS storedinid
          FROM project p
         INNER JOIN projectprop pp ON pp.project_id = p.project_id
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno DESC;

    
    ELSEIF (p_storedin IN (1020, 1021, 1022, 1023, 1024, 1025)) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, g.nd_geolocation_id AS levelno, 
               CASE p_storedin
                    WHEN 1020 THEN (IF(gp.value IS NULL, IF (isnumeric, '0', ''), gp.value))
                    WHEN 1021 THEN (g.description)
                    WHEN 1022 THEN (IF(g.latitude IS NULL, IF (isnumeric, '0', ''), g.latitude))
                    WHEN 1023 THEN (IF(g.longitude IS NULL, IF (isnumeric, '0', ''), g.longitude))
                    WHEN 1024 THEN (g.geodetic_datum)
                    WHEN 1025 THEN (IF(g.altitude IS NULL, IF (isnumeric, '0', ''), g.altitude))
               END as lvalue, p_storedin AS storedinid
          FROM projectprop pp
         INNER JOIN nd_experiment_project ep ON ep.project_id = pp.project_id
         INNER JOIN nd_experiment e ON e.nd_experiment_id = ep.nd_experiment_id
         INNER JOIN nd_geolocation g ON g.nd_geolocation_id = e.nd_geolocation_id
          LEFT JOIN nd_geolocationprop gp ON gp.nd_geolocation_id = g.nd_geolocation_id AND gp.type_id = pp.value        
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno DESC;

    ELSEIF (p_storedin = 1030) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, ep.nd_experiment_id AS levelno, 
               IF(e.value IS NULL, IF (isnumeric, '0', ''), e.value) AS lvalue, p_storedin AS storedinid
          FROM nd_experimentprop e
         INNER JOIN nd_experiment_project ep ON ep.nd_experiment_id = e.nd_experiment_id
         INNER JOIN projectprop pp ON pp.project_id = ep.project_id
         WHERE pp.projectprop_id = p_labelid AND e.type_id = pp.value
         ORDER BY levelno DESC;

    ELSEIF (p_storedin IN (1040, 1041, 1042, 1046, 1047)) THEN
        SELECT DISTINCT p_labelid AS labelid, p_factorid AS factorid, s.stock_id AS levelno, 
               CASE p_storedin
                    WHEN 1040 THEN (IF(sP.value IS NULL, IF (isnumeric, '0', ''), sp.value))
                    WHEN 1041 THEN (s.uniquename)
                    WHEN 1042 THEN (IF(s.dbxref_id IS NULL, IF (isnumeric, '0', ''), s.dbxref_id))
                    WHEN 1046 THEN (s.name)
                    WHEN 1047 THEN (IF(s.value IS NULL, IF (isnumeric, '0', ''), s.value))
               END as lvalue, p_storedin AS storedinid
          FROM projectprop pp 
         INNER JOIN nd_experiment_project ep ON ep.project_id = pp.project_id
         INNER JOIN nd_experiment_stock es ON es.nd_experiment_id = ep.nd_experiment_id
         INNER JOIN stock s ON s.stock_id = es.stock_id
          LEFT JOIN stockprop sp ON sp.stock_id = s.stock_id AND sp.type_id = pp.value
         WHERE pp.projectprop_id = p_labelid
         ORDER by levelno DESC;
    END IF;


END IF;
END$$


DROP PROCEDURE IF EXISTS `searchLevels`$$

CREATE PROCEDURE `searchLevels`(
  IN labelid int
  , IN levelno int
  , IN factorid int
  , IN lvalue1 double
  , IN lvalue2 varchar(255)
  , IN isnumeric int
  , IN iscentral int)

BEGIN

  SET @sql := CONCAT("SELECT DISTINCT storedinid AS storedinid, labelid AS labelid, factorid, levelno AS levelno, IF (lvalue IS NULL, IF (", isnumeric, ", '0', '') , lvalue) AS lvalue from v_level ");

  IF isnumeric = 1 THEN
    SET @sql = CONCAT(@sql, " WHERE dtypeid NOT IN (1120, 1125, 1128, 1130) ");
  ELSE
    SET @sql = CONCAT(@sql, " WHERE dtypeid IN (1120, 1125, 1128, 1130) ");
  END IF;

  IF (labelid IS NOT NULL) THEN
    SET @sql = CONCAT(@sql, " AND labelid = ", labelid);
  END IF;

  IF (levelno IS NOT NULL) THEN
    SET @sql = CONCAT(@sql, " AND levelno = ", levelno);
  END IF;

  IF (factorid IS NOT NULL) THEN
    SET @sql = CONCAT(@sql, " AND factorid = ", factorid);
  END IF;
  
  IF (lvalue1 IS NOT NULL) THEN
    SET @sql = CONCAT(@sql, " AND lvalue = ", lvalue1);
  END IF;

  IF (lvalue2 IS NOT NULL) THEN
    SET @sql = CONCAT(@sql, " AND lvalue = ", lvalue2);
  END IF;

  IF iscentral = 1 THEN
    SET @sql = CONCAT(@sql, " ORDER BY labelid, levelno ASC");
  ELSE
    SET @sql = CONCAT(@sql, " ORDER BY labelid, levelno DESC");
  END IF;

  PREPARE stmt FROM @sql;
  EXECUTE stmt;


END$$

DROP PROCEDURE IF EXISTS `addLevelsForFactor`$$

CREATE PROCEDURE `addLevelsForFactor`(
  IN p_labelid int
  , IN p_storedin int
  , IN p_values MEDIUMTEXT
  , IN p_levelno int)

BEGIN

    DECLARE stdvarid INT;
    SELECT value INTO stdvarid FROM projectprop WHERE projectprop_id = p_labelid;
  
 
    IF (p_storedin = 1030) THEN
        select IF(nd_experimentprop_id is NULL or min(nd_experimentprop_id) >= 0, -1, min(nd_experimentprop_id) -1)  
        INTO @newexpid 
        from nd_experimentprop;

        CALL split(@newexpid, p_levelno, p_values, '$%^');

        insert into nd_experimentprop (nd_experimentprop_id, nd_experiment_id, type_id, value, rank) 
        select id, levelno, stdvarid, `value`, 0
        FROM temptbl;

    ELSEIF (p_storedin = 1040) THEN
        select IF(stockprop_id is NULL or min(stockprop_id) >= 0, -1, min(stockprop_id) -1)  
        INTO @newexpid 
        from stockprop;

        CALL split(@newexpid, p_levelno, p_values, '$%^');

        insert into stockprop (stockprop_id, stock_id, type_id, value, rank) 
        select id, levelno, stdvarid, `value`, 0
        FROM temptbl;
    END IF;



END$$

DELIMITER ;
