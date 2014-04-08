START TRANSACTION;

UPDATE schema_version SET
    version = '20140311'
;

UPDATE nd_geolocation SET description=1 WHERE nd_geolocation_id = 1;

COMMIT;
