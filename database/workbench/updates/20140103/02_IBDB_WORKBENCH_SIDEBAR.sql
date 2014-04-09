DROP TABLE IF EXISTS workbench_sidebar_category_link;
DROP TABLE IF EXISTS workbench_sidebar_category;

CREATE TABLE workbench_sidebar_category (
    sidebar_category_id             INT(11) NOT NULL AUTO_INCREMENT,
    sidebar_category_name           VARCHAR(255) NOT NULL,
    sidebar_category_label          VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (sidebar_category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table workbench_sidebar_category
--
LOCK TABLES workbench_sidebar_category WRITE;
INSERT INTO workbench_sidebar_category VALUES 
 (1,'activities','Breeding Activities')
,(2,'information_mgt','Information Management')
,(3,'statistical_analysis','Statistical Analysis')
,(4,'marker_assisted_breeding','Marker Assisted Breeding')
,(5,'additional_tools','Additional Tools')
,(6,'workflows','Workflows')
,(7,'admin','Program Administration');
UNLOCK TABLES;

--
-- Table structure for table workbench_sidebar_category_link
--

CREATE TABLE workbench_sidebar_category_link (
    sidebar_category_link_id        INT(11) NOT NULL AUTO_INCREMENT,
    tool_name                       VARCHAR(128) NOT NULL,
    sidebar_category_id             INT(11) NOT NULL,
    sidebar_link_name               VARCHAR(255) DEFAULT NULL,
    sidebar_link_title              VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (sidebar_category_link_id),
    KEY sidebar_category_id_idx (sidebar_category_id),
    KEY tool_name (tool_name),
    CONSTRAINT sidebar_category_id FOREIGN KEY (sidebar_category_id) REFERENCES workbench_sidebar_category (sidebar_category_id) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_tool_name FOREIGN KEY (tool_name) REFERENCES workbench_tool (name) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES workbench_sidebar_category_link WRITE;
INSERT INTO workbench_sidebar_category_link VALUES 
 (1,'bm_list_manager_main',1,'manage_list','Manage Lists')
,(2,'crossing_manager',1,'manage_crosses','Make Crosses')
,(3,'nursery_manager_fieldbook_web',1,'manage_nurseries','Manage Nurseries')
,(4,'trial_manager_fieldbook_web',1,'manage_trials','Manage Trials')
/*,(5,'bm_list_manager_main',2,'bm_list_manager','List Manager')*/
/*,(5,'ibfb_germplasm_import',2,'ibfb_germlasm_import','IBFB Germplasm Import')*/
,(5,'germplasm_import',2,'germplasm_import','Import Germplasm')
/*,(7,'germplasm_browser',2,'germplasm_import','Browse Germplasm')*/
,(6,'gdms',2,'gdms','Manage Genotyping Data')
,(7,'study_browser',2,'study_browser','Browse Studies')
,(8,'germplasm_mainheadtohead',2,'main_hxh','Head to Head Query')
,(9,'query_for_adapted_germplasm',2,'adopted_query','Adapted Germplasm Query')
,(10,'ontology_browser_fieldbook_web',2,'ontology_browser_fieldbook_web','Manage Ontologies')
,(11,'breeding_view_wb',3,'breeding_view_wb','Single-Site Analysis')
,(12,'breeding_gxe',3,'breeding_gxe','Multi-Site Analysis')
,(13,'bv_meta_analysis',3,'bv_meta_analysis','Multi-Year Multi-Site Analysis')
,(14,'breeding_view',3,'breeding_view','Breeding View Standalone for QTL')
,(15,'mbdt',4,'mbdt','Molecular Breeding Design Tool')
,(16,'optimas',4,'optimas','Molecular Breeding Decision Tool: OptiMAS')
,(17,'breeding_planner',4,'mbp','Molecular Breeding Planner');

UNLOCK TABLES;
