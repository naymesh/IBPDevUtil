ALTER TABLE listnms ENGINE = MYISAM;

ALTER TABLE listnms ADD FULLTEXT INDEX(listname);

CREATE INDEX index_liststatus ON listnms(liststatus);

CREATE INDEX index_listname ON listnms(listname);

CREATE INDEX index_desig ON listdata(desig);

