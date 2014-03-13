delimiter $$

drop procedure if exists `getDataNByEffectId`$$

CREATE PROCEDURE `getDataNByEffectId`(IN effectid int, IN iscentral int)
begin



IF iscentral = 1 then

	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value 
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
	and cvt3.cvterm_id = 1110 
	) 
	order by ounitid asc, variatid asc ;
else

	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value 
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
	and cvt3.cvterm_id = 1110 
	) 
	order by ounitid desc, variatid desc ;
	
end if;
end$$

drop procedure if exists `getDataNList`$$

CREATE PROCEDURE `getDataNList`()
begin

	select nep.nd_experiment_id as ounitid, pp.projectprop_id as variatid, p.value
	from phenotype p
	inner join projectprop pp on pp.value = observable_id 
	and exists
	(
	select 1
	from cvterm cvt1
	inner join cvterm_relationship cvtr ON cvt1.cvterm_id = cvtr.subject_id
	INNER JOIN cvterm cvt3 ON cvtr.object_id = cvt3.cvterm_id
	where p.observable_id = cvt1.cvterm_id
	and cvt3.cvterm_id = 1110
	)
	INNER JOIN projectprop label ON label.rank = pp.rank and label.project_id = pp.project_id and pp.type_id = 1070 and label.type_id in(1043, 1048)
	inner join nd_experiment_phenotype nep on p.phenotype_id = nep.phenotype_id
	inner join nd_experiment_project nexp on nexp.nd_experiment_id = nep.nd_experiment_id and pp.project_id = nexp.project_id
	group by ounitid, variatid, p.value;

end$$


drop procedure if exists `getListDataN`$$

CREATE PROCEDURE `getListDataN`(IN paramvariatid int, IN iscentral int)
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
	and cvt3.cvterm_id = 1110
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
	from cvterm_relationship cvtr 
	where p.observable_id = cvtr.subject_id
	and cvtr.object_id = 1110
	)
	INNER JOIN projectprop label ON label.rank = pp.rank and label.project_id = pp.project_id and label.type_id in(1043, 1048) 
	inner join nd_experiment_phenotype nep on p.phenotype_id = nep.phenotype_id
	inner join nd_experiment_project nexp on nexp.nd_experiment_id = nep.nd_experiment_id and pp.project_id = nexp.project_id
        where
            pp.projectprop_id = paramvariatid
	order by ounitid desc;
	
	
end if;
end$$

delimiter ;