START TRANSACTION;

UPDATE schema_version SET
    version = '20140123'
;

DELETE FROM workbench.workbench_tool WHERE
name IN ('ibfb_germplasm_import', 'germplasm_headtohead');

COMMIT;
