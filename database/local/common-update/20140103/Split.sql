DELIMITER $$

DROP PROCEDURE if exists split$$
CREATE PROCEDURE `split`(genid int, p_levelno int, id_list MEDIUMTEXT, delimiter_str varchar(10))
BEGIN

  # routine that takes in a list of values delimited by delimeter_str, performs a split and returns the results
  # via a temporary table. Any stored procs that use this will need to reference the temptbl directly.

  declare i, current_pos, next_pos int default 1;
  declare id varchar(2000);
  declare done boolean default false;

  drop temporary table if exists temptbl;
  create temporary table temptbl (id int, levelno int, `value` varchar(2000));


  myloop: LOOP

    set next_pos = locate(delimiter_str, id_list, current_pos);

    if (next_pos = 0) then
	  set next_pos = length(id_list)+1;
  	  set done = true;
    end if;

    set id = (select substring(id_list,current_pos, next_pos-current_pos));

    insert into temptbl(id, levelno, `value`) values(genid, p_levelno, trim(id));
    set genid = genid - 1;
    set p_levelno = p_levelno - 1;

    if (done) then
	   LEAVE myloop;
    end if;

    set current_pos = next_pos+length(delimiter_str);

  end LOOP;

  -- select * from temptbl;

END$$

DELIMITER ;

