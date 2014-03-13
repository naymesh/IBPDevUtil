SET @ORIGINAL_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

SET @ORIGINAL_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @ORIGINAL_SQL_MODE=@@SQL_MODE, SQL_MODE='ALLOW_INVALID_DATES,NO_AUTO_VALUE_ON_ZERO,NO_AUTO_CREATE_USER';



DROP TABLE IF EXISTS `dmsattr`;



DROP VIEW IF EXISTS `category_details`; 

CREATE VIEW `category_details` AS select `c1`.`cvterm_id` AS `cvterm_id`,`c1`.`name` AS `stdvar_name`,`c2`.`cvterm_id` AS `category_id`,`c2`.`name` AS `category_name` from ((`cvterm` `c1` join `cvterm_relationship` `cr1` on((`cr1`.`subject_id` = `c1`.`cvterm_id`))) join `cvterm` `c2` on((`c2`.`cvterm_id` = `cr1`.`object_id`))) where (`cr1`.`type_id` = 1190) order by `c1`.`cvterm_id`,`c2`.`name`;

DROP VIEW IF EXISTS `standard_variable_details`;

CREATE VIEW `standard_variable_details` AS select `c`.`cvterm_id` AS `cvterm_id`,`c`.`cv_id` AS `cv_id`,`c`.`name` AS `stdvar_name`,`c`.`definition` AS `stdvar_definition`,group_concat(if((`cr`.`type_id` = 1200),`cr`.`object_id`,NULL) separator ',') AS `property_id`,group_concat(if((`cr`.`type_id` = 1210),`cr`.`object_id`,NULL) separator ',') AS `method_id`,group_concat(if((`cr`.`type_id` = 1220),`cr`.`object_id`,NULL) separator ',') AS `scale_id`,group_concat(if((`cr`.`type_id` = 1225),`cr`.`object_id`,NULL) separator ',') AS `is_a`,group_concat(if((`cr`.`type_id` = 1044),`cr`.`object_id`,NULL) separator ',') AS `stored_in`,group_concat(if((`cr`.`type_id` = 1105),`cr`.`object_id`,NULL) separator ',') AS `has_type`,group_concat(if((`cr`.`type_id` = 1200),`c1`.`name`,NULL) separator ',') AS `property`,group_concat(if((`cr`.`type_id` = 1210),`c2`.`name`,NULL) separator ',') AS `method`,group_concat(if((`cr`.`type_id` = 1220),`c3`.`name`,NULL) separator ',') AS `scale`,(case when (`cr`.`object_id` in (1010,1011,1012)) then 'STUDY' when (`cr`.`object_id` in (1015,1016,1017)) then 'DATASET' when (`cr`.`object_id` in (1020,1021,1022,1023,1024,1025)) then 'TRIAL_ENVIRONMENT' when (`cr`.`object_id` = 1030) then 'TRIAL_DESIGN' when (`cr`.`object_id` in (1040,1041,1042,1046,1047)) then 'GERMPLASM_ENTRY' when (`cr`.`object_id` = 1043) then 'VARIATE_VALUE' when (`cr`.`object_id` = 1048) then 'VARIATE_CATEGORICAL' end) AS `type`,(case when (`cr`.`object_id` in (1120,1125,1128,1130)) then 'C' when (`cr`.`object_id` in (1110,1117,1118)) then 'N' else NULL end) AS `datatype_abbrev` from ((((`cvterm` `c` join `cvterm_relationship` `cr` on((`cr`.`subject_id` = `c`.`cvterm_id`))) join `cvterm` `c1` on((`c1`.`cvterm_id` = `cr`.`object_id`))) join `cvterm` `c2` on((`c2`.`cvterm_id` = `cr`.`object_id`))) join `cvterm` `c3` on((`c3`.`cvterm_id` = `cr`.`object_id`))) where (`c`.`cv_id` = 1040) group by `c`.`cvterm_id`,`c`.`name` order by `c`.`cvterm_id`;



DROP VIEW IF EXISTS `trait_details`;


CREATE VIEW `trait_details` AS select `c2`.`cvterm_id` AS `trait_group_id`,`c2`.`name` AS `trait_group_name`,`c1`.`cvterm_id` AS `trait_id`,`c1`.`name` AS `trait_name` from ((`cvterm` `c1` join `cvterm_relationship` `cr` on((`c1`.`cvterm_id` = `cr`.`subject_id`))) join `cvterm` `c2` on((`c2`.`cvterm_id` = `cr`.`object_id`))) where (`c1`.`cv_id` = 1010) order by `c2`.`name`,`c1`.`name`;



DROP VIEW IF EXISTS `h2h_details`;
CREATE VIEW `h2h_details` AS select `pr`.`object_project_id` AS `study_id`,`ep`.`project_id` AS `project_id`,`e`.`type_id` AS `type_id`,`e`.`nd_geolocation_id` AS `location_id`,`e`.`type_id` AS `observation_type`,`e`.`nd_experiment_id` AS `experiment_id`,`p`.`phenotype_id` AS `phenotype_id`,`td`.`trait_name` AS `trait_name`,`p`.`value` AS `observed_value`,`s`.`stock_id` AS `stock_id`,`s`.`name` AS `entry_designation` from ((((((((`stock` `s` join `nd_experiment_stock` `es` on((`es`.`stock_id` = `s`.`stock_id`))) join `nd_experiment` `e` on((`e`.`nd_experiment_id` = `es`.`nd_experiment_id`))) join `nd_experiment_project` `ep` on((`ep`.`nd_experiment_id` = `e`.`nd_experiment_id`))) join `nd_experiment_phenotype` `epx` on((`epx`.`nd_experiment_id` = `e`.`nd_experiment_id`))) join `phenotype` `p` on((`p`.`phenotype_id` = `epx`.`phenotype_id`))) join `standard_variable_details` `svd` on((`svd`.`cvterm_id` = `p`.`observable_id`))) join `trait_details` `td` on((`td`.`trait_id` = `svd`.`property_id`))) join `project_relationship` `pr` on((`pr`.`subject_project_id` = `ep`.`project_id`))) where ((`e`.`type_id` = 1170) or ((`e`.`type_id` = 1155) and (1 = (select count(0) from `project_relationship` where ((`project_relationship`.`object_project_id` = `pr`.`object_project_id`) and (`project_relationship`.`type_id` = 1150)))))) order by `ep`.`project_id`,`e`.`nd_geolocation_id`,`e`.`type_id`,`td`.`trait_name`,`s`.`name`;



DROP VIEW IF EXISTS `project_variable_details`;
CREATE VIEW `project_variable_details` AS select `p`.`project_id` AS `project_id`,`p`.`name` AS `project_name`,`p`.`description` AS `description`,`pp_2`.`value` AS `variable_name`,`svd`.`cvterm_id` AS `cvterm_id`,`svd`.`cv_id` AS `cv_id`,`svd`.`stdvar_name` AS `stdvar_name`,`svd`.`stdvar_definition` AS `stdvar_definition`,`svd`.`property_id` AS `property_id`,`svd`.`method_id` AS `method_id`,`svd`.`scale_id` AS `scale_id`,`svd`.`is_a` AS `is_a`,`svd`.`stored_in` AS `stored_in`,`svd`.`has_type` AS `has_type`,`svd`.`property` AS `property`,`svd`.`method` AS `method`,`svd`.`scale` AS `scale`,`svd`.`type` AS `type`,`svd`.`datatype_abbrev` AS `datatype_abbrev` from (((`project` `p` join `projectprop` `pp_1` on((`pp_1`.`project_id` = `p`.`project_id`))) join `projectprop` `pp_2` on(((`pp_2`.`project_id` = `p`.`project_id`) and (`pp_2`.`rank` = `pp_1`.`rank`)))) join `standard_variable_details` `svd` on((`svd`.`cvterm_id` = `pp_1`.`value`))) where ((`pp_1`.`type_id` = 1070) and (`pp_2`.`type_id` not in (1060,1070)) and (`pp_2`.`type_id` <> `pp_1`.`value`)) order by `p`.`project_id`,`pp_2`.`rank`;



SET FOREIGN_KEY_CHECKS=@ORIGINAL_FOREIGN_KEY_CHECKS;

SET UNIQUE_CHECKS=@ORIGINAL_UNIQUE_CHECKS;

SET SQL_MODE=@ORIGINAL_SQL_MODE;
