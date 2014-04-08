TOMCAT_SERVER=/Users/rebecca/servers/apache-tomcat-7.0.50

$TOMCAT_SERVER/bin/shutdown.sh
sleep 15
rm $TOMCAT_SERVER/webapps/ibpworkbench.war
rm -rf $TOMCAT_SERVER/webapps/ibpworkbench
cp /Users/rebecca/git/IBPWorkbench/target/ibpworkbench-1.1.3.6.war $TOMCAT_SERVER/webapps/ibpworkbench.war
$TOMCAT_SERVER/bin/catalina.sh start
