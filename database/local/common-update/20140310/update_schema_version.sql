DROP TABLE IF EXISTS schema_version;
CREATE TABLE schema_version (
    version     VARCHAR(32)
    ,PRIMARY KEY (version)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_version(version) VALUES ('20130310');
