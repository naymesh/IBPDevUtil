delimiter $$
drop procedure if exists `getListTmsMethod`$$

CREATE PROCEDURE `getListTmsMethod` (
IN v_tmethid int,
IN v_tmname varchar(200) character set utf8,
IN v_tmdesc varchar(255) character set utf8)
begin
	SET @sql := CONCAT("SELECT cvt.cvterm_id AS tmethid, ",
	   			"cvt.name AS tmname, ",
       			"cvt.definition AS tmdesc ",
  				"FROM cvterm cvt ");

        IF (v_tmname IS NOT NULL) THEN
            SET @sql = CONCAT(@sql, " LEFT JOIN cvtermsynonym cs ON cs.cvterm_id = cvt.cvterm_id ");
        END IF;

        SET @sql = CONCAT(@sql, " WHERE cvt.cv_id = 1020 ");

	IF(v_tmethid IS NOT NULL) THEN
		SET @sql = CONCAT(@sql," AND cvt.cvterm_id = ", v_tmethid);
    END IF;

	IF(v_tmname IS NOT NULL) THEN
		SET @sql = CONCAT(@sql," AND (cvt.name = '", v_tmname, "' OR cs.synonym = '", v_tmname, "') ");
    END IF;
	
	IF(v_tmdesc IS NOT NULL) THEN
		SET @sql = CONCAT(@sql," AND cvt.definition = '", v_tmdesc, "' ");
    END IF;

        IF (v_tmname IS NOT NULL) THEN
            SET @sql = CONCAT(@sql, " ORDER BY cs.cvtermsynonym_id, tmethid; ");
        ELSE
            SET @sql = CONCAT(@sql, " ORDER BY tmethid; ");
        END IF;
	
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
end$$

drop procedure if exists `getTmsMethodList`$$

CREATE PROCEDURE `getTmsMethodList` ()
begin
	SET @sql := CONCAT("SELECT cvterm_id AS tmethid, ",
	   			"name AS tmname, ",
       			"definition AS tmdesc ",
  				"FROM cvterm "
 				"WHERE cv_id = 1020 ");
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
end$$

delimiter ;