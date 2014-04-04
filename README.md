IBP Development Utilities
=========================

Point `config.properties` to your MySQL instance and run `groovy createschema.groovy`.

To see Grapes being downloaded (useful for first time running), add verbose Grape handling to your command
'groovy -Dgroovy.grape.report.downloads=true createschema.groovy'

The groovy script

* Creates the `workbench` schema
* Registers Crops and Tools in workbench schema
* Creates central and local database schema for one sample crop e.g. `ibdbv2_rice_central` and `ibdbv2_rice_local`
* Applies the update scripts that create views, procedures etc. in workbench, local and central schema

TODO
* Data loading into the central crop database.



