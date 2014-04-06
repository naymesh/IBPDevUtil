START TRANSACTION;

UPDATE schema_version SET
    version = '20130519'
;

CREATE TABLE IF NOT EXISTS workbench_user_info (
    user_id INT NOT NULL
    ,login_count INT NOT NULL DEFAULT 0
    ,PRIMARY KEY (user_id)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

COMMIT;