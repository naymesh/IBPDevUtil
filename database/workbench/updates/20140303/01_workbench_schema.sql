SET @ORIGINAL_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @ORIGINAL_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @ORIGINAL_SQL_MODE=@@SQL_MODE, SQL_MODE='ALLOW_INVALID_DATES,NO_AUTO_VALUE_ON_ZERO,NO_AUTO_CREATE_USER';

UPDATE schema_version SET
    version = '20140303'
;

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


SET FOREIGN_KEY_CHECKS=@ORIGINAL_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@ORIGINAL_UNIQUE_CHECKS;
SET SQL_MODE=@ORIGINAL_SQL_MODE;
