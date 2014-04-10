USER=root
PASSWORD=
PORT=3306
CENTRAL_CROP_DB=ibdbv2_rice_central
DATA_SCRIPT_LOCATION=/Users/naymesh/work/gcp/dbdumps/cropdata/rice/2.0.8

echo 'Loading file 1 : GMS_1'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/01_ibdbv2_rice_GMS_20140127.sql

echo 'Loading file 2 : GMS_2'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/02_ibdbv2_rice_GMS_20130924.sql

echo 'Loading file 3 : GMS_3 (larger file)'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/03_ibdbv2_rice_GMS_20130924.sql

echo 'Loading file 4 : GMS_4'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/04_ibdbv2_rice_GMS_20131212.sql

echo 'Loading file 5 : GMS_5 (larger)'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/05_ibdbv2_rice_GMS_20130924.sql

echo 'Loading file 6 : GMS_6'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/06_ibdbv2_rice_GMS_20130504.sql

echo 'Loading file 7 : DMS_CV'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/07_ibdbv2_rice_DMS_CV_20140128.sql

echo 'Loading file 8 : DMS'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/08_ibdbv2_rice_DMS_20131213.sql

echo 'Loading file 9 : GDMS'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/ibdbv2_rice_GDMS_20131212.sql

echo 'Loading file 10 : Updates'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < post-load-updates/update-listnms.sql


