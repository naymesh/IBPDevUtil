delimiter $$

drop procedure if exists `getDataCByEffectId`$$

CREATE PROCEDURE `getDataCByEffectId`(IN effectid int, IN iscentral int)
begin



IF iscentral = 1 then

	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value as dvalue
	from phenotype p 
	inner join nd_experiment_phenotype nep on p.phenotype_id = nep.phenotype_id 
	inner join nd_experiment_project nexp on nexp.nd_experiment_id = nep.nd_experiment_id 
	inner join projectprop pp on pp.value = p.observable_id and pp.project_id = nexp.project_id 
	INNER JOIN projectprop label ON label.project_id = pp.project_id AND label.rank = pp.rank 
	WHERE pp.type_id = 1070 and label.type_id in(1043, 1048) and nexp.project_id = effectid 
	and exists 
	( 
	select 1 
	from cvterm cvt1 
	inner join cvterm_relationship cvtr ON cvt1.cvterm_id = cvtr.subject_id 
	INNER JOIN cvterm cvt3 ON cvtr.object_id = cvt3.cvterm_id 
	where p.observable_id = cvt1.cvterm_id 
	and cvt3.cvterm_id = 1120 
	) 
	order by ounitid asc, variatid asc ;
else

	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value as dvalue
	from phenotype p 
	inner join nd_experiment_phenotype nep on p.phenotype_id = nep.phenotype_id 
	inner join nd_experiment_project nexp on nexp.nd_experiment_id = nep.nd_experiment_id 
	inner join projectprop pp on pp.value = p.observable_id and pp.project_id = nexp.project_id 
	INNER JOIN projectprop label ON label.project_id = pp.project_id AND label.rank = pp.rank 
	WHERE pp.type_id = 1070 and label.type_id in(1043, 1048) and nexp.project_id = effectid 
	and exists 
	( 
	select 1 
	from cvterm cvt1 
	inner join cvterm_relationship cvtr ON cvt1.cvterm_id = cvtr.subject_id 
	INNER JOIN cvterm cvt3 ON cvtr.object_id = cvt3.cvterm_id 
	where p.observable_id = cvt1.cvterm_id 
	and cvt3.cvterm_id = 1120 
	) 
	order by ounitid desc, variatid desc ;
	
end if;
end$$

drop procedure if exists `getDataCList`$$

CREATE PROCEDURE `getDataCList`()
begin

	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value as dvalue
	from phenotype p
	inner join projectprop pp on pp.value = observable_id 
	and exists
	(
	select 1
	from cvterm cvt1
	inner join cvterm_relationship cvtr ON cvt1.cvterm_id = cvtr.subject_id
	INNER JOIN cvterm cvt3 ON cvtr.object_id = cvt3.cvterm_id
	where p.observable_id = cvt1.cvterm_id
	and cvt3.cvterm_id = 1120
	)
	INNER JOIN projectprop label ON label.rank = pp.rank and label.project_id = pp.project_id and pp.type_id = 1070 and label.type_id in(1043, 1048)
	inner join nd_experiment_phenotype nep on p.phenotype_id = nep.phenotype_id
	inner join nd_experiment_project nexp on nexp.nd_experiment_id = nep.nd_experiment_id and pp.project_id = nexp.project_id
	group by ounitid, variatid, p.value;

end$$

drop procedure if exists `getListDataC`$$

CREATE PROCEDURE `getListDataC`(IN paramvariatid int, IN iscentral int)
begin

IF iscentral = 1 then
	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value as dvalue
	from phenotype p
	inner join projectprop pp on pp.value = observable_id and pp.type_id = 1070
	and exists
	(
	select 1
	from cvterm cvt1
	inner join cvterm_relationship cvtr ON cvt1.cvterm_id = cvtr.subject_id
	INNER JOIN cvterm cvt3 ON cvtr.object_id = cvt3.cvterm_id
	where p.observable_id = cvt1.cvterm_id
	and cvt3.cvterm_id = 1120
	)
	INNER JOIN projectprop label ON label.rank = pp.rank and label.project_id = pp.project_id and label.type_id in(1043, 1048)
	inner join nd_experiment_phenotype nep on p.phenotype_id = nep.phenotype_id
	inner join nd_experiment_project nexp on nexp.nd_experiment_id = nep.nd_experiment_id and pp.project_id = nexp.project_id
        where
         pp.projectprop_id = paramvariatid
	order by ounitid asc;
else
	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value as dvalue
	from phenotype p
	inner join projectprop pp on pp.value = observable_id and pp.type_id = 1070
	and exists
	(
	select 1
	from cvterm cvt1
	inner join cvterm_relationship cvtr ON cvt1.cvterm_id = cvtr.subject_id
	INNER JOIN cvterm cvt3 ON cvtr.object_id = cvt3.cvterm_id
	where p.observable_id = cvt1.cvterm_id
	and cvt3.cvterm_id = 1120
	)
	INNER JOIN projectprop label ON label.rank = pp.rank and label.project_id = pp.project_id and label.type_id in(1043, 1048) 
	inner join nd_experiment_phenotype nep on p.phenotype_id = nep.phenotype_id
	inner join nd_experiment_project nexp on nexp.nd_experiment_id = nep.nd_experiment_id and pp.project_id = nexp.project_id
        where
            pp.projectprop_id = paramvariatid
	order by ounitid desc;
	
	
end if;
end$$

drop procedure if exists addOrUpdateDataC$$

CREATE PROCEDURE addOrUpdateDataC(
IN v_ounitid int,
IN v_variatid int,
IN v_dvalue varchar(255),
IN v_cvalueId int)
begin

DECLARE v_phenotype_id int;
DECLARE v_phenotype_name varchar(50);
-- DECLARE v_cvalue_id int;
DECLARE v_nd_experiment_phenotype_id int;


-- START TRANSACTION;

select ph.phenotype_id into v_phenotype_id
from nd_experiment_phenotype nep, phenotype ph, projectprop pp 
where nep.nd_experiment_id = v_ounitid
and nep.phenotype_id = ph.phenotype_id
and ph.observable_id = pp.value
and pp.projectprop_id = v_variatid;
    
IF(v_phenotype_id IS NULL) THEN

   IF (v_dvalue IS NOT NULL) THEN
	CALL getNextMinReturn('phenotype',v_phenotype_id);
	
	select value into v_phenotype_name
	from projectprop pp
	where pp.projectprop_id = v_variatid;
	
	-- select cvterm_id into v_cvalue_id 
	-- from cvterm ct, cvterm_relationship cr  
	-- where name =  v_dvalue
	-- and object_id = ct.cvterm_id
	-- and subject_id = v_phenotype_name
	-- and exists (
    	-- select 1 
    	-- from projectprop pp, projectprop label
    	-- where pp.project_id = label.project_id
    	-- and pp.rank = label.rank
    	-- and label.type_id = 1048
	-- and pp.projectprop_id = v_variatid);
	
        -- PHENOTYPE unique constraint | uniquename
        -- IF NOT EXISTS(SELECT 1 FROM phenotype WHERE uniquename=v_phenotype_id) THEN
		insert into phenotype(phenotype_id,uniquename,name,observable_id,attr_id,value,cvalue_id,assay_id) 
		values(v_phenotype_id,v_phenotype_id,v_phenotype_name,v_phenotype_name,NULL,v_dvalue,v_cvalueId,NULL);
	-- END IF;	

	CALL getNextMinReturn('nd_experiment_phenotype',v_nd_experiment_phenotype_id);
	
        -- ND_EXPERIMENT_PHENOTYPE unique constraint | ND_EXPERIMENT_ID, PHENOTYPE_ID
        IF NOT EXISTS(SELECT 1 FROM nd_experiment_phenotype WHERE nd_experiment_id=v_ounitid AND phenotype_id=v_phenotype_id) THEN
		insert into nd_experiment_phenotype(nd_experiment_phenotype_id,nd_experiment_id,phenotype_id)
		values(v_nd_experiment_phenotype_id,v_ounitid,v_phenotype_id);
	END IF;

    END IF;

ELSE 

--	select cvterm_id into v_cvalue_id 
--	from cvterm ct, cvterm_relationship cr, phenotype ph  
--	where ct.name =  v_dvalue
--	and cr.object_id = ct.cvterm_id
--	and cr.subject_id = ph.observable_id
--	and ph.phenotype_id = v_phenotype_id;
	
    update phenotype
	set value = v_dvalue
	,cvalue_id = v_cvalueId 
	where phenotype_id = v_phenotype_id;
	
	
END IF;

-- COMMIT;

end$$

delimiter delimiter;;