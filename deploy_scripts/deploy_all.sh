
TOMCAT_SERVER=/Users/naymesh/servers/tomcat
CHECKOUT_HOME=/Users/naymesh/src/gcp

echo 'Shutting down Tomcat..'

$TOMCAT_SERVER/bin/shutdown.sh
sleep 15

echo 'Removing currently deployed wars..'
cd $TOMCAT_SERVER/webapps
rm *.war
rm -rf $TOMCAT_SERVER/webapps/DatasetImporter
rm -rf $TOMCAT_SERVER/webapps/GermplasmStudyBrowser
rm -rf $TOMCAT_SERVER/webapps/BreedingManager
rm -rf $TOMCAT_SERVER/webapps/Fieldbook
rm -rf $TOMCAT_SERVER/webapps/ibpworkbench

echo 'Deploying latest wars..'
cp $CHECKOUT_HOME/DatasetImporter/target/DatasetImporter.war $TOMCAT_SERVER/webapps/
cp $CHECKOUT_HOME/GermplasmStudyBrowser/target/GermplasmStudyBrowser-1.2.0.war $TOMCAT_SERVER/webapps/GermplasmStudyBrowser.war
cp $CHECKOUT_HOME/BreedingManager/target/BreedingManager-1.2.0.war $TOMCAT_SERVER/webapps/BreedingManager.war
cp $CHECKOUT_HOME/Fieldbook/target/Fieldbook.war $TOMCAT_SERVER/webapps/
cp $CHECKOUT_HOME/IBPWorkbench/target/ibpworkbench-1.1.3.6.war $TOMCAT_SERVER/webapps/ibpworkbench.war

echo 'Starting Tomcat..'
$TOMCAT_SERVER/bin/startup.sh
