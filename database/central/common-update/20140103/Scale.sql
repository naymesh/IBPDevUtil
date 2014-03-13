delimiter $$

drop procedure if exists `getListScaleAll`$$

CREATE PROCEDURE `getListScaleAll`(IN iscentral int)
begin



IF iscentral = 1 then

	select distinct cvsc.cvterm_id as scaleid,
	cvsc.name as scname,
	cvst.cvterm_id as traitid,
	case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype
	from cvterm_relationship cvr
	inner join cvterm_relationship cvrsb on cvrsb.subject_id = cvr.subject_id
	inner join cvterm cvsc on cvsc.cvterm_id = cvrsb.object_id and cvrsb.type_id = 1220
	inner join cvterm_relationship cvrsb2 on cvrsb2.subject_id = cvr.subject_id
	inner join cvterm cvst on cvst.cvterm_id = cvrsb2.object_id and cvrsb2.type_id = 1200
	inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id
	inner join cvterm cvsdt on cvsdt.cvterm_id = cvrsb3.type_id and cvrsb3.type_id = 1105
	ORDER BY scaleid asc;	
	
else

	select distinct cvsc.cvterm_id as scaleid,
	cvsc.name as scname,
	cvst.cvterm_id as traitid,
	case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype
	from cvterm_relationship cvr
	inner join cvterm_relationship cvrsb on cvrsb.subject_id = cvr.subject_id
	inner join cvterm cvsc on cvsc.cvterm_id = cvrsb.object_id and cvrsb.type_id = 1220
	inner join cvterm_relationship cvrsb2 on cvrsb2.subject_id = cvr.subject_id
	inner join cvterm cvst on cvst.cvterm_id = cvrsb2.object_id and cvrsb2.type_id = 1200
	inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id
	inner join cvterm cvsdt on cvsdt.cvterm_id = cvrsb3.type_id and cvrsb3.type_id = 1105
	ORDER BY scaleid desc;
	
end if;
end$$


drop procedure if exists `getListScale`$$

CREATE PROCEDURE `getListScale`(IN traitid int, IN iscentral int)
begin



IF iscentral = 1 then

	select distinct cvsc.cvterm_id as scaleid,
	cvsc.name as scname,
	cvst.cvterm_id as traitid,
	case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype
	from cvterm_relationship cvr
	inner join cvterm_relationship cvrsb on cvrsb.subject_id = cvr.subject_id
	inner join cvterm cvsc on cvsc.cvterm_id = cvrsb.object_id and cvrsb.type_id = 1220
	inner join cvterm_relationship cvrsb2 on cvrsb2.subject_id = cvr.subject_id
	inner join cvterm cvst on cvst.cvterm_id = cvrsb2.object_id and cvrsb2.type_id = 1200 and cvst.cvterm_id = traitid
	inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id
	inner join cvterm cvsdt on cvsdt.cvterm_id = cvrsb3.type_id and cvrsb3.type_id = 1105
	ORDER BY scaleid asc;	
	
else

	select distinct cvsc.cvterm_id as scaleid,
	cvsc.name as scname,
	cvst.cvterm_id as traitid,
	case when cvrsb3.object_id in (1110, 1120, 1125, 1128, 1130) then 'D' else 'C' END as sctype
	from cvterm_relationship cvr
	inner join cvterm_relationship cvrsb on cvrsb.subject_id = cvr.subject_id
	inner join cvterm cvsc on cvsc.cvterm_id = cvrsb.object_id and cvrsb.type_id = 1220
	inner join cvterm_relationship cvrsb2 on cvrsb2.subject_id = cvr.subject_id
	inner join cvterm cvst on cvst.cvterm_id = cvrsb2.object_id and cvrsb2.type_id = 1200 and cvst.cvterm_id = traitid
	inner join cvterm_relationship cvrsb3 on cvrsb3.subject_id = cvr.subject_id
	inner join cvterm cvsdt on cvsdt.cvterm_id = cvrsb3.type_id and cvrsb3.type_id = 1105
	ORDER BY scaleid desc;
	
end if;
end$$

delimiter ;