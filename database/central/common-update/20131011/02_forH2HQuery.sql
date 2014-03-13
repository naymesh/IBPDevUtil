drop view if exists h2h_details;
create view h2h_details as
select pr.object_project_id as 'study_id', ep.project_id, e.type_id, e.nd_geolocation_id as 'location_id', e.type_id 'observation_type', e.nd_experiment_id as 'experiment_id', 
       p.phenotype_id, td.trait_name, p.value as 'observed_value', s.stock_id, s.name as 'entry_designation'
from stock s
join nd_experiment_stock es on es.stock_id = s.stock_id
join nd_experiment e on e.nd_experiment_id = es.nd_experiment_id
join nd_experiment_project ep on ep.nd_experiment_id = e.nd_experiment_id
join nd_experiment_phenotype epx on epx.nd_experiment_id = e.nd_experiment_id 
join phenotype p on p.phenotype_id = epx.phenotype_id
join standard_variable_details svd on svd.cvterm_id = p.observable_id
join trait_details td on td.trait_id = svd.property_id
join project_relationship pr on pr.subject_project_id = ep.project_id
#where e.type_id in (1155, 1170)
where
  (e.type_id = 1170 
   or 
  (e.type_id = 1155 
   and 1 = (select count(*) from project_relationship where object_project_id = pr.object_project_id and type_id = 1150)))
order by ep.project_id, e.nd_geolocation_id, e.type_id, td.trait_name, s.name;


drop procedure if exists h2h_traitXenv;

delimiter $$
CREATE PROCEDURE `h2h_traitXenv`(germplasm1 varchar(100), germplasm2 varchar(100))
begin

	drop temporary table if exists h2h_temp;
	CREATE TEMPORARY TABLE h2h_temp AS (
		select distinct trait_name, entry_designation, location_id
		from h2h_details
		where entry_designation in (germplasm1, germplasm2));

		select distinct location_id, trait_name, 1
		from h2h_temp h2h
		group by location_id, trait_name, 1
		having count(*) > 1
		order by trait_name, location_id;

end$$
delimiter ;

drop procedure if exists h2h_traitXenv_summary;

delimiter $$
CREATE PROCEDURE `h2h_traitXenv_summary`(germplasm1 varchar(100), germplasm2 varchar(100))
begin


	drop temporary table if exists h2h_temp;

	CREATE TEMPORARY TABLE h2h_temp AS (
		select distinct trait_name, entry_designation, location_id
		from h2h_details
		where entry_designation in (germplasm1, germplasm2));

		select trait_name, count(*)
		from (	select distinct trait_name, location_id, count(*)
				from h2h_temp
				group by trait_name, location_id
				having count(location_id) > 1) as h2h_temp2
		group by trait_name;


end$$
delimiter ;