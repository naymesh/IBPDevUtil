START TRANSACTION;

UPDATE schema_version SET
    version = '20140116'
;

UPDATE workbench_sidebar_category SET
	sidebar_category_label = 'Marker-Assisted Breeding'
WHERE
	sidebar_category_id = 4
;

COMMIT;
