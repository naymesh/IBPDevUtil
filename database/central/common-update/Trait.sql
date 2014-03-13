delimiter $$

drop procedure if exists `getTraitList`$$

CREATE PROCEDURE `getTraitList`()
begin
    SELECT DISTINCT
	   tcvr.object_id AS tid,
	   cvt.cvterm_id AS traitid,
	   cvt.name AS trname,
	   cvt.definition AS trdesc,
	   1 AS tnstat, 
	   grp.name AS traitgroup,
           grp.cvterm_id AS traitGroupId
      FROM cvterm cvt
     INNER JOIN cvterm_relationship gcvr ON gcvr.subject_id = cvt.cvterm_id
     INNER JOIN cvterm grp ON grp.cvterm_id = gcvr.object_id
     INNER JOIN cvterm_relationship traitcvr ON traitcvr.object_id = cvt.cvterm_id and traitcvr.type_id = 1200
     INNER JOIN cvterm label ON label.cvterm_id = traitcvr.subject_id
     INNER JOIN cvterm_relationship tcvr ON tcvr.subject_id = label.cvterm_id and tcvr.type_id = 1044
     WHERE gcvr.type_id = 1225 
       AND cvt.cv_id = 1010
     ORDER BY traitid, tid;

end$$

delimiter $$

DROP PROCEDURE IF EXISTS `getTraitListByTrait` $$

CREATE PROCEDURE `getTraitListByTrait`(
IN tid int, 
IN traitId int, 
IN traitName varchar(200) character set utf8, 
IN traitDescription varchar(255) character set utf8, 
IN traitGroup varchar(255) character set utf8)
BEGIN

SET @mySQL := 'SELECT DISTINCT
                    tcvr.object_id AS tid,
                    cvt.cvterm_id AS traitId,
                    cvt.name AS traitName,
                    cvt.definition AS traitDescription,
                    1 AS tnstat, 
                    grp.name AS traitGroup, 
                    grp.cvterm_id AS traitGroupId
            FROM cvterm cvt
           LEFT JOIN cvterm_relationship gcvr ON gcvr.subject_id = cvt.cvterm_id AND gcvr.type_id = 1225
           LEFT JOIN cvterm grp ON grp.cvterm_id = gcvr.object_id
           LEFT JOIN cvterm_relationship traitcvr ON traitcvr.object_id = cvt.cvterm_id and traitcvr.type_id = 1200
           LEFT JOIN cvterm label ON label.cvterm_id = traitcvr.subject_id
           LEFT JOIN cvterm_relationship tcvr ON tcvr.subject_id = label.cvterm_id and tcvr.type_id = 1044
           LEFT JOIN cvtermsynonym syn ON syn.cvterm_id = cvt.cvterm_id 
           WHERE cvt.cv_id = 1010 ';

  IF (tid IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND tcvr.object_id = ", tid);
  END IF;

  IF (traitId IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND cvt.cvterm_id = ", traitId);
  END IF;

  IF (traitName IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND (cvt.name = '", traitName, "' OR syn.synonym = '", traitName, "') ");
  END IF;

  IF (traitDescription IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND cvt.definition LIKE '%", traitDescription, "%'");
  END IF;

  IF (traitGroup IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND grp.name LIKE '%", traitGroup, "%'");
  END IF;

  set @mySQL := CONCAT(@mySQL, " ORDER BY syn.cvtermsynonym_id, traitid, tid; ");

  PREPARE stmt FROM @mySQL;
  EXECUTE stmt;

end$$

DROP PROCEDURE IF EXISTS `getTraitListWithSynonymByTrait` $$

CREATE PROCEDURE `getTraitListWithSynonymByTrait`(
IN tid int, 
IN traitId int, 
IN traitName varchar(200) character set utf8, 
IN traitDescription varchar(255) character set utf8, 
IN traitGroup varchar(255) character set utf8)
BEGIN

SET @mySQL := 'SELECT DISTINCT
                    tcvr.object_id AS tid,
                    cvt.cvterm_id AS traitId,
                    cvt.name AS traitName,
                    cvt.definition AS traitDescription,
                    1 AS tnstat, 
                    grp.name AS traitGroup, 
                    grp.cvterm_id AS traitGroupId
            FROM cvterm cvt
           LEFT JOIN cvterm_relationship gcvr ON gcvr.subject_id = cvt.cvterm_id AND gcvr.type_id = 1225
           LEFT JOIN cvterm grp ON grp.cvterm_id = gcvr.object_id
           LEFT JOIN cvterm_relationship traitcvr ON traitcvr.object_id = cvt.cvterm_id and traitcvr.type_id = 1200
           LEFT JOIN cvterm label ON label.cvterm_id = traitcvr.subject_id
           LEFT JOIN cvterm_relationship tcvr ON tcvr.subject_id = label.cvterm_id and tcvr.type_id = 1044
           LEFT JOIN cvtermsynonym syn ON syn.cvterm_id = cvt.cvterm_id
           WHERE cvt.cv_id = 1010 ';

  IF (tid IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND tcvr.object_id = ", tid);
  END IF;

  IF (traitId IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND cvt.cvterm_id = ", traitId);
  END IF;

  IF (traitName IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND (cvt.name LIKE '%", traitName, "%' OR syn.synonym LIKE '%", traitName, "%')");
  END IF;

  IF (traitDescription IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND cvt.definition LIKE '%", traitDescription, "%'");
  END IF;

  IF (traitGroup IS NOT NULL) THEN
    set @mySQL := CONCAT(@mySQL, " AND grp.name LIKE '%", traitGroup, "%'");
  END IF;

  set @mySQL := CONCAT(@mySQL, " ORDER BY syn.cvtermsynonym_id, traitid, tid; ");

  PREPARE stmt FROM @mySQL;
  EXECUTE stmt;

end$$

delimiter ;