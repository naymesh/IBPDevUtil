DROP TABLE IF EXISTS `listdataprops`;

CREATE TABLE `listdataprops` ( 
  `listdataprop_id` int(11) NOT NULL AUTO_INCREMENT, 
  `listdata_id` int(11) NOT NULL DEFAULT '0', 
  `column_name` varchar(50) NOT NULL DEFAULT '-', 
  `value` varchar(255), 
  PRIMARY KEY (`listdataprop_id`) 
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

ALTER TABLE `listnms` ADD COLUMN(
  `notes` TEXT
);