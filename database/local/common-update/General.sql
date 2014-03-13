delimiter $$

drop procedure if exists `getNextMin`$$

CREATE PROCEDURE `getNextMin`(
IN tableName varchar(255))
begin

SET @sql := CONCAT("select IF(min(",tableName,"_id) is NULL or min(",tableName,"_id) >= 0, -1, min(",tableName,"_id) -1)  as id from ",tableName);
PREPARE stmt FROM @sql;
	EXECUTE stmt;
	
end$$

drop procedure if exists `getNextMinReturn`$$

CREATE PROCEDURE `getNextMinReturn`(
IN tableName varchar(255), OUT idnew INT)
begin
set @c1 = 0;

SET @sql := CONCAT("select IF(min(",tableName,"_id) is NULL or min(",tableName,"_id) >= 0, -1, min(",tableName,"_id) -1)  into @c1 from ",tableName);
PREPARE stmt FROM @sql;
	EXECUTE stmt;
set idnew = @c1; 	
	
end$$


drop procedure if exists `addCvterm`$$

CREATE PROCEDURE `addCvterm`(IN cvidin int, IN cvname varchar(200), IN cvdesc varchar(255))
begin

	call getNextMinReturn('cvterm', @newcvtermid);

	-- CVTERM unique contraint | NAME, CV_ID, IS_OBSOLETE
	IF NOT EXISTS (SELECT 1 FROM cvterm WHERE name=cvname AND cv_id=cvidin AND is_obsolete=0) THEN
		insert into cvterm (cvterm_id, cv_id, name, definition, dbxref_id, is_obsolete, is_relationshiptype) value (@newcvtermid, cvidin, cvname, cvdesc, NULL, 0, 0);
	END IF;

end$$

drop procedure if exists `addCvtermWithID`$$

CREATE PROCEDURE `addCvtermWithID`(IN cvterm_id_v INT, IN cvidin int, IN cvname varchar(200), IN cvdesc varchar(255))
begin
	
	-- CVTERM unique contraint | NAME, CV_ID, IS_OBSOLETE
	IF NOT EXISTS (SELECT 1 FROM cvterm WHERE name=cvname AND cv_id=cvidin AND is_obsolete=0) THEN
		insert into cvterm (cvterm_id, cv_id, name, definition, dbxref_id, is_obsolete, is_relationshiptype) value (cvterm_id_v, cvidin, cvname, cvdesc, NULL, 0, 0);
	END IF;

end$$

drop procedure if exists `addCvtermReturnId`$$

CREATE PROCEDURE `addCvtermReturnId`(IN cvidin int, IN cvname varchar(200), IN cvdesc varchar(255), OUT newcvtermidret INT)
begin

	call getNextMinReturn('cvterm', @newcvtermid);
	-- CVTERM unique contraint | NAME, CV_ID, IS_OBSOLETE
	IF NOT EXISTS (SELECT 1 FROM cvterm WHERE name=cvname AND cv_id=cvidin AND is_obsolete=0) THEN
		insert into cvterm (cvterm_id, cv_id, name, definition, dbxref_id, is_obsolete, is_relationshiptype) value (@newcvtermid, cvidin, cvname, cvdesc, NULL, 0, 0);
	ELSE
		SELECT cvterm_id INTO @newcvtermid FROM cvterm  WHERE name=cvname AND cv_id=cvidin AND is_obsolete=0;
	END IF;

	set newcvtermidret = @newcvtermid; 

end$$

drop procedure if exists `addCvtermRelationship`$$

CREATE PROCEDURE `addCvtermRelationship`(IN typeid int, IN subjectid int, IN objectid int)
begin

	call getNextMinReturn('cvterm_relationship', @newcvtermrelationshipid);
	-- CVTERM_RELATIONSHIP unique constraint | OBJECT_ID, SUBJECT_ID, TYPE_ID
	IF NOT EXISTS (SELECT 1 FROM cvterm_relationship WHERE object_id=objectid AND subject_id=subjectid AND type_id=typeid) THEN
		insert into cvterm_relationship (cvterm_relationship_id, type_id, subject_id, object_id) value (@newcvtermrelationshipid, typeid, subjectid, objectid);
	END IF;


end$$


drop procedure if exists `updateCvterm`$$

CREATE PROCEDURE `updateCvterm`(IN cvtermid int, IN cvname varchar(200), IN cvdesc varchar(255))
begin

	update cvterm
	set name = cvname,
	definition = cvdesc
	where cvterm_id = cvtermid;


end$$

drop procedure if exists `addNdGeolocation`$$

CREATE PROCEDURE `addNdGeolocation`(IN nd_geolocation_id_v int, IN description_v varchar(255))
begin

/* nd_geolocation_id 	description 	latitude 	longitude 	geodetic_datum 	altitude */
insert into  nd_geolocation (nd_geolocation_id, description, latitude, longitude, geodetic_datum, altitude) value (nd_geolocation_id_v, description_v,NULL,NULL,'',NULL);

end$$

drop procedure if exists `addNdExperimentStock`$$

CREATE PROCEDURE `addNdExperimentStock`(IN nd_experiment_stock_id_v int, IN nd_experiment_id_v int, IN stock_id_v int)
begin

/* nd_geolocation_id 	description 	latitude 	longitude 	geodetic_datum 	altitude */
insert into  nd_experiment_stock (nd_experiment_stock_id,nd_experiment_id,stock_id,type_id) value (nd_experiment_stock_id_v, nd_experiment_id_v, stock_id_v, 1000);

end$$

drop procedure if exists `addStock`$$

CREATE PROCEDURE `addStock`(
IN stock_id_in int,
IN v_uniquename varchar(255),
IN dbxref_id varchar(255),
IN name varchar(255),
IN value varchar(255))
begin

-- STOCK unique constraint | ORGANISM_ID, UNIQUENAME, TYPE_ID
-- IF NOT EXISTS (SELECT 1 FROM stock WHERE organism_id IS NULL AND uniquename=v_uniquename AND type_id=8230) THEN
	insert into stock (stock_id, type_id, uniquename, dbxref_id, name, value, is_obsolete) 
	value (stock_id_in, 8230, v_uniquename, dbxref_id, name, value, 0);
-- END IF;

end$$

DROP PROCEDURE if exists addStocks$$
CREATE PROCEDURE `addStocks`(
  IN p_stockId int,
  IN p_uniquenames MEDIUMTEXT, 
  IN p_dbxrefs MEDIUMTEXT,
  IN p_names MEDIUMTEXT,
  IN p_values MEDIUMTEXT)
BEGIN
  declare i, current_pos1, next_pos1, current_pos2, next_pos2, current_pos3, next_pos3, current_pos4, next_pos4 int default 1;
  declare auniquename, adbxref, aname, avalue varchar(2000);
  declare done boolean default false;
  
  drop temporary table if exists temptbl;
  create temporary table temptbl (stock_id int, dbxref_id varchar(255), name varchar(255), uniquename varchar(255), 
                                  `value` varchar(255), type_id int, is_obsolete int);


  myloop: LOOP

    set next_pos1 = locate('$%^', p_uniquenames, current_pos1);
    set next_pos2 = locate('$%^', p_dbxrefs, current_pos2);
    set next_pos3 = locate('$%^', p_names, current_pos3);
    set next_pos4 = locate('$%^', p_values, current_pos4);

    -- uniquename is the only required field in stock. 
    -- So assumes there's always a delimited string of uniquenames.
    if (next_pos1 = 0) then
        SET next_pos1 = length(p_uniquenames) + 1;
        SET next_pos2 = length(p_dbxrefs) + 1;
        SET next_pos3 = length(p_names) + 1;
        SET next_pos4 = length(p_values) + 1;
        SET done = true;
    end if;

    set auniquename = (select substring(p_uniquenames,current_pos1, next_pos1-current_pos1));
    set adbxref = (select substring(p_dbxrefs,current_pos2, next_pos2-current_pos2));
    set aname = (select substring(p_names,current_pos3, next_pos3-current_pos3));
    set avalue = (select substring(p_values,current_pos4, next_pos4-current_pos4));

    insert into temptbl(stock_id, dbxref_id, name, uniquename, value, type_id, is_obsolete) 
    values(
        p_stockId, 
        IF (adbxref ='', NULL, adbxref), 
        IF (aname ='', NULL, aname),
        auniquename, 
        IF (avalue ='', NULL, avalue),
        8230, 0);
    set p_stockId = p_stockId - 1;
    
    IF (done) THEN
        LEAVE myloop;
    END IF;

    set current_pos1 = next_pos1+length('$%^');
    set current_pos2 = next_pos2+length('$%^');
    set current_pos3 = next_pos3+length('$%^');
    set current_pos4 = next_pos4+length('$%^');

  end LOOP;

  insert into stock(stock_id, dbxref_id, name, uniquename, value, type_id, is_obsolete) 
  select stock_id, dbxref_id, name, uniquename, value, type_id, is_obsolete from temptbl;

END$$

DROP PROCEDURE if exists addPhenotypicData$$
CREATE PROCEDURE `addPhenotypicData`(
  IN p_experiments LONGTEXT, 
  IN p_variates LONGTEXT,
  IN p_values LONGTEXT,
  IN p_cvalueIds LONGTEXT)
BEGIN
  declare i, current_pos1, next_pos1, current_pos2, next_pos2, current_pos3, next_pos3, current_pos4, next_pos4, phenotypeId, expPhenotypeId int default 1;
  declare aexperiment, avariate, avalue, v_cvalue_id varchar(2000);
  declare done boolean default false;
  
  drop temporary table if exists temptbl;
  create temporary table temptbl ( 
    `phenotype_id` int(11),
    `uniquename` varchar(255),
    `name` varchar(255),
    `observable_id` int(11),
    `attr_id` int(11),
    `value` varchar(255),
    `cvalue_id` int(11),
    `assay_id` int(11),
    `nd_experiment_phenotype_id` int(11),
    `nd_experiment_id` int(11));

  call getNextMinReturn('phenotype', phenotypeId);
  call getNextMinReturn('nd_experiment_phenotype', expPhenotypeId);

  myloop: LOOP

    set next_pos1 = locate('$%^', p_experiments, current_pos1);
    set next_pos2 = locate('$%^', p_variates, current_pos2);
    set next_pos3 = locate('$%^', p_values, current_pos3);
    set next_pos4 = locate('$%^', p_cvalueIds, current_pos4);

    -- uniquename is the only required field in stock. 
    -- So assumes there's always a delimited string of uniquenames.
    if (next_pos1 = 0) then
        SET next_pos1 = length(p_experiments) + 1;
        SET next_pos2 = length(p_variates) + 1;
        SET next_pos3 = length(p_values) + 1;
        SET next_pos4 = length(p_cvalueIds) + 1;
        SET done = true;
    end if;

    set aexperiment = (select substring(p_experiments,current_pos1, next_pos1-current_pos1));
    set avariate = (select substring(p_variates,current_pos2, next_pos2-current_pos2));
    set avalue = (select substring(p_values,current_pos3, next_pos3-current_pos3));
    set v_cvalue_id = (select substring(p_cvalueIds,current_pos4, next_pos4-current_pos4));

    -- select cvterm_id into v_cvalue_id 
    -- from cvterm ct
    -- inner join cvterm_relationship cr ON cr.object_id = ct.cvterm_id AND cr.type_id = 1190 AND cr.subject_id = avariate
    -- inner join cvterm_relationship cs ON cs.subject_id = cr.subject_id AND cs.type_id = 1044 and cs.object_id = 1048
    -- where ct.name =  avalue;

    insert into temptbl(phenotype_id, uniquename, `name`, observable_id, attr_id, `value`, cvalue_id, assay_id, nd_experiment_phenotype_id, nd_experiment_id) 
    values(
        phenotypeId
        , phenotypeId
        , avariate
        , avariate
        , NULL
        , avalue
        , if (v_cvalue_id = 'null' or v_cvalue_id = 'NULL' or v_cvalue_id = '' or v_cvalue_id = 0, null, v_cvalue_id)
        , NULL
        , expPhenotypeId
        , aexperiment
    );
    set phenotypeId = phenotypeId - 1;
    set expPhenotypeId = expPhenotypeId - 1;
    
    IF (done) THEN
        LEAVE myloop;
    END IF;

    set current_pos1 = next_pos1+length('$%^');
    set current_pos2 = next_pos2+length('$%^');
    set current_pos3 = next_pos3+length('$%^');
    set current_pos4 = next_pos4+length('$%^');

  end LOOP;

  insert into phenotype(phenotype_id, uniquename, `name`, observable_id, attr_id, `value`, cvalue_id, assay_id) 
  select phenotype_id, uniquename, `name`, observable_id, attr_id, `value`, cvalue_id, assay_id from temptbl;

  insert into nd_experiment_phenotype(nd_experiment_phenotype_id, nd_experiment_id, phenotype_id)
  select nd_experiment_phenotype_id, nd_experiment_id, phenotype_id from temptbl;

END$$

drop procedure if exists `addNdExperiment`$$

CREATE PROCEDURE `addNdExperiment`(IN nd_experimentid_id_v int, IN nd_geolocation_id_v int, IN type_id_v INT)
begin

insert into   nd_experiment (nd_experiment_id,nd_geolocation_id,type_id) value (nd_experimentid_id_v, nd_geolocation_id_v, type_id_v);


end$$

drop procedure if exists `addExperiments`$$

CREATE PROCEDURE `addExperiments`(IN p_first_id int, IN p_geolocation_ids MEDIUMTEXT)
begin

  CALL split(p_first_id, p_first_id, p_geolocation_ids, '$%^');
  
  insert into nd_experiment (nd_experiment_id,nd_geolocation_id,type_id) 
  select id, `value`, 1155 from temptbl;


end$$

drop procedure if exists `addExperimentStocks`$$

CREATE PROCEDURE `addExperimentStocks`(IN p_first_id int, IN p_experiment_id int, IN p_stock_ids MEDIUMTEXT)
begin

  CALL split(p_first_id, p_experiment_id, p_stock_ids, '$%^');
  
  insert into nd_experiment_stock (nd_experiment_stock_id, nd_experiment_id, type_id, stock_id) 
  select id, levelno, 1000, `value` from temptbl;


end$$

drop procedure if exists `addExperimentProjects`$$

CREATE PROCEDURE `addExperimentProjects`(IN p_first_id int, IN p_project_id int, IN p_experiment_ids MEDIUMTEXT)
begin

  CALL split(p_first_id, p_first_id, p_experiment_ids, '$%^');
  
  insert into nd_experiment_project (nd_experiment_project_id, project_id, nd_experiment_id) 
  select id, p_project_id, `value` from temptbl;


end$$


DROP VIEW IF EXISTS `v_factor`$$
CREATE VIEW v_factor (projectprop_id, project_id, rank, varid, factorid, storedinid, traitid, dtypeid)
AS
SELECT 
    prop.projectprop_id AS projectprop_id
    , prop.project_id AS project_id
    , prop.rank AS rank
    , prop.value AS varid
     , GROUP_CONCAT(
         CASE
           WHEN stinrel.object_id = 1047 AND mfactors.value = '8230' THEN mfactors.projectprop_id
           WHEN stinrel.object_id IN (1010, 1011, 1012) AND mfactors.value = '8005' THEN mfactors.projectprop_id
           WHEN stinrel.object_id IN (1015, 1016, 1017) AND mfactors.value = '8150' THEN mfactors.projectprop_id
           WHEN stinrel.object_id IN (1040, 1041, 1042, 1046, 1047) AND mfactors.value = '8230' THEN mfactors.projectprop_id
           WHEN stinrel.object_id IN (1020, 1021, 1022, 1023, 1024, 1025) AND mfactors.value = '8170' THEN mfactors.projectprop_id
           WHEN stinrel.object_id = 1030 AND mfactors.value IN ('8200', '8380') THEN mfactors.projectprop_id
         END
      ) AS factorid
    , stinrel.object_id AS storedinid
    , traitrel.object_id AS traitid
    , dtyperel.object_id AS dtypeid
  FROM projectprop prop
  INNER JOIN cvterm_relationship stinrel ON stinrel.subject_id = prop.value and stinrel.type_id = 1044
  INNER JOIN cvterm_relationship traitrel on traitrel.subject_id = prop.value and traitrel.type_id = 1200
  INNER JOIN cvterm_relationship dtyperel ON dtyperel.subject_id = prop.value AND dtyperel.type_id = 1105
  LEFT JOIN projectprop mfactors ON mfactors.project_id = prop.project_id AND mfactors.type_id = 1070 
    AND mfactors.value in ('8005', '8150', '8230', '8170', '8200', '8380')
  WHERE prop.type_id = 1070 
    AND stinrel.object_id NOT IN (1043, 1048)
  GROUP BY prop.projectprop_id
$$

DROP VIEW IF EXISTS `v_level`$$
CREATE VIEW v_level (labelid, factorid, levelno, lvalue, dtypeid, storedinid, nd_experiment_id)
AS
SELECT 
stdvar.projectprop_id AS labelId
, stdvar.factorid AS factorId
, CASE
    WHEN stdvar.storedinid IN (1010, 1011, 1012, 1015, 1016, 1017) THEN p.project_id
    WHEN stdvar.storedinid IN (1020, 1021, 1022, 1023, 1024, 1025) THEN geo.nd_geolocation_id
    WHEN stdvar.storedinid = 1030 THEN eprop.nd_experiment_id
    WHEN stdvar.storedinid IN (1040, 1041, 1042, 1046, 1047) THEN stock.stock_id
  END AS levelno
, CASE stdvar.storedinid 
    WHEN 1010 THEN (pval.value)
    WHEN 1011 THEN (p.name)
    WHEN 1012 THEN (p.description)
    WHEN 1015 THEN (pval.value)
    WHEN 1016 THEN (p.name)
    WHEN 1017 THEN (p.description)
    WHEN 1020 THEN (gprop.value)
    WHEN 1021 THEN (geo.description)
    WHEN 1022 THEN (geo.latitude)
    WHEN 1023 THEN (geo.longitude)
    WHEN 1024 THEN (geo.geodetic_datum)
    WHEN 1025 THEN (geo.altitude)
    WHEN 1030 THEN (eprop.value)
    WHEN 1040 THEN (sprop.value)
    WHEN 1041 THEN (stock.uniquename)
    WHEN 1042 THEN (stock.dbxref_id)
    WHEN 1046 THEN (stock.name)
    WHEN 1047 THEN (stock.value)
  END AS lvalue
, stdvar.dtypeid AS dtypeid
, stdvar.storedinid AS storedinid
, exp.nd_experiment_id AS nd_experiment_id
FROM 
v_factor AS stdvar
INNER JOIN project p ON p.project_id = stdvar.project_id
INNER JOIN nd_experiment_project ep ON ep.project_id = p.project_id
INNER JOIN nd_experiment exp ON exp.nd_experiment_id = ep.nd_experiment_id
LEFT JOIN nd_geolocation geo ON geo.nd_geolocation_id = exp.nd_geolocation_id
LEFT JOIN projectprop pval ON pval.type_id = stdvar.varid AND pval.project_id = p.project_id AND pval.rank = stdvar.rank
LEFT JOIN nd_geolocationprop gprop ON gprop.nd_geolocation_id = geo.nd_geolocation_id AND gprop.type_id = stdvar.varid
LEFT JOIN nd_experimentprop eprop ON eprop.nd_experiment_id = exp.nd_experiment_id AND eprop.type_id = stdvar.varid
LEFT JOIN nd_experiment_stock es ON es.nd_experiment_id = exp.nd_experiment_id
LEFT JOIN stock stock ON stock.stock_id = es.stock_id
LEFT JOIN stockprop sprop ON sprop.stock_id = stock.stock_id AND sprop.type_id = stdvar.varid
$$

DROP PROCEDURE IF EXISTS `searchCVTerm`$$

CREATE PROCEDURE `searchCVTerm` (IN cvtermid int, IN cvname varchar(255), IN cvid INT)
  BEGIN

    SET @myQuery = 'select cvterm_id as cvtermid,name as cvname from cvterm';

    SET @myQuery = CONCAT(@myQuery, ' WHERE cv_id = ', cvid);

    IF (cvtermid is not NULL AND cvtermid <> 0) THEN
      SET @myQuery = CONCAT(@myQuery, ' AND (cvterm_id = ', cvtermid);
    END IF;

    IF (cvname IS NOT NULL) THEN
      IF (cvtermid is not NULL AND cvtermid <> 0) THEN
        SET @myQuery = CONCAT(@myQuery, ' OR ');
      ELSE
        SET @myQuery = CONCAT(@myQuery, ' AND (');
      END IF;
      SET @myQuery = CONCAT(@myQuery, 'name like ''%', cvname, '%''');
    END IF;

    SET @myQuery = CONCAT(@myQuery, ') ORDER BY cvterm_id, name');

    PREPARE stmt FROM @myQuery;
    EXECUTE stmt;

  END;
$$

DROP PROCEDURE IF EXISTS `getCVTermByCvid`$$

CREATE PROCEDURE `getCVTermByCvid` (IN cvid INT)
  BEGIN

    SET @myQuery = 'select cvterm_id as cvtermid,name as cvname from cvterm';

    SET @myQuery = CONCAT(@myQuery, ' WHERE cv_id = ', cvid);

    SET @myQuery = CONCAT(@myQuery, ' ORDER BY cvterm_id, name');

    PREPARE stmt FROM @myQuery;
    EXECUTE stmt;

  END;
$$

DROP PROCEDURE IF EXISTS `getStoredInId`$$

CREATE PROCEDURE `getStoredInId`(IN traitid INT, IN scaleid INT, IN methodid INT, IN isVariate INT)
BEGIN

  IF (isVariate = 1) THEN
    SELECT stinrel.object_id AS storedinid
    FROM 
      cvterm_relationship stinrel 
      INNER JOIN cvterm_relationship scalerel ON scalerel.subject_id = stinrel.subject_id AND scalerel.type_id = 1220 
      INNER JOIN cvterm_relationship methodrel ON methodrel.subject_id = stinrel.subject_id AND methodrel.type_id = 1210 
      INNER JOIN cvterm_relationship traitrel ON traitrel.subject_id = stinrel.subject_id AND traitrel.type_id = 1200 
    WHERE stinrel.type_id = 1044
      AND traitrel.object_id = traitid
      AND scalerel.object_id = scaleid
      AND methodrel.object_id = methodid
      AND stinrel.object_id IN (1043, 1048)
    LIMIT 1;
  ELSE
    SELECT stinrel.object_id AS storedinid
    FROM 
      cvterm_relationship stinrel 
      INNER JOIN cvterm_relationship scalerel ON scalerel.subject_id = stinrel.subject_id AND scalerel.type_id = 1220 
      INNER JOIN cvterm_relationship methodrel ON methodrel.subject_id = stinrel.subject_id AND methodrel.type_id = 1210 
      INNER JOIN cvterm_relationship traitrel ON traitrel.subject_id = stinrel.subject_id AND traitrel.type_id = 1200 
    WHERE stinrel.type_id = 1044
      AND traitrel.object_id = traitid
      AND scalerel.object_id = scaleid
      AND methodrel.object_id = methodid
      AND stinrel.object_id NOT IN (1043, 1048)
    LIMIT 1;
  END IF
  ;

END$$

DROP PROCEDURE IF EXISTS `getValidValueIds`$$

CREATE PROCEDURE `getValidValueIds`(IN varId INT)
BEGIN

  SELECT object_id
  FROM 
    cvterm_relationship
  WHERE type_id = 1190
    AND subject_id = varId
  ;

END$$

DROP PROCEDURE IF EXISTS `getNameOfCvTerms`$$

CREATE PROCEDURE `getNameOfCvTerms`(IN varIds VARCHAR(2000))
BEGIN

  SET @sql := CONCAT("SELECT cvterm_id, name ",
  " FROM cvterm ",
  " WHERE cvterm_id IN (", varIds, ")");

PREPARE stmt FROM @sql;
EXECUTE stmt;

END$$

DROP PROCEDURE IF EXISTS `getNumericRange`$$

CREATE PROCEDURE `getNumericRange`(IN varId INT, IN typeId INT)
BEGIN

  SELECT value
  FROM cvtermprop
  WHERE cvterm_id = varId
  AND type_id = typeId;

END$$

DROP PROCEDURE IF EXISTS `getObjectInRelationship`$$

CREATE PROCEDURE `getObjectInRelationship`(IN varId INT, IN typeId INT)
BEGIN

  SELECT object_id
  FROM cvterm_relationship
  WHERE subject_id = varId
  AND type_id = typeId;

END$$

DROP PROCEDURE IF EXISTS `getCvTermIdByName`$$

CREATE PROCEDURE `getCvTermIdByName`(IN p_name VARCHAR(255), IN cvId INT)
BEGIN

  SELECT cvterm_id
  FROM cvterm
  WHERE name = p_name
  AND cv_id = cvId;

END$$

delimiter ;
