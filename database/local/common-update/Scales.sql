delimiter $$

drop procedure if exists `getScales`$$

CREATE PROCEDURE `getScales`(
IN v_scaleid int,
IN v_scname varchar(200) character set utf8, 
IN v_sctype varchar(10) character set utf8)
begin

	SET @sql := CONCAT("select distinct cvsc.cvterm_id as scaleid, ",
	"cvsc.name as scname, ",
	"case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype, ",
        "cvrsb3.object_id as dtypeId ",
	"from cvterm cvsc ",
	"left join cvterm_relationship cvrsb on cvrsb.object_id = cvsc.cvterm_id and cvrsb.type_id = 1220 ",
	"left join cvterm_relationship cvr on cvr.subject_id = cvrsb.subject_id ",
	"left join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id and cvrsb3.type_id = 1105 ",
        "left join cvtermsynonym syn on syn.cvterm_id = cvsc.cvterm_id ",
	"WHERE cvsc.cv_id = 1030 ");
	IF(v_scname IS NOT NULL) THEN
            SET @sql = CONCAT(@sql," AND (cvsc.name = '",v_scname,"' OR syn.synonym = '", v_scname, "') ");
        END IF;
        SET @sql = CONCAT(@sql, " HAVING 1=1 ");
	IF(v_scaleid IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND scaleid = ",v_scaleid);
	END IF;
	IF(v_sctype IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND sctype = '",v_sctype,"'");
	END IF;	
	
        SET @sql = CONCAT(@sql, " ORDER BY syn.cvtermsynonym_id ");

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	
end$$

drop procedure if exists `searchScales`$$

CREATE PROCEDURE `searchScales`(
IN v_scaleid int,
IN v_scname varchar(200) character set utf8, 
IN v_sctype varchar(10) character set utf8)
begin

	SET @sql := CONCAT("select distinct cvsc.cvterm_id as scaleid, ",
	"cvsc.name as scname, ",
	"case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype, ",
        "cvrsb3.object_id as dtypeId ",
	"from cvterm_relationship cvr ",
	"inner join cvterm_relationship cvrsb on cvrsb.subject_id = cvr.subject_id ",
	"inner join cvterm cvsc on cvsc.cvterm_id = cvrsb.object_id and cvrsb.type_id = 1220 ",
	"inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id and cvrsb3.type_id = 1105 ",
	"having 1=0 ");
	IF(v_scaleid IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," OR scaleid = ",v_scaleid);
	END IF;
	IF(v_scname IS NOT NULL) THEN
            SET @sql = CONCAT(@sql," OR scname like '%",v_scname,"%'");
            -- SET @sql = CONCAT(@sql, " OR EXISTS (SELECT 1 FROM cvtermsynonym AS syn WHERE syn.cvterm_id = cvsc.cvterm_id AND syn.synonym LIKE '%", v_scname, "%') ");
        END IF;
	IF(v_sctype IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," OR sctype like '%",v_sctype,"%'");
	END IF;	

        SET @sql = CONCAT(@sql, " UNION ");
        SET @sql = CONCAT(@sql, 
            " SELECT DISTINCT cvt.cvterm_id as scaleid, cvt.name AS scname, ",
            " case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype ",
            " FROM cvterm cvt ",
            " INNER JOIN cvterm_relationship cvr ON cvr.object_id = cvt.cvterm_id AND cvr.type_id = 1030 ",
            " inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id and cvrsb3.type_id = 1105 ",
            " INNER JOIN cvtermsynonym syn ON syn.cvterm_id = cvt.cvterm_id AND syn.synonym LIKE '%", v_scname, "%'");

	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	
end$$

drop procedure if exists `getScalesList`$$

CREATE PROCEDURE `getScalesList`()
begin

	SET @sql := CONCAT("select distinct cvsc.cvterm_id as scaleid, ",
	"cvsc.name as scname, ",
	"case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype, ",
        "cvrsb3.object_id as dtypeId ",
	"from cvterm_relationship cvr ",
	"inner join cvterm_relationship cvrsb on cvrsb.subject_id = cvr.subject_id ",
	"inner join cvterm cvsc on cvsc.cvterm_id = cvrsb.object_id and cvrsb.type_id = 1220 ",
	"inner join cvterm_relationship cvrsb2 on cvrsb2.subject_id = cvr.subject_id ",
	"inner join cvterm cvst on cvst.cvterm_id = cvrsb2.object_id and cvrsb2.type_id = 1200 ",
	"inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id ",
	"inner join cvterm cvsdt on cvsdt.cvterm_id = cvrsb3.type_id and cvrsb3.type_id = 1105 ",
	"having 1=1 ");
	
	
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	
end$$

drop procedure if exists `getScalesByScnameAndSctype`$$

CREATE PROCEDURE `getScalesByScnameAndSctype`(
IN v_scname varchar(200) character set utf8, 
IN v_sctype varchar(10) character set utf8)
begin

	SET @sql := CONCAT("select distinct cvsc.cvterm_id as scaleid, ",
	"cvsc.name as scname, ",
	"case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype, ",
        "cvrsb3.object_id as dtypeId ",
	"from cvterm_relationship cvr ",
	"inner join cvterm_relationship cvrsb on cvrsb.subject_id = cvr.subject_id ",
	"inner join cvterm cvsc on cvsc.cvterm_id = cvrsb.object_id and cvrsb.type_id = 1220 ",
	"inner join cvterm_relationship cvrsb2 on cvrsb2.subject_id = cvr.subject_id ",
	"inner join cvterm cvst on cvst.cvterm_id = cvrsb2.object_id and cvrsb2.type_id = 1200 ",
	"inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id ",
	"inner join cvterm cvsdt on cvsdt.cvterm_id = cvrsb3.type_id and cvrsb3.type_id = 1105 ",
	"having 1=1 ");
	

	IF(v_scname IS NOT NULL) THEN
    SET @sql = CONCAT(@sql," AND scname = '",v_scname,"'");
    END IF;
	IF(v_sctype IS NOT NULL) THEN
	SET @sql = CONCAT(@sql," AND sctype = '",v_sctype,"'");
	END IF;	
	
	
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	
end$$

delimiter ;