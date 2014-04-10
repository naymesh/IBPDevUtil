IBP Development Utilities
=========================

Here's how you create a working BMS environment on your local Linux/Mac machine from scratch

### Create DB Schema ###

The groovy script DROPS YOUR EXISTING DB COMPLETELY so backup first, if you need to.

* Configre `config.properties` to point to your MySQL instance
* Run `groovy createschema.groovy`
* To see Grapes being downloaded (useful for first time running), add verbose Grape handling to your command `groovy -Dgroovy.grape.report.downloads=true createschema.groovy`

The groovy script:

* Drops and creates the `workbench` schema
* Registers Crops and Tools in workbench schema
* Drops and creates central and local database schema for one sample crop e.g. `ibdbv2_rice_central` and `ibdbv2_rice_local`
* Applies the update scripts that create views, procedures etc. in workbench, local and central schema

### Load Crop Data ###

The crop data files are often large, so we do not keep these in Git - but everything else is here. Follow these directions to load:

1. Download crop installer exe e.g. from the [Efficio GCP confluence], extract/unzip (anywhere else, not into this IBPDevUtil source tree)
2. Open script `database/crop/rice/loadRice.sh` for editing
	* Set DATA\_SCRIPT\_LOCATION to refer to the directory where you extracted the crop data dump sql files.
	* Set USER, PASSWORD, PORT and CENTRAL_CROP_DB values as per your local MySQL instance setup.
3. Setting `max_allowed_packet=64M` in MySQL(d) configuration (usually `/etc/my.cnf`) will be helpful. Otherwise you may see `ERROR 2006 (HY000) at line 17: MySQL server has gone away` when loading some large scripts, which is not good.
4. `cd database/crop/rice`
5. `./loadRice.sql`

### Build Code ###

* Checkout all BMS working projects from Git:
	* `git clone https://github.com/digitalabs/IBPCommons`
	* `git clone https://github.com/digitalabs/IBPMiddleware`
	* `git clone https://github.com/digitalabs/GermplasmStudyBrowser`
	* `git clone https://github.com/digitalabs/BreedingManager`
	* `git clone https://github.com/digitalabs/DatasetImporter`
	* `git clone https://github.com/digitalabs/Fieldbook`
	* `git clone https://github.com/digitalabs/IBPWorkbench`

* Configure properties as necessary in pipeline/config/[yourname] or use an existing dir
* Build each project `mvn clean antrun:run install -DenvConfig=[your_chosen_env_here]`

### Configure Tomcat ###

Load Time Weaving

* This is one off Tomcat setting required to deal with [Spring Load Time Weaving] used by IBP workbench. 
* Set the path to where your `spring-instrument-3.1.1.RELEASE.jar` is in `tomcat_settings/setenv.sh`
* Copy the `tomcat_settings/setenv.sh` file into your `TOMCAT_HOME/bin` directory (there will not be one there when you install Tomcat, if there is then add to it). Tomcat will pick this file up (check in catalina.sh if you like) when it starts.

Tomcat Port

* Popular/default tomcat port used by IBP applications is 18080. Configure the default tomcat Connector in `TOMCAT_HOME/conf/server.xml` to listen on 18080 instead of the default 8080. 

*NOTE:* Recommended version of Tomcat is 7.0.50. Load time weaving related things are broken in 7.0.51 and above versions of Tomcat.

### Deploy Wars to Tomcat ###

1. cd deploy_scripts
2. Configure your scripts
3. run a script.
4. All scripts: 
	* stop Tomcat (doesn't matter if it is already stopped)
	* sleep 15 seconds to make sure it is stopped
	* copy
	* start tomcat
5. **deploy_all.sh** : Stops Tomcat - copies 5 war files into tomcat/webapps. Please configure your Tomcat home dir (TOMCAT_SERVER), and the directory where all of your checkouts reside (CHECKOUT_HOME), we copy from the Maven target dir of each project.
6. **deploy_app.sh** : For Single apps APART FROM Workbench. Configure as above. Example usage is `./deploy_app.sh Fieldbook`.
7. **deploy_wb.sh** : deploys workbench. No parameters required.

Errors on copy to console. Watch the Tomcat logs for progress


[Efficio GCP confluence]:http://confluence.efficio.us.com/display/GCP/Download+Links+for+Installers+for+UAT+Testing
[Spring Load TIme Weaving]:http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/#aop-aj-ltw

