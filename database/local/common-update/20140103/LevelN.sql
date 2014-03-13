DELIMITER $$

DROP PROCEDURE IF EXISTS `addLevelN`$$

CREATE PROCEDURE `addLevelN`(
  IN labelidin int
  , IN factoridin int
  , IN lvaluein double
  , IN levelno_v int
  , IN v_storedinid int)

BEGIN

	-- declare v_storedinid INT;
	
	declare v_projectid INT;
	declare v_termid varchar(255);
	declare v_rankint INT; 
        declare v_propid INT;
	
	-- SELECT storedinid 
	--   INTO v_storedinid
      -- FROM v_factor
     -- WHERE projectprop_id = labelidin  limit 1; 
	
	IF(v_storedinid = 1010 or v_storedinid = 1015) THEN
		select p.project_id, p.value, p.rank, pp.projectprop_id
                  into v_projectid, v_termid, v_rankint, v_propid 
                  from projectprop p
                  left join projectprop pp on pp.project_id = p.project_id AND pp.type_id = p.type_id AND pp.rank = p.rank
                 where p.projectprop_id = labelidin;

                IF (v_propid IS NULL) THEN 
                    -- call getNextMinReturn('projectprop', @newppid);
                    select IF(min(projectprop_id) is NULL or min(projectprop_id) >= 0, -1, min(projectprop_id) -1)  
                      INTO @newppid 
                      from projectprop;

                    insert into projectprop (projectprop_id,project_id,type_id,value,rank) value ( @newppid, v_projectid, v_termid, lvaluein, v_rankint);
                END IF;
    	/*
	IF(v_storedinid = 1011) THEN
		-- assumption is info was added when project is added already
		;
    END IF;
	IF(v_storedinid = 1012) THEN
		-- assumption is info was added when project is added already
		;
    END IF;
	
	IF(v_storedinid = 1016) THEN
		-- assumption is info was added when project is added already
		;
    END IF;
	IF(v_storedinid = 1017) THEN
		-- assumption is info was added when project is added already
		;
    END IF;
	*/
    ELSEIF(v_storedinid = 1020) THEN	 
	select p.project_id, p.value, p.rank, gp.nd_geolocationprop_id
          into v_projectid, v_termid, v_rankint, v_propid 
          from projectprop p
          left join nd_geolocationprop gp on gp.nd_geolocation_id=levelno_v AND gp.type_id=v_termid AND gp.rank=0
         where p.projectprop_id = labelidin;

	-- ND_GEOLOCATIONPROP unique constraint | ND_GEOLOCATION_ID, TYPE_ID, RANK
        IF (v_propid IS NULL) THEN
                -- call getNextMinReturn('nd_geolocationprop', @newgeoid);
                select IF(min(nd_geolocationprop_id) is NULL or min(nd_geolocationprop_id) >= 0, -1, min(nd_geolocationprop_id) -1)  
                  INTO @newgeoid 
                  from nd_geolocationprop;
                insert into nd_geolocationprop (nd_geolocationprop_id, nd_geolocation_id, type_id, value, rank) value (@newgeoid, levelno_v, v_termid , lvaluein, 0);
	END IF;

   	
    ELSEIF(v_storedinid = 1021) THEN
		update nd_geolocation set description = lvaluein where nd_geolocation_id = levelno_v;
    
    ELSEIF(v_storedinid = 1022) THEN
		update nd_geolocation set latitude = lvaluein where nd_geolocation_id = levelno_v;
    
    ELSEIF(v_storedinid = 1023) THEN
		update nd_geolocation set longitude = lvaluein where nd_geolocation_id = levelno_v;
    
    ELSEIF(v_storedinid = 1024) THEN
		update nd_geolocation set geodetic_datum = lvaluein where nd_geolocation_id = levelno_v;
    
    ELSEIF(v_storedinid = 1025) THEN
		update nd_geolocation set altitude = lvaluein where nd_geolocation_id = levelno_v;
    
    ELSEIF(v_storedinid = 1030) THEN
		select p.project_id, p.value, p.rank, ep.nd_experimentprop_id
                  into v_projectid, v_termid, v_rankint, v_propid 
                  from projectprop p
                  left join nd_experimentprop ep on ep.nd_experiment_id=levelno_v AND ep.type_id=v_termid AND ep.rank=0
                 where p.projectprop_id = labelidin;
		
-- ND_EXPERIMENTPROP unique constraint | ND_EXPERIMENT_ID, TYPE_ID, RANK
		IF (v_propid IS NULL) THEN
                        -- call getNextMinReturn('nd_experimentprop', @newexpid);
                        select IF(min(nd_experimentprop_id) is NULL or min(nd_experimentprop_id) >= 0, -1, min(nd_experimentprop_id) -1)  
                          INTO @newexpid 
                          from nd_experimentprop;

                        insert into nd_experimentprop (nd_experimentprop_id, nd_experiment_id,type_id,value,rank) value (@newexpid, levelno_v, v_termid , lvaluein, 0);
		END IF;
		
    ELSEIF(v_storedinid = 1040) THEN
		select p.project_id, p.value, p.rank, sp.stockprop_id
                  into v_projectid, v_termid, v_rankint, v_propid 
                  from projectprop p
                  left join stockprop sp on sp.stock_id=levelno_v AND sp.type_id=v_termid AND sp.rank=0
                 where p.projectprop_id = labelidin;

		-- STOCKPROP unique constraint | STOCK_ID, TYPE_ID, RANK
                IF (v_propid IS NULL) THEN
                    	-- call getNextMinReturn('stockprop', @newstockpropid);
                        select IF(min(stockprop_id) is NULL or min(stockprop_id) >= 0, -1, min(stockprop_id) -1)  
                          INTO @newstockpropid from stockprop;

                        insert into stockprop (stockprop_id,stock_id,type_id,value,rank) value (@newstockpropid, levelno_v, v_termid , lvaluein, 0);
		END IF;
    
    ELSEIF(v_storedinid = 1041) THEN
			update stock set uniquename = lvaluein where stock_id = levelno_v;
    
    ELSEIF(v_storedinid = 1042) THEN
			update stock set dbxref_id = lvaluein where stock_id = levelno_v;
    
    ELSEIF(v_storedinid = 1046) THEN
			update stock set name = lvaluein where stock_id = levelno_v;
    
    ELSEIF(v_storedinid = 1047) THEN
			update stock set value = lvaluein where stock_id = levelno_v;
    END IF;
	

END$$




DROP PROCEDURE IF EXISTS `updateLevelN`$$

CREATE PROCEDURE `updateLevelN`(
  IN labelidin int
  , IN factoridin int
  , IN levelnoin int
  , IN lvaluein double)

BEGIN

	DECLARE v_storedinid INT;
	DECLARE v_projectid INT;
	
	SELECT storedinid, project_id 
	  INTO v_storedinid, v_projectid
      FROM v_factor
     WHERE projectprop_id = labelidin; 
	
	IF (v_storedinid = 1010 OR v_storedinid = 1015) THEN
		UPDATE v_factor stdvar 
	     INNER JOIN projectprop pval ON pval.type_id = stdvar.varid AND pval.project_id = stdvar.project_id AND pval.rank = stdvar.rank
		   SET pval.value = lvaluein
		 WHERE stdvar.projectprop_id = labelidin;
    END IF;
	
	IF (v_storedinid = 1011 OR v_storedinid = 1016) THEN			
		UPDATE project
		   SET name = lvaluein
		 WHERE project_id = v_projectid;
    END IF;

	IF (v_storedinid = 1012 OR v_storedinid = 1017) THEN
		UPDATE project
		   SET description = lvaluein
		 WHERE project_id = v_projectid;
    END IF;
	
	IF (v_storedinid = 1020) THEN
		UPDATE nd_geolocationprop gp
		 INNER JOIN v_factor stdvar ON stdvar.varid = gp.type_id
		   SET gp.value = lvaluein
		 WHERE gp.nd_geolocation_id = levelnoin
		   AND stdvar.projectprop_id = labelidin;
    END IF;
	
	IF (v_storedinid = 1021) THEN
		UPDATE nd_geolocation 
           SET description = lvaluein 
         WHERE nd_geolocation_id = levelnoin;
    END IF;

	IF (v_storedinid = 1022) THEN
		UPDATE nd_geolocation 
		   SET latitude = lvaluein 
		 WHERE nd_geolocation_id = levelnoin;
    END IF;

	IF (v_storedinid = 1023) THEN
		UPDATE nd_geolocation 
           SET longitude = lvaluein 
		 WHERE nd_geolocation_id = levelnoin;
    END IF;

	IF (v_storedinid = 1024) THEN
		UPDATE nd_geolocation 
           SET geodetic_datum = lvaluein 
		 WHERE nd_geolocation_id = levelnoin;
    END IF;

	IF (v_storedinid = 1025) THEN
		UPDATE nd_geolocation 
           SET altitude = lvaluein 
         WHERE nd_geolocation_id = levelnoin;
    END IF;
	
	IF (v_storedinid = 1030) THEN
		UPDATE nd_experimentprop exp
		 INNER JOIN v_factor stdvar ON stdvar.varid = exp.type_id
		   SET value = lvaluein
		 WHERE exp.nd_experiment_id = levelnoin
		   AND stdvar.projectprop_id = labelidin;	
    END IF;

	IF (v_storedinid = 1040) THEN		
		UPDATE stockprop sp
		 INNER JOIN v_factor stdvar ON stdvar.varid = sp.type_id
		   SET sp.value = lvaluein
		 WHERE sp.stock_id = levelnoin
		  and stdvar.projectprop_id = labelidin;
    END IF;

	IF (v_storedinid = 1041) THEN
		UPDATE stock 
           SET uniquename = lvaluein 
		 WHERE stock_id = levelnoin;
    END IF;
	IF(v_storedinid = 1042) THEN
		UPDATE stock 
           SET dbxref_id = lvaluein 
		 WHERE stock_id = levelnoin;
    END IF;

	IF (v_storedinid = 1046) THEN
		UPDATE stock 
           SET name = lvaluein 
		 WHERE stock_id = levelnoin;
    END IF;

	IF (v_storedinid = 1047) THEN
		UPDATE stock 
           SET value = lvaluein 
		 WHERE stock_id = levelnoin;
    END IF;
	

END$$

DELIMITER ;
