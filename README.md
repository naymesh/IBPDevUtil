IBP Development Utilities
=========================

Here's how you create a working BMS environment on your local Linux/Mac machine from scratch.

## Prerequisite Software

If you do not have any of the following installed, follow the instructions.

### MySQL

Download and install the latest version of the [community edition](http://dev.mysql.com/downloads/mysql/).

You will need to add mysql to your path. When you restart your computer, the MySQL daemon should be running. To start it immediately, you can run `sudo /Library/StartupItems/MySQLCOM/MySQLCOM start`.

You will probably also want to install [MySQL Workbench](http://www.mysql.com/products/workbench) and [MySQL Utilities](https://dev.mysql.com/downloads/tools/utilities/) to assist in working with your MySQL databases.

### Tomcat

Download and extract [version 7.0.50](http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.50/bin/apache-tomcat-7.0.50.zip) of Tomcat.

**NOTE:** It is important that you do not use a version more recent than 7.0.50, due to an issue with load time weaving in 7.0.51+.

### JDK

Install the latest Java 7.x JDK and set the JAVA_HOME variable.

### Maven

Install the latest version of [Maven](http://maven.apache.org/download.cgi) and follow the installation instructions.

### Groovy

Install the latest version of [Groovy](http://groovy.codehaus.org) and follow the installation instructions.

## Project Code

Checkout all BMS projects from Git:
* `git clone https://github.com/digitalabs/IBPMiddleware`
* `git clone https://github.com/digitalabs/IBPCommons`
* `git clone https://github.com/digitalabs/GermplasmStudyBrowser`
* `git clone https://github.com/digitalabs/BreedingManager`
* `git clone https://github.com/digitalabs/DatasetImporter`
* `git clone https://github.com/digitalabs/Fieldbook`
* `git clone https://github.com/digitalabs/IBPWorkbench`

## Configuring Tomcat

### Load Time Weaving

This is one off Tomcat setting required to deal with [Spring Load Time Weaving] used by IBP workbench.

* Download `spring-instrument-3.1.1.RELEASE.jar` and save it to a known location.
* Alter the `-javaagent` property in the `CATALINA_OPTS` variable in `tomcat_settings/setenv.sh` to be the location of `spring-instrument-3.1.1.RELEASE.jar`.
* Copy the `tomcat_settings/setenv.sh` file into your `TOMCAT_HOME/bin` directory (this file probably does not already exist but if it does, add to it). Tomcat will pick this file up (check in `catalina.sh` if you like) when it starts.

### Tomcat Port

* Popular/default tomcat port used by IBP applications is 18080. Configure the default tomcat Connector in `TOMCAT_HOME/conf/server.xml` to listen on 18080 instead of the default 8080.

## Create DB Schema

The groovy script DROPS YOUR EXISTING DB COMPLETELY so backup first, if you need to.

* Configure `config.properties` to point to your MySQL instance
* Run `groovy createschema.groovy`. To see Grapes being downloaded (useful for first time running), add verbose Grape handling to your command `groovy -Dgroovy.grape.report.downloads=true createschema.groovy`

The groovy script:

* Drops and creates the `workbench` schema
* Registers Crops and Tools in workbench schema
* Drops and creates central and local database schema for one sample crop e.g. `ibdbv2_rice_central` and `ibdbv2_rice_local`
* Applies the update scripts that create views, procedures etc. in workbench, local and central schema

## Build the Projects

* Project configuration can be found in `{project-folder}/pipeline/config`. You can use an existing folder to start with, or create a new folder with your own configuration. At a minimum, ensure any config you are using has the correct settings to connect to your local MySQL database.
* Build each project by running `mvn clean antrun:run install -DenvConfig=[config_folder]`, where `config_folder` is the folder above. Be aware that you need to build Middleware first, and Commons second (as it depends on Middleware). The rest can be built in any order - each depending only on Commons.

**Note:** There is an issue with the tests running at the moment - please add `-DskipTests` to skip the tests and allow the build to pass.

## Load Crop Data

The crop data files are often large, so we do not keep these in Git. Follow these directions to load:

1. Download the crop installer exe from the [Efficio GCP confluence]. Rename the extension from `.exe` to `.zip` and use the command line tool to unzip, i.e. `unzip installer.zip -d destination_folder`.
2. Open script `database/crop/rice/loadRice.sh` for editing
	* Set `DATA\_SCRIPT\_LOCATION` to refer to the directory where you extracted the crop data dump sql files.
	* Set `USER`, `PASSWORD`, `PORT` and `CENTRAL_CROP_DB` values as per your local MySQL instance setup.
3. Setting `max_allowed_packet=64M` in MySQL(d) configuration (usually `/etc/my.cnf`) will be helpful. Otherwise you may see `ERROR 2006 (HY000) at line 17: MySQL server has gone away` when loading some large scripts, which is not good. If this is the first item in your configuration file, be aware you need to include it in a group. If this is the only thing in your file, you can use:
```
[mysqld]
max_allowed_packet	= 50M
```
4. `cd database/crop/rice`
5. `./loadRice.sql`

## Deploy Wars to Tomcat

Configure the scripts located in `deploy_scripts` to reflect your system configuration (tomcat and checkout location). Be aware that the checkout location is the root directory where all your project folders are.

Each script in the `deploy_scripts` directory does the following:
* stops Tomcat (doesn't matter if it is already stopped)
* sleeps for 15 seconds to make sure it is stopped
* copies the war(s)
* starts tomcat

### Which Script to Run
* **deploy_all.sh**: Stops Tomcat - copies 5 war files into tomcat/webapps. Please configure your Tomcat home dir (TOMCAT_SERVER), and the directory where all of your checkouts reside (CHECKOUT_HOME), we copy from the Maven target dir of each project.
* **deploy_app.sh**: For Single apps APART FROM Workbench. Configure as above. Example usage is `./deploy_app.sh Fieldbook`.
* **deploy_wb.sh**: Deploys workbench. No parameters required.

Usually you'll just want to run `./deploy_all.sh`.

Errors on copy will be written to console. Watch the Tomcat logs for progress.

[Efficio GCP confluence]:http://confluence.efficio.us.com/display/GCP/Download+Links+for+Installers+for+UAT+Testing
[Spring Load TIme Weaving]:http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/#aop-aj-ltw

