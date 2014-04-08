IBP Development Utilities
=========================

Here's how you create a working BMS environment on your local Linux/Mac machine from scratch

### First Time Only - set Tomcat to deal with Spring Configurable beans (Load TIme Weaving) ###

Copy the tomcat_settings/setenv.sh file into your TOMCAT_HOME/bin directory (there will not be one there when you install Tomcat, if there is then add to it). Tomcat will pick this file up (check in catalina.sh if you like) when it starts.

### Create DB Schemas (workbench, crop central) ###

The following configuration must be declared 

* config.properties (MySQL connection data, Installation directory -- the BMSstores this in the DB - it is used to find crop data) ..... TODO : check what else this is used for

Run `groovy createschema.groovy`.

To see Grapes being downloaded (useful for first time running), add verbose Grape handling to your command
'groovy -Dgroovy.grape.report.downloads=true createschema.groovy'

The groovy script DROPS YOUR EXISTING DB COMPLETELY - backup if you need to.

The script :

* Drops and creates the `workbench` schema
* Registers Crops and Tools in workbench schema
* Drops and creates central and local database schema for one sample crop e.g. `ibdbv2_rice_central` and `ibdbv2_rice_local`
* Applies the update scripts that create views, procedures etc. in workbench, local and central schema


### Load Crop Data ###

The crop data files are often large, so we do not keep these in Git - but everything else is here. 

Follow these directions to load 

1. Either : 
    * scp from our Linux server
    * download crop installer exe, extract (anywhere else, not into this IBPDevUtil source tree), and configure the loadRice.sh script to refer to this directory as the source for the crop files
2. cd database/crop/rice
3. If not done previously, set path config in loadRice.sh. We copy files in and out of this directory so we do not accidentally commit to Git
4. ./loadRice.sql

Let me know how the script progress feedback goes .....

### Build Code ###

* checkout all BMS working projects from Git
* configure as necessary in pipeline/config/[yourname]
* build each project 'mvn clean antrun:run install -DenvConfig=rebecca [your_chosen_env_here]'

Projects :
git clone https://github.com/digitalabs/IBPCOmmons
git clone https://github.com/digitalabs/IBPMiddleware
git clone https://github.com/digitalabs/GermplasmStudyBrowser
git clone https://github.com/digitalabs/BreedingManager
git clone https://github.com/digitalabs/DatasetImporter
git clone https://github.com/digitalabs/Fieldbook
git clone https://github.com/digitalabs/IBPWorkbench


### Deploy Wars to Tomcat ###

1. cd deploy_scripts
2. Configure your scripts
3. run a script. Here is a guide to them all

All scripts : 
* stop Tomcat (doesn't matter if it is already stopped)
* sleep 15 seconds to make sure it is stopped
* copy
* start tomcat

Errors on copy to console. Watch the Tomcat logs for progress

**deploy_all.sh** : Stops Tomcat - copies 5 war files into tomcat/webapps. Please configure your Tomcat home dir, and the directory where all of your checkouts reside (we copy from the MVN target dir)

**deploy_app.sh** : For Single apps APART FROM Workbench. Configure as above. Example usage is './deploy_app.sh Fieldbook'

**deploy_wb.sh** : deploys workbench. No parameters required