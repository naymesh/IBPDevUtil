delimiter $$

drop procedure if exists addOindex$$

CREATE PROCEDURE addOindex(
IN v_nd_experiment_id int,
IN v_project_id int,
IN v_nd_experiment_project_id int)
begin

-- DECLARE v_nd_experiment_project_id int;

-- START TRANSACTION;

-- CALL getNextMinReturn('nd_experiment_project',v_nd_experiment_project_id);

INSERT INTO nd_experiment_project(nd_experiment_project_id,project_id,nd_experiment_id)
VALUES(v_nd_experiment_project_id,v_project_id,v_nd_experiment_id);

-- COMMIT;

end$$

delimiter ;