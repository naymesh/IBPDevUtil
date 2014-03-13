delimiter $$

drop procedure if exists `getTraitGroups`$$

CREATE PROCEDURE `getTraitGroups`()
begin
	SELECT DISTINCT trg.name AS traitGroup
	  FROM cvterm trg
	 WHERE EXISTS (
			SELECT NULL
			  FROM cvterm cvt
	         INNER JOIN cvterm_relationship isa ON isa.subject_id = cvt.cvterm_id
			 WHERE cvt.cv_id = 1010
	           AND isa.type_id = 1225
	           AND isa.object_id = trg.cvterm_id
		);
end$$

drop procedure if exists `getTraitsById`$$

CREATE PROCEDURE `getTraitsById` (IN v_traitid int)
begin
    SELECT DISTINCT
	   tcvr.object_id AS tid,
	   cvt.cvterm_id AS traitid,
	   cvt.name AS trname,
	   cvt.definition AS trdesc,
	   1 AS tnstat, 
	   grp.name AS traitgroup
      FROM cvterm cvt
     LEFT JOIN cvterm_relationship gcvr ON gcvr.subject_id = cvt.cvterm_id AND gcvr.type_id = 1225
     LEFT JOIN cvterm grp ON grp.cvterm_id = gcvr.object_id
     LEFT JOIN cvterm_relationship traitcvr ON traitcvr.object_id = cvt.cvterm_id and traitcvr.type_id = 1200
     LEFT JOIN cvterm label ON label.cvterm_id = traitcvr.subject_id
     LEFT JOIN cvterm_relationship tcvr ON tcvr.subject_id = label.cvterm_id and tcvr.type_id = 1044
     WHERE cvt.cv_id = 1010
     AND cvt.cvterm_id = v_traitid
     ORDER BY traitid, tid
     LIMIT 1;
end$$

DROP PROCEDURE IF EXISTS `updateTraits`$$

CREATE PROCEDURE `updateTraits` (
IN v_tid int
,IN v_trname varchar(200)
,IN v_definition varchar(255)
,IN v_nstat int
,IN v_traitgroup varchar(200)
)

begin

PREPARE statement FROM 
'
   UPDATE cvterm 
   SET name = ? 
   WHERE cvterm_id = ?;
';
SET @cvtermname = v_trname;
SET @cvterm_id = v_tid;
EXECUTE statement USING @cvtermname, @cvterm_id;


/*UPDATE cvterm cvt
INNER JOIN cvterm_relationship cvr ON cvr.object_id = cvt.cvterm_id
INNER JOIN cvterm_relationship gcvr ON gcvr.subject_id = cvt.cvterm_id
INNER JOIN cvterm grp ON grp.cvterm_id = gcvr.object_id
SET
cvt.name = v_trname,
cvt.definition = v_definition,
grp.name = v_traitgroup
WHERE gcvr.type_id = 1225 -- get "is a" relationship to get group name
AND cvr.type_id = 1200 -- get "has property" relationships
AND cvt.cvterm_id = v_tid;
*/

end$$


drop procedure if exists `addTraits`$$

CREATE PROCEDURE `addTraits` (
IN trname varchar(200) character set utf8, 
IN trdesc varchar(255) character set utf8, 
IN traitgroupid int(11))
-- IN traitgroup varchar(255) character set utf8)
begin
        -- declare v_traitgroupid int default 0;
        declare v_newcvtermid int;

	-- add cvterm - IN cvidin int, IN cvname varchar(500), IN cvdesc varchar(500), OUT newcvtermidret INT
	call addCvtermReturnId(1010, trname, trdesc, v_newcvtermid);

        -- select cvterm_id  
        --   into v_traitgroupid
        --   from cvterm 
        --  where cv_id = 1000 
        --    and name = traitgroup;
        
        -- if (v_traitgroupid = 0) then
        --    	call addCvtermReturnId(1000, traitgroup, traitgroup, v_traitgroupid); -- group
        -- end if;
	
	-- add cvterm relationship --IN typeid int, IN subjectid int, IN objectid int
	-- call addCvtermRelationship(1200,?subjectId?,@newcvtermid);
	-- add cvterm relationship	
	-- call addCvtermRelationship(1225, @newcvtermid, v_traitgroupid);
        call addCvtermRelationship(1225, @newcvtermid, traitgroupid);

	select v_newcvtermid;
end$$

delimiter ;