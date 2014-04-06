SET @OLD_FOREIGN_KEY_CHECKS=@@foreign_key_checks;
SET foreign_key_checks = 0;

DROP TABLE IF EXISTS schema_version;
CREATE TABLE schema_version (
    version     VARCHAR(32)
    ,PRIMARY KEY (version)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- The 'users' table DDL is copied from the DMS 'users' table.
--
DROP TABLE IF EXISTS users; 
CREATE TABLE users (
  userid INT NOT NULL DEFAULT 0,
  instalid INT NOT NULL DEFAULT 0,
  ustatus INT NOT NULL DEFAULT 0,
  uaccess INT NOT NULL DEFAULT 0,
  utype INT NOT NULL DEFAULT 0,
  uname VARCHAR(30) NOT NULL DEFAULT '-',
  upswd VARCHAR(30) NOT NULL DEFAULT '-',
  personid INT NOT NULL DEFAULT 0,
  adate INT NOT NULL DEFAULT 0,
  cdate INT NOT NULL DEFAULT 0,
  PRIMARY KEY (userid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE INDEX users_idx01 ON users (instalid);
CREATE INDEX users_idx02 ON users (personid);
CREATE INDEX users_idx03 on users (userid);    -- added 20091103 mhabito: define regular index on column(s) with UNIQUE KEY constraint

--
-- The 'persons' table DDL is copied from the DMS 'persons' table.
--
DROP TABLE IF EXISTS persons; 
CREATE TABLE persons (
  personid INT NOT NULL DEFAULT 0,
  fname VARCHAR(20) NOT NULL DEFAULT '-',
  lname VARCHAR(50) NOT NULL DEFAULT '-',
  ioname VARCHAR(15) NOT NULL DEFAULT '-',
  institid INT NOT NULL DEFAULT 0,
  ptitle VARCHAR(25) NOT NULL DEFAULT '-',
  poname VARCHAR(50) NOT NULL DEFAULT '-',
  plangu INT NOT NULL DEFAULT 0,
  pphone VARCHAR(20) NOT NULL DEFAULT '-',
  pextent VARCHAR(20) NOT NULL DEFAULT '-',
  pfax VARCHAR(20) NOT NULL DEFAULT '-',
  pemail VARCHAR(40) NOT NULL DEFAULT '-',
  prole INT NOT NULL DEFAULT 0,
  sperson INT NOT NULL DEFAULT 0,
  eperson INT NOT NULL DEFAULT 0,
  pstatus INT NOT NULL DEFAULT 0,
  pnotes VARCHAR(255) NOT NULL DEFAULT '-',
  contact VARCHAR(255) NOT NULL DEFAULT '-',
  PRIMARY KEY (personid) 
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE INDEX persons_idx01 ON persons (institid);
CREATE INDEX persons_idx02 ON persons (personid);

-- 
--  A template of a Workflow.
--  
--  To represent a workflow (such as MARS) in the DB,
--  we will be adding records on the following tables:
--       workbench_workflow_template
--       workbench_workflow_step
--       workbench_workflow_template_step
--       workbench_tool
--       workbench_tool_input
--       workbench_tool_output
--       workbench_tool_transform
--       workbench_workflow_step_tool
--  
--  When creating a new project, the user selects a workflow template,
--  and we "clone" the template's steps by adding entries to:
--       workbench_project_workflow_step
--  from the
--       workbench_workflow_template_step
--  table.
--  We need to do this because users are allowed to:
--      - create workflow templates
--      - change the workflow used in their project without affecting
--        the workflow template used in the project
--      - users are allowed to save the workflow used in their project
--        (i.e, they are allowed to add new workflow templates)
-- 
DROP TABLE IF EXISTS workbench_workflow_template;
CREATE TABLE workbench_workflow_template (
     template_id            INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,name                   VARCHAR(255) NOT NULL
    ,user_defined           BOOL NOT NULL DEFAULT FALSE
    ,PRIMARY KEY(template_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  A "Step" in a workflow.
-- 
DROP TABLE IF EXISTS workbench_workflow_step;
CREATE TABLE workbench_workflow_step (
     step_id                INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,name                   VARCHAR(64) NOT NULL
    ,title                  VARCHAR(255) NOT NULL
    ,PRIMARY KEY(step_id)
    ,UNIQUE(name)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  The steps associated with a Workflow Template.
--  
--  NOTE: If we are going to save the "prev/next step" of a "step",
--  it might be hard to support the UI mockup provided by douglas.
--  See Note 20120330_workflow_steps
-- 
DROP TABLE IF EXISTS workbench_workflow_template_step;
CREATE TABLE workbench_workflow_template_step (
     workflow_template_step_id          INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,template_id                        INT UNSIGNED NOT NULL
    ,step_number                        VARCHAR(16)
    ,step_id                            INT UNSIGNED NOT NULL
    ,PRIMARY KEY(workflow_template_step_id)
    ,UNIQUE(template_id, step_number)
    ,CONSTRAINT fk_workflow_template_step_1 FOREIGN KEY(template_id) REFERENCES workbench_workflow_template(template_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_workflow_template_step_2 FOREIGN KEY(step_id) REFERENCES workbench_workflow_step(step_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  Tools such as "Germplasm Browser" and "Field Book"
--  will be registered here.
--  
DROP TABLE IF EXISTS workbench_tool;
CREATE TABLE workbench_tool (
     tool_id                INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,name                   VARCHAR(128) NOT NULL
    ,group_name             VARCHAR(128) NOT NULL
    ,title                  VARCHAR(255) NOT NULL
    ,version                VARCHAR(16) NOT NULL
    ,tool_type              ENUM('WEB', 'WEB_WITH_LOGIN', 'NATIVE','WORKBENCH','ADMIN')
    ,path                   TEXT
    ,parameter              VARCHAR(255) NOT NULL DEFAULT ''
    ,user_tool              BOOLEAN NOT NULL DEFAULT FALSE
    ,PRIMARY KEY(tool_id)
    ,UNIQUE(name)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--  The workbench_tool_input, workbench_tool_output, and workbench_tool_transform
--  tables were originally intended to contain information on how an output of a
--  certain tool can be transformed as input of another tool.
-- 
--  A list of named "input" of a tool.
--  "input_label" is the parameter name we could use as labels in screens.
--  "input_name" is the official paramter name (for web or commandline tools).
-- 
DROP TABLE IF EXISTS workbench_tool_input;
CREATE TABLE workbench_tool_input (
     tool_input_id          INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,tool_id                INT UNSIGNED NOT NULL
    ,input_label            VARCHAR(255)
    ,input_name             VARCHAR(128)
    ,input_type             ENUM('NUMBER', 'TEXT', 'DATE', 'FILE')
    ,PRIMARY KEY(tool_input_id)
    ,CONSTRAINT fk_tool_input_1 FOREIGN KEY(tool_id) REFERENCES workbench_tool(tool_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS workbench_tool_output;
CREATE TABLE workbench_tool_output (
     tool_output_id         INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,tool_id                INT UNSIGNED NOT NULL
    ,output_label           VARCHAR(255)
    ,output_name            VARCHAR(128)
    ,output_type            ENUM('NUMBER', 'TEXT', 'DATE', 'FILE')
    ,PRIMARY KEY(tool_output_id)
    ,CONSTRAINT fk_tool_output_1 FOREIGN KEY(tool_id) REFERENCES workbench_tool(tool_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  A "Tool Transform" represents an implementation that could
--  transform an "output" of a certain tool to an "input" of another tool.
-- 
DROP TABLE IF EXISTS workbench_tool_transform;
CREATE TABLE workbench_tool_transform (
     tool_transform_id              INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,input_tool_id                  INT UNSIGNED NOT NULL
    ,output_tool_id                 INT UNSIGNED NOT NULL
    ,transform_label                VARCHAR(255) NOT NULL
    ,transform_name                 VARCHAR(255) NOT NULL
    ,PRIMARY KEY(tool_transform_id)
    ,UNIQUE(transform_label)
    ,UNIQUE(transform_name)
    ,CONSTRAINT fk_tool_transform_1 FOREIGN KEY(input_tool_id) REFERENCES workbench_tool(tool_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_tool_transform_2 FOREIGN KEY(output_tool_id) REFERENCES workbench_tool(tool_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  The tools associated with a Workflow Step.
--  
--  "tool_number" is added so we can set a tool order.
-- 
DROP TABLE IF EXISTS workbench_workflow_step_tool;
CREATE TABLE workbench_workflow_step_tool (
     workflow_step_tool_id              INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,template_id                        INT UNSIGNED NOT NULL
    ,step_id                            INT UNSIGNED NOT NULL
    ,tool_number                        INT UNSIGNED NOT NULL
    ,tool_id                            INT UNSIGNED NOT NULL
    ,PRIMARY KEY(workflow_step_tool_id)
    ,UNIQUE(template_id, step_id, tool_id)
    ,CONSTRAINT fk_workflow_step_tool_1 FOREIGN KEY(template_id) REFERENCES workbench_workflow_template(template_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_workflow_step_tool_2 FOREIGN KEY(step_id) REFERENCES workbench_workflow_step(step_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_workflow_step_tool_3 FOREIGN KEY(tool_id) REFERENCES workbench_tool(tool_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  A project uses an instance of a "Workflow Template".
--  A project has one and only one workflow, which could be modified
--  later even after a project has made progress.
--  
--  A project has an instance of a "Workflow Template" to ensure that
--  a project's workflow can be modified without affecting all other
--  projects that followed the same template.
--  
--  "template_id" is the ID of the Workflow being used by the project.
--  "template_modified" specifies whether modifications on the original
--  Workflow steps has been made.
--  
--  TODO:
--  - a project has a data set
--  CONFIRM:
--  - what are datasets?
-- 
DROP TABLE IF EXISTS workbench_project;
CREATE TABLE workbench_project (
     project_id                 INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,user_id                    INT UNSIGNED NOT NULL
    ,project_name               VARCHAR(255) NOT NULL
    ,start_date                 DATE
    ,template_id                INT UNSIGNED NOT NULL
    ,template_modified          BOOL NOT NULL DEFAULT FALSE
    ,crop_type                  VARCHAR(32)
    ,local_db_name              VARCHAR(64)
    ,central_db_name            VARCHAR(64)
    ,last_open_date             TIMESTAMP NULL
	,local_schema_version       VARCHAR(32)
    ,PRIMARY KEY(project_id)
    ,CONSTRAINT fk_project_1 FOREIGN KEY(template_id) REFERENCES workbench_workflow_template(template_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_project_2 FOREIGN KEY(crop_type) REFERENCES workbench_crop(crop_name) ON UPDATE CASCADE
    ,CONSTRAINT uk_project_name UNIQUE(project_name)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  A "step" in a Project Workflow represents an "activity".
--  It can be assigned to a user (Contact), have a Due Date and a Status.
-- 
DROP TABLE IF EXISTS workbench_project_workflow_step;
CREATE TABLE workbench_project_workflow_step (
     project_workflow_step_id           INT UNSIGNED NOT NULL
    ,project_id                         INT UNSIGNED NOT NULL
    ,step_number                        VARCHAR(16) NOT NULL
    ,step_id                            INT UNSIGNED NOT NULL
    ,contact_id                         INT UNSIGNED
    ,due_date                           DATE
    ,status                             VARCHAR(255)
    ,PRIMARY KEY(project_workflow_step_id)
    ,UNIQUE(project_id, step_number)
    ,CONSTRAINT fk_project_workflow_step_1 FOREIGN KEY(project_id) REFERENCES workbench_project(project_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_project_workflow_step_2 FOREIGN KEY(step_id) REFERENCES workbench_workflow_step(step_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  CONFIRM:
--  - If we have a Workflow Step known to be associated with two tools, Tool A and Tool B,
--    can a project that has that Workflow Step declare that it will not use Tool B?
--    We might need to create a separate table if we support it (I hope we don't).
-- 
DROP TABLE IF EXISTS workbench_dataset;
CREATE TABLE workbench_dataset (
     dataset_id             INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,name                   VARCHAR(128) NOT NULL
    ,description            TEXT
    ,creation_date          DATE
    ,project_id             INT UNSIGNED NOT NULL
    ,type                   ENUM('STUDY', 'GERMPLASM_LIST')
    ,PRIMARY KEY(dataset_id)
    ,CONSTRAINT fk_workbench_dataset_1 FOREIGN KEY(project_id) REFERENCES workbench_project(project_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  The breeding method/s associated to a workbench project
-- 
DROP TABLE IF EXISTS workbench_project_method;
CREATE TABLE workbench_project_method (
     project_method_id           INT UNSIGNED AUTO_INCREMENT NOT NULL 
    ,project_id                  INT UNSIGNED NOT NULL
    ,method_id                   INT(11) NOT NULL
    ,PRIMARY KEY(project_method_id)
    ,UNIQUE(project_id, method_id)
    ,CONSTRAINT fk_project_method_1 FOREIGN KEY(project_id) REFERENCES workbench_project(project_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- The mapping of workbench users with corresponding ibdb local user.
--
DROP TABLE IF EXISTS workbench_ibdb_user_map;
CREATE TABLE workbench_ibdb_user_map (
     ibdb_user_map_id           INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,workbench_user_id          INT(11) NOT NULL
    ,project_id                 INT UNSIGNED NOT NULL
    ,ibdb_user_id               INT(11) NOT NULL
    ,PRIMARY KEY(ibdb_user_map_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- table for mapping workbench_project with location
--
DROP TABLE IF EXISTS workbench_project_loc_map;
CREATE TABLE workbench_project_loc_map (
     id                      INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,project_id              INT UNSIGNED NOT NULL
    ,location_id             INT(11) NOT NULL               
    ,PRIMARY KEY(id)
    ,CONSTRAINT fk_workbench_project_loc_map_1 FOREIGN KEY(project_id) REFERENCES workbench_project(project_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;


--
--  The activities performed by users in a project.
--
DROP TABLE IF EXISTS workbench_project_activity; 
CREATE TABLE workbench_project_activity (
     project_activity_id    INT UNSIGNED AUTO_INCREMENT NOT NULL 
    ,project_id                INT UNSIGNED NOT NULL
    ,name                    VARCHAR(128) NOT NULL
    ,description            TEXT
    ,user_id                INT(11) NOT NULL
    ,date                   TIMESTAMP
    ,PRIMARY KEY(project_activity_id)
    ,CONSTRAINT fk_project_activity_1 FOREIGN KEY(project_id) REFERENCES workbench_project(project_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_project_activity_2 FOREIGN KEY(user_id) REFERENCES users(userid) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- The workbench user roles.
-- 
DROP TABLE IF EXISTS workbench_role;
CREATE TABLE workbench_role (
     role_id INT UNSIGNED AUTO_INCREMENT
    ,name    VARCHAR(255)
    ,workflow_template_id INT UNSIGNED NOT NULL
    ,role_label VARCHAR(255)
    ,label_order INT
    ,CONSTRAINT workbench_role_pk PRIMARY KEY(role_id)
    ,CONSTRAINT fk_workbench_role_1 FOREIGN KEY(workflow_template_id) REFERENCES workbench_workflow_template(template_id) 
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  The users/s associated to a workbench project together with their roles.
-- 
DROP TABLE IF EXISTS workbench_project_user_role;
CREATE TABLE workbench_project_user_role (
     project_user_id            INT UNSIGNED AUTO_INCREMENT NOT NULL 
    ,project_id                 INT UNSIGNED NOT NULL
    ,user_id                    INT(11) NOT NULL
    ,role_id                     INT UNSIGNED NOT NULL
    ,PRIMARY KEY(project_user_id)
    ,UNIQUE(project_id, user_id, role_id)
    ,CONSTRAINT fk_project_user_role_1 FOREIGN KEY(project_id) REFERENCES workbench_project(project_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_project_user_role_2 FOREIGN KEY(role_id) REFERENCES workbench_role(role_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Mapping table of workbench users to their mysql username and password for each of their projects
--
DROP TABLE IF EXISTS workbench_project_user_mysql_account;
CREATE TABLE workbench_project_user_mysql_account (
     project_user_mysql_id      INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,project_id                 INT UNSIGNED NOT NULL
    ,user_id                    INT(11) NOT NULL
    ,mysql_username             VARCHAR(16) NOT NULL
    ,mysql_password             VARCHAR(16) NOT NULL
    ,PRIMARY KEY(project_user_mysql_id)
    ,UNIQUE(project_id, user_id)
    ,CONSTRAINT fk_project_user_mysql_1 FOREIGN KEY(project_id) REFERENCES workbench_project(project_id) ON UPDATE CASCADE
    ,CONSTRAINT fk_project_user_mysql_2 FOREIGN KEY(user_id) REFERENCES users(userid) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Workbench related settings/preferences.
--
DROP TABLE IF EXISTS workbench_setting;
CREATE TABLE workbench_setting (
     setting_id                 INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,installation_directory     VARCHAR(255)
    ,PRIMARY KEY(setting_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Tool Configuration table
--
DROP TABLE IF EXISTS workbench_tool_config;
CREATE TABLE workbench_tool_config(
     config_id               INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,tool_id                 INT UNSIGNED NOT NULL
    ,config_key              VARCHAR(255) NOT NULL
    ,config_value            VARCHAR(255) NOT NULL
    ,PRIMARY KEY(config_id)
    ,UNIQUE KEY(tool_id, config_key)
    ,CONSTRAINT fk_tool_config_1 FOREIGN KEY(tool_id) REFERENCES workbench_tool(tool_id) ON UPDATE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- This table is intended to contain workbench runtime data.
-- This data may be exposed to other tools via the Middleware.
--
DROP TABLE IF EXISTS workbench_runtime_data;
CREATE TABLE workbench_runtime_data (
     id                     INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,user_id                INT(11)
    ,PRIMARY KEY(id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Workbench user security questions
DROP TABLE IF EXISTS workbench_security_question;
CREATE TABLE workbench_security_question (
     security_question_id   INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,user_id                INT NOT NULL
    ,security_question      VARCHAR(255) NOT NULL
    ,security_answer        VARCHAR(255) NOT NULL
    ,PRIMARY KEY (security_question_id)
    ,CONSTRAINT fk_security_question_1 FOREIGN KEY(user_id) REFERENCES users(userid) ON DELETE CASCADE
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
-- workbench crops
--
DROP TABLE IF EXISTS workbench_crop;
CREATE TABLE IF NOT EXISTS workbench_crop(
     crop_name VARCHAR(32) NOT NULL
    ,central_db_name VARCHAR(64)
	,schema_version VARCHAR(32)
    ,PRIMARY KEY(crop_name)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Workbench Backup Project
DROP TABLE IF EXISTS workbench_project_backup;
CREATE TABLE workbench_project_backup (
     project_backup_id                INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,project_id                        INT UNSIGNED NOT NULL
    ,backup_path                    TEXT NOT NULL
    ,backup_time                    TIMESTAMP NOT NULL
      ,PRIMARY KEY(project_backup_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Workbench Project User info
--
DROP TABLE IF EXISTS workbench_project_user_info;
CREATE TABLE workbench_project_user_info (
      user_info_id             INT(10) unsigned NOT NULL AUTO_INCREMENT
      ,project_id                INT(10) unsigned NOT NULL
      ,user_id                 INT(11) NOT NULL
      ,last_open_date         TIMESTAMP NULL DEFAULT NULL
      ,PRIMARY KEY (user_info_id),
      UNIQUE KEY `project_id` (project_id,user_id),
      KEY `fk_workbench_project_user_info_idx` (project_id),
      KEY `fk_workbench_project_user_info_2_idx` (user_id),
      CONSTRAINT `fk_workbench_project_user_info_1` FOREIGN KEY (project_id) REFERENCES `workbench_project` (project_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
      CONSTRAINT `fk_workbench_project_user_info_2` FOREIGN KEY (user_id) REFERENCES `users` (`userid`) ON DELETE NO ACTION ON UPDATE NO ACTION
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Workbench user details
--
DROP TABLE IF EXISTS workbench_user_info; 
CREATE TABLE workbench_user_info (
  user_id INT NOT NULL,
  login_count INT NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 
--  Stores configuration of applications (e.g. Nursery Manager)
-- 
DROP TABLE IF EXISTS template_setting;
CREATE TABLE template_setting (
     template_setting_id         INT UNSIGNED AUTO_INCREMENT NOT NULL
    ,project_id		INT NOT NULL
    ,tool_id		INT UNSIGNED NOT NULL
    ,name		VARCHAR(75) NOT NULL
    ,configuration	TEXT NOT NULL
    ,is_default		TINYINT(1)
    ,PRIMARY KEY template_setting_pk (template_setting_id)
    ,UNIQUE KEY template_setting_uk1 (project_id, tool_id, name)
    ,CONSTRAINT fk_templatesetting_workbench_tool_1 FOREIGN KEY(tool_id) REFERENCES workbench_tool(tool_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET foreign_key_checks = @OLD_FOREIGN_KEY_CHECKS;