REPLACE INTO cv(cv_id,name,definition) VALUES
 (1000, 'IBDB TERMS', 'CV of terms used to annotate relationships and identify objects in the ibdb database')
,(2005,'8006','Study status - Assigned (code)')
,(2010,'8070','Study type - assigned (type)');

REPLACE INTO cvterm(cvterm_id,cv_id,name,definition,dbxref_id,is_obsolete,is_relationshiptype) VALUES
 (1110,1000,'Numeric variable','Variable with numeric values either continuous or integer',null,0,0)
,(1113,1000,'Minimum value','Minimum value allowed for a numeric variable',null,0,0)
,(1115,1000,'Maximum value','Maximum value allowed for a numeric variable',null,0,0)
,(1117,1000,'Date variable','Date - numeric value in format yyyymmdd with least significant parts set to zero acording to precision',null,0,0)
,(1118,1000,'Numeric DBID  variable','Integer database ID (may be negative)',null,0,0)
,(1120,1000,'Character  variable','Variable with character values',null,0,0)
,(1125,1000,'Timestamp  variable','Character variable in format yyyy-mm-dd:hh:mm:ss:nnn with least significant parts omitted acording to precision',null,0,0)
,(1128,1000,'Character DBID  variable','Character database ID',null,0,0)
,(1130,1000,'Categorical  variable','Variable with discrete class values (numeric or character all treated as character)',null,0,0)
,(10000,2010,'N','Nursery',null,0,0)
,(10001,2010,'HB','Hybridization nursery',null,0,0)
,(10002,2010,'PN','Pedigree nursery',null,0,0)
,(10003,2010,'CN','Characterization nursery',null,0,0)
,(10005,2010,'OYT','Observational yield trial',null,0,0)
,(10007,2010,'BON','BULU observational nursery',null,0,0)
,(10010,2010,'T','Trial',null,0,0)
,(10015,2010,'RYT','Replicated yield trial',null,0,0)
,(10017,2010,'OFT','On farm trial',null,0,0)
,(10020,2010,'S','Survey',null,0,0)
,(10030,2010,'E','Experiment',null,0,0)
,(12960,2005,'1','Active study visable to all users with access',null,0,0)
,(12970,2005,'2','Active study visable to owner only',null,0,0)
,(12980,2005,'3','Locked study visable to all users with access',null,0,0)
,(12990,2005,'9','Deleted study',null,0,0)
;

REPLACE INTO nd_geolocation (nd_geolocation_id, description) VALUES
(1, '0');
