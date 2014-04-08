
TOMCAT_SERVER=/Users/rebecca/servers/apache-tomcat-7.0.50

$TOMCAT_SERVER/bin/shutdown.sh
sleep 15
cd $TOMCAT_SERVER/webapps
rm *.war
rm -rf $TOMCAT_SERVER/webapps/DatasetImporter
rm -rf $TOMCAT_SERVER/webapps/GermplasmStudyBrowser
rm -rf $TOMCAT_SERVER/webapps/BreedingManager
rm -rf $TOMCAT_SERVER/webapps/Fieldbook
rm -rf $TOMCAT_SERVER/webapps/ibpworkbench
cp /Users/rebecca/git/DatasetImporter/target/DatasetImporter.war $TOMCAT_SERVER/webapps/
cp /Users/rebecca/git/GermplasmStudyBrowser/target/GermplasmStudyBrowser-1.2.0.war $TOMCAT_SERVER/webapps/GermplasmStudyBrowser.war
cp /Users/rebecca/git/BreedingManager/target/BreedingManager-1.2.0.war $TOMCAT_SERVER/webapps/BreedingManager.war
cp /Users/rebecca/git/Fieldbook/target/Fieldbook.war $TOMCAT_SERVER/webapps/
cp /Users/rebecca/git/IBPWorkbench/target/ibpworkbench-1.1.3.6.war $TOMCAT_SERVER/webapps/ibpworkbench.war
$TOMCAT_SERVER/bin/startup.sh
