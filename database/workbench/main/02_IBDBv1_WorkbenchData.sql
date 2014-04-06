-- Add Schema Version
INSERT INTO schema_version (version) VALUES ('20140103');

-- Add Workflow Template Data.
-- Add any new workflow here.
INSERT INTO workbench_workflow_template (name, user_defined) VALUES
 ('MARS', FALSE)
,('CB', FALSE)
,('MAS', FALSE)
,('MABC', FALSE)
,('Manager', FALSE)
;

-- Add the Workflow Steps Data
-- Add any new workflow step here.
INSERT INTO workbench_workflow_step (name, title) VALUES
 ('project_planning', 'Project Planning')
,('population_management', 'Population Management')
,('field_trial_management', 'Field Trial Management')
,('genotyping', 'Genotyping')
,('phenotypic_analysis', 'Phenotypic Analysis')
,('qtl_analysis', 'QTL Analysis')
,('qtl_selection', 'QTL Selection')
,('recombination_cycle', 'Recombination Cycle')
,('final_breeding_decision', 'Final Breeding Decision')
,('population_development','Population Development')
,('statistical_analysis','Statistical Analysis')
,('breeding_decision','Breeding Decision')
,('backcrossing','Backcrossing')
,('administration','Administration')
,('analysis_pipeline','Analysis Pipeline')
,('configuration','Configuration')
,('breeding_management','Breeding Management')
,('decision_support','Decision Support')
;

-- Add steps to MARS Workflow
INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'project_planning';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'population_management';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'field_trial_management';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'genotyping';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'phenotypic_analysis';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'qtl_analysis';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'qtl_selection';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'recombination_cycle';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MARS' AND step.name = 'final_breeding_decision';

-- Add steps to CB Workflow
INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'CB' AND step.name = 'project_planning';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 2, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'CB' AND step.name = 'population_development';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 4, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'CB' AND step.name = 'field_trial_management';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 5, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'CB' AND step.name = 'statistical_analysis';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 6, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'CB' AND step.name = 'breeding_decision';

-- Add steps to MAS Workflow
INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MAS' AND step.name = 'project_planning';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 2, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MAS' AND step.name = 'population_development';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 3, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MAS' AND step.name = 'genotyping';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 4, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MAS' AND step.name = 'field_trial_management';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 5, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MAS' AND step.name = 'statistical_analysis';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 6, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MAS' AND step.name = 'breeding_decision';


-- Add steps to MABC workflow
INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MABC' AND step.name = 'project_planning';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 2, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MABC' AND step.name = 'backcrossing';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 3, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MABC' AND step.name = 'genotyping';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 4, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MABC' AND step.name = 'field_trial_management';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 5, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MABC' AND step.name = 'statistical_analysis';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 6, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'MABC' AND step.name = 'breeding_decision';

-- Add steps to Manager Workflow
INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 1, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'Manager' AND step.name = 'administration';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 2, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'Manager' AND step.name = 'configuration';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 3, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'Manager' AND step.name = 'project_planning';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 4, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'Manager' AND step.name = 'breeding_management';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 5, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'Manager' AND step.name = 'analysis_pipeline';

INSERT IGNORE INTO workbench_workflow_template_step(template_id, step_number, step_id)
SELECT template_id, 6, step_id 
FROM workbench_workflow_template template, workbench_workflow_step step
WHERE template.name = 'Manager' AND step.name = 'decision_support';

-- 
-- workbench_role data
-- 
INSERT INTO workbench_role(name, workflow_template_id, role_label, label_order) 
SELECT 'CB Breeder', template_id, 'Conventional Breeding (CB)', 1 
FROM workbench_workflow_template WHERE name = 'CB'
	AND NOT EXISTS (SELECT role_id FROM workbench_role 
                WHERE name = 'CB Breeder' 
                    AND workflow_template_id = (SELECT DISTINCT template_id 
                                                FROM workbench_workflow_template WHERE name = 'CB'));

INSERT INTO workbench_role(name, workflow_template_id, role_label, label_order) 
SELECT 'MAS Breeder', template_id, 'Marker Assisted Selection (MAS)', 2 
FROM workbench_workflow_template WHERE name = 'MAS'
	AND NOT EXISTS (SELECT role_id FROM workbench_role 
                WHERE name = 'MAS Breeder' 
                    AND workflow_template_id = (SELECT DISTINCT template_id 
                                                FROM workbench_workflow_template WHERE name = 'MAS'));

INSERT INTO workbench_role(name, workflow_template_id, role_label, label_order) 
SELECT 'MABC Breeder', template_id, 'Marker Assisted Backcrossing (MABC)', 3 
FROM workbench_workflow_template WHERE name = 'MABC'
	AND NOT EXISTS (SELECT role_id FROM workbench_role 
                WHERE name = 'MABC Breeder' 
                    AND workflow_template_id = (SELECT DISTINCT template_id 
                                                FROM workbench_workflow_template WHERE name = 'MABC'));

INSERT INTO workbench_role(name, workflow_template_id, role_label, label_order) 
SELECT 'MARS Breeder', template_id, 'Marker Assisted Recurrent Selection (MARS)', 4
FROM workbench_workflow_template WHERE name = 'MARS'
	AND NOT EXISTS (SELECT role_id FROM workbench_role 
                WHERE name = 'MARS Breeder' 
                    AND workflow_template_id = (SELECT DISTINCT template_id 
                                                FROM workbench_workflow_template WHERE name = 'MARS'));

INSERT INTO workbench_role(name, workflow_template_id, role_label, label_order) 
SELECT 'Manager', template_id, 'Access all tools with a menu interface (MENU)', 5 
FROM workbench_workflow_template WHERE name = 'Manager'
	AND NOT EXISTS (SELECT role_id FROM workbench_role 
                WHERE name = 'Manager' 
                    AND workflow_template_id = (SELECT DISTINCT template_id 
                                                FROM workbench_workflow_template WHERE name = 'Manager'));
