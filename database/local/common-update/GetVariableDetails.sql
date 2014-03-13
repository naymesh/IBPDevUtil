DELIMITER $$

DROP PROCEDURE if exists GetVariableDetails$$
CREATE PROCEDURE `GetVariableDetails`(pid int, id_list varchar(2000))
BEGIN

  # brings back details based on a comma delimited list of one or more ids. 

  call split(id_list,',');

  select cvterm_id, property_id as 'factor_id', project_id, stdvar_name, 
		 property, method, scale, datatype_abbrev
  from   project_variable_details
  where  project_id = pid
  and    cvterm_id in (select id from temptbl)
  order by cvterm_id;

  # call GetVariableDetails(10015,'8010,8020'); #can pass in a list or one or more

END$$

DELIMITER ;
