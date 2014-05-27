USER=root
PASSWORD=
PORT=13306
CENTRAL_CROP_DB=ibdbv2_maize_central
DATA_SCRIPT_LOCATION=/Users/rebecca/cropdbs/maizeDB-2.1.3/database/central/maize/full

echo 'Loading file 1 : DMS_CV'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/02_ibdbv2_maize_DMS_CV_20140421.sql

echo 'Loading file 2 : DMS'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/03_ibdbv2_maize_DMS_20131210.sql

echo 'Loading file 3 : GDMS'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/ibdbv2_maize_GDMS_20131108.sql

echo 'Loading file 4 : GMS'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/ibdbv2_maize_gms_20140403.sql

echo 'Loading file 5 : trim cvterm'
mysql -u $USER -P$PORT $CENTRAL_CROP_DB < $DATA_SCRIPT_LOCATION/zz_trim_cv_term.sql



