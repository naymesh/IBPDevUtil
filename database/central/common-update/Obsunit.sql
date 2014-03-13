delimiter $$

drop procedure if exists `getObsunitList`$$

CREATE PROCEDURE `getObsunitList`()
begin

select 
project_id as effectid, 
nd_experiment_id as ounitid 
from nd_experiment_project nep 
inner join project_relationship pr on pr.subject_project_id = nep.project_id and pr.type_id = 1150 
order by project_id;

end$$

drop procedure if exists `getObsunitListByEffectid`$$

CREATE PROCEDURE `getObsunitListByEffectid`(IN effectidin int,  IN iscentral int)
begin



IF iscentral = 1 then

	select 
project_id as effectid, 
nd_experiment_id as ounitid 
from nd_experiment_project nep 
inner join project_relationship pr on pr.subject_project_id = nep.project_id and pr.type_id = 1150 
where project_id = effectidin
order by ounitid asc;

else

	select 
project_id as effectid, 
nd_experiment_id as ounitid 
from nd_experiment_project nep 
inner join project_relationship pr on pr.subject_project_id = nep.project_id and pr.type_id = 1150 
where project_id = effectidin
order by ounitid desc;

	
end if;

end$$

drop procedure if exists `getStudyObsunit`$$

CREATE PROCEDURE `getStudyObsunit`(IN v_studyid int)
begin

select project_id as effectid, 
nd_experiment_id as ounitid 
from nd_experiment_project 
where project_id = v_studyid;

end$$

delimiter ;