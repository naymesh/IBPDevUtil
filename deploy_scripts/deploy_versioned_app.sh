TOMCAT_SERVER=/Users/rebecca/servers/apache-tomcat-7.0.50
VERSION=1.2.0

$TOMCAT_SERVER/bin/shutdown.sh
sleep 15
rm $TOMCAT_SERVER/webapps/$1.war
rm -rf $TOMCAT_SERVER/webapps/$1
cp /Users/rebecca/git/$1/target/$1-$VERSION.war $TOMCAT_SERVER/webapps/$1.war
$TOMCAT_SERVER/bin/startup.sh
