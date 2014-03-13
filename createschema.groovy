@GrabConfig(systemClassLoader=true)
@Grab(group='mysql', module='mysql-connector-java', version='5.1.29')
@Grab(group='commons-io', module='commons-io', version='2.4')
@Grab(group='commons-dbutils', module='commons-dbutils', version='1.5')

import org.apache.commons.io.FileUtils
import org.apache.commons.io.LineIterator
import org.apache.commons.dbutils.QueryRunner
import org.apache.commons.dbutils.DbUtils
import org.apache.commons.dbutils.ResultSetHandler
import org.apache.commons.dbutils.handlers.ArrayListHandler

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.DriverManager;
import java.sql.Statement;

public class ScriptRunner {

  private static final String LINE_SEPARATOR = System.getProperty("line.separator", "\n");

  private static final String DEFAULT_DELIMITER = ";";

  private Connection connection;

  private boolean stopOnError;
  private boolean autoCommit;
  private boolean sendFullScript;
  private boolean removeCRs;
  private boolean escapeProcessing = true;
  private boolean logSqlError = true;

  private PrintWriter logWriter = new PrintWriter(System.out);
  private PrintWriter errorLogWriter = new PrintWriter(System.err);

  private String delimiter = DEFAULT_DELIMITER;
  private boolean fullLineDelimiter = false;

  public ScriptRunner(Connection connection) {
    this.connection = connection;
  }
  
  public ScriptRunner(Connection connection, boolean autoCommit, boolean stopOnError) {
      this.connection = connection;
      this.autoCommit = autoCommit;
      this.stopOnError = stopOnError;
  }

  public void runScript(Reader reader) {
    setAutoCommitInternal();

    try {
      if (sendFullScript) {
        executeFullScript(reader);
      } else {
        executeLineByLine(reader);
      }
    } finally {
      rollbackConnection();
    }
  }

  private void executeFullScript(Reader reader) {
    StringBuilder script = new StringBuilder();
    try {
      BufferedReader lineReader = new BufferedReader(reader);
      String line;
      while ((line = lineReader.readLine()) != null) {
        script.append(line);
        script.append(LINE_SEPARATOR);
      }
      executeStatement(script.toString());
      commitConnection();
    } catch (Exception e) {
      String message = "Error executing: " + script + ".  Cause: " + e;
      printlnError(message);
      throw new RuntimeException(message, e);
    }
  }

  private void executeLineByLine(Reader reader) {
    StringBuilder command = new StringBuilder();
    try {
      BufferedReader lineReader = new BufferedReader(reader);
      String line;
      while ((line = lineReader.readLine()) != null) {
        command = handleLine(command, line);
      }
      commitConnection();
      checkForMissingLineTerminator(command);
    } catch (Exception e) {
      String message = "Error executing: " + command + ".  Cause: " + e;
      printlnError(message);
      throw new RuntimeException(message, e);
    }
  }

  public void closeConnection() {
    try {
      connection.close();
    } catch (Exception e) {
      // ignore
    }
  }

  private void setAutoCommitInternal() {
    try {
      if (autoCommit != connection.getAutoCommit()) {
        connection.setAutoCommit(autoCommit);
      }
    } catch (Throwable t) {
      throw new RuntimeException("Could not set AutoCommit to " + autoCommit + ". Cause: " + t, t);
    }
  }

  private void commitConnection() {
    try {
      if (!connection.getAutoCommit()) {
        connection.commit();
      }
    } catch (Throwable t) {
      throw new RuntimeException("Could not commit transaction. Cause: " + t, t);
    }
  }

  private void rollbackConnection() {
    try {
      if (!connection.getAutoCommit()) {
        connection.rollback();
      }
    } catch (Throwable t) {
      // ignore
    }
  }

  private void checkForMissingLineTerminator(StringBuilder command) {
    if (command != null && command.toString().trim().length() > 0) {
      throw new RuntimeException("Line missing end-of-line terminator (" + delimiter + ") => " + command);
    }
  }

  private StringBuilder handleLine(StringBuilder command, String line) throws SQLException, UnsupportedEncodingException {
    String trimmedLine = line.trim();
    if (lineIsComment(trimmedLine)) {
      //println(trimmedLine);
    }
    else if (lineIsDelimier(trimmedLine)) {
        //println(trimmedLine);
        String[] tokens = trimmedLine.split("\\s+");
        if (tokens.length >= 2) {
            delimiter = tokens[1];
        }
    }
    else if (commandReadyToExecute(trimmedLine)) {
      command.append(line.substring(0, line.lastIndexOf(delimiter)));
      command.append(LINE_SEPARATOR);
      //println(command);
      executeStatement(command.toString());
      command.setLength(0);
      System.gc();
    } else if (trimmedLine.length() > 0) {
      command.append(line);
      command.append(LINE_SEPARATOR);
    }
    return command;
  }

  private boolean lineIsComment(String trimmedLine) {
    return trimmedLine.startsWith("//") || trimmedLine.startsWith("--");
  }
  
  private boolean lineIsDelimier(String trimmedLine) {
      return trimmedLine.toLowerCase().startsWith("delimiter");
  }

  private boolean commandReadyToExecute(String trimmedLine) {
    // issue #561 remove anything after the delimiter
    return !fullLineDelimiter && trimmedLine.contains(delimiter) || fullLineDelimiter && trimmedLine.equals(delimiter);
  }

  protected void executeStatement(String command) throws SQLException, UnsupportedEncodingException {
    boolean hasResults = false;
    Statement statement = connection.createStatement();
    statement.setEscapeProcessing(escapeProcessing);
    String sql = command;
    if (removeCRs)
      sql = sql.replaceAll("\r\n", "\n");
    if (stopOnError) {
      hasResults = statement.execute(sql);
    } else {
      try {
        hasResults = statement.execute(sql);
      } catch (SQLException e) {
          if (logSqlError) {
              String message = "Error executing: " + command + ".  Cause: " + e;
              printlnError(message);
          }
      }
    }
    printResults(statement, hasResults);
    try {
      statement.close();
    } catch (Exception e) {
      // Ignore to workaround a bug in some connection pools
    }
  }

  private void printResults(Statement statement, boolean hasResults) {
    try {
      if (hasResults) {
        ResultSet rs = statement.getResultSet();
        if (rs != null) {
          ResultSetMetaData md = rs.getMetaData();
          int cols = md.getColumnCount();
          for (int i = 0; i < cols; i++) {
            String name = md.getColumnLabel(i + 1);
            print(name + "\t");
          }
          println("");
          while (rs.next()) {
            for (int i = 0; i < cols; i++) {
              String value = rs.getString(i + 1);
              print(value + "\t");
            }
            println("");
          }
        }
      }
    } catch (SQLException e) {
      printlnError("Error printing results: " + e.getMessage());
    }
  }

  private void print(Object o) {
    if (logWriter != null) {
      logWriter.print(o);
      logWriter.flush();
    }
  }

  private void println(Object o) {
    if (logWriter != null) {
      logWriter.println(o);
      logWriter.flush();
    }
  }

  private void printlnError(Object o) {
    if (errorLogWriter != null) {
      errorLogWriter.println(o);
      errorLogWriter.flush();
    }
  }

}

def config = new Properties()
new File("config.properties").withInputStream { 
  stream -> config.load(stream) 
}

String connectionUrl = String.format("jdbc:mysql://%s:%s/?user=%s&password=%s&useUnicode=true&characterEncoding=utf8", 
    
                                    config["db.host"], config["db.port"], config["db.user"], config["db.password"])

String installationDir = config["misc.IBPInstallDir"];

Class.forName("com.mysql.jdbc.Driver");
Connection conn = DriverManager.getConnection(connectionUrl);

//PART 1 - InitializeWorkbenchDatabaseAction.runWorkbenchScripts

println "\n** Creating workbench schema **"

QueryRunner queryRunner = new QueryRunner()

queryRunner.update(conn, "CREATE DATABASE IF NOT EXISTS workbench");
queryRunner.update(conn, "GRANT ALL ON workbench.* TO 'workbench'@'localhost' IDENTIFIED BY 'workbench'")
queryRunner.update(conn, "USE workbench")

def executeScript(Connection connection, File sqlFile) throws IOException {
    
    BufferedReader br = null;
    
    print "Running script : ${sqlFile.path} ..."

    try {
        
        br = new BufferedReader(new InputStreamReader(new FileInputStream(sqlFile)));
        ScriptRunner scriptRunner = new ScriptRunner(connection, false, true);
        scriptRunner.runScript(br);

    } finally {
        if (br != null) {
             br.close();
        }
    }

    println "Done."
}

queryRunner.update(conn, "USE workbench");

executeScript(conn, new File("database/workbench/IBDBv1_Workbench_Project.sql"))

//will this table ever have muliple rows?
queryRunner.update(conn, "INSERT INTO workbench.workbench_setting(installation_directory) VALUES (?)", installationDir) 


//PART 2 - InitializeWorkbenchDatabaseAction.registerCrops

println "\n** Registering central crop schema names **"

enum Crop {
     BEAN(      "bean",         "ibdbv2_bean_central",          "ibdbv2_bean_central_light",        "ibdbv2_bean_local"),
     CASSAVA(   "cassava",      "ibdbv2_cassava_central",       "ibdbv2_cassava_central_light",     "ibdbv2_cassava_local"),
     CHICKPEA(  "chickpea",     "ibdbv2_chickpea_central",      "ibdbv2_chickpea_central_light",    "ibdbv2_chickpea_local"),
     COWPEA(    "cowpea",       "ibdbv2_cowpea_central",        "ibdbv2_cowpea_central_light",      "ibdbv2_cowpea_local"),
     GROUNDNUT( "groundnut",    "ibdbv2_groundnut_central",     "ibdbv2_groundnut_central_light",   "ibdbv2_groundnut_local"),
     MAIZE(     "maize",        "ibdbv2_maize_central",         "ibdbv2_maize_central_light",       "ibdbv2_maize_local"),
     RICE(      "rice",         "ibdbv2_rice_central",          "ibdbv2_rice_central_light",        "ibdbv2_rice_local"),
     SORGHUM(   "sorghum",      "ibdbv2_sorghum_central",       "ibdbv2_sorghum_central_light",     "ibdbv2_sorghum_local"),
     PHASEOLUS( "phaseolus",    "ibdbv2_phaseolus_central",     "ibdbv2_phaseolus_central_light",   "ibdbv2_phaseolus_local"),
     WHEAT(     "wheat",        "ibdbv2_wheat_central",         "ibdbv2_wheat_central_light",       "ibdbv2_wheat_local"),
     LENTIL(    "lentil",       "ibdbv2_lentil_central",        "ibdbv2_lentil_central_light",      "ibdbv2_lentil_local"),
     SOYBEAN(   "soybean",      "ibdbv2_soybean_central",       "ibdbv2_soybean_central_light",     "ibdbv2_soybean_local");
    
    final String cropName;
    final String centralDatabaseName;
    final String centralLightDatabaseName;
    final String localDatabaseName;
    
    
    Crop(String cropName, String centralDatabaseName, String centralLightDatabaseName, String localDatabaseName) {
        this.cropName = cropName;
        this.centralDatabaseName = centralDatabaseName;
        this.centralLightDatabaseName = centralLightDatabaseName;
        this.localDatabaseName = localDatabaseName;
    }
}

queryRunner.update(conn, "SET FOREIGN_KEY_CHECKS=0")

ResultSetHandler<List<Object[]>> rsHandler = new ResultSetHandler<List<Object[]>>() {
    public List<Object[]> handle(ResultSet rs) throws SQLException {        
        
        List<Object[]> results = new ArrayList<Object[]>();
        while(rs.next()) {
            Object [] row = new ArrayListHandler().handleRow(rs)
            results.add(row)
        }
        return results
    }
}

for(Crop c : Crop.values()) {
    //def dbChekResult = queryRunner.query(conn, " SELECT count(*) AS count FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ? ", rsHandler, c.centralDatabaseName)
    //if(dbChekResult [0][0] == 1)
    // For dev environment, register all the common crops
    queryRunner.update(conn, "INSERT INTO workbench.workbench_crop (crop_name, central_db_name) VALUES (?, ?)", c.cropName, c.centralDatabaseName);
}

//PART 3 - InitializeWorkbenchDatabaseAction.registerTools

enum Tool {
    mbdt(1, "mbdt", "mbdt", "MBDT","1.0.3","NATIVE","tools/mbdt/MBDT.exe","",0),
    
    optimas(2, "optimas", "optimas", "OptiMAS", "1.4", "NATIVE", "tools/optimas/optimas_gui.exe","",0),
    
    fieldbook(3, "fieldbook", "fieldbook", "FieldBook", "4.0.8", "NATIVE", "tools/fieldbook/IBFb/bin/ibfb.exe","--ibpApplication=IBFieldbookTools",0),
    
    breeding_view(4, "breeding_view", "breeding_view", "Breeding View", "1.1.0.12243", "NATIVE", "tools/breeding_view/Bin/BreedingView.exe","",0),
    
    breeding_manager(5, "breeding_manager", "breeding_manager", "Breeding Manager", "4.0.8", "NATIVE", "tools/fieldbook/IBFb/bin/ibfb.exe","--ibpApplication=BreedingManager",0),
    
    germplasm_browser(6, "germplasm_browser", "germplasm_browser", "Browse Germplasm Information", "1.2.0", "WEB", "http://localhost:18080/GermplasmStudyBrowser/main/germplasm/","",0),
    
    study_browser(7, "study_browser", "study_browser", "Browse Studies and Datasets", "1.2.0", "WEB", "http://localhost:18080/GermplasmStudyBrowser/main/study/","",0),
    
    germplasm_list_browser(8, "germplasm_list_browser", "germplasm_list_browser", "Browse Germplasm Lists", "1.2.0", "WEB", "http://localhost:18080/GermplasmStudyBrowser/main/germplasmlist/","",0),
    
    gdms(9, "gdms", "gdms", "GDMS", "2.0", "WEB_WITH_LOGIN", "http://localhost:18080/GDMS/login.do","",0),
    
    list_manager(10, "list_manager", "list_manager", "List Manager", "1.1.1.0", "WEB", "http://localhost:18080/BreedingManager/main/germplasm-import/","",0),
    
    crossing_manager(11, "crossing_manager", "crossing_manager", "Crossing Manager", "1.2.0", "WEB", "http://localhost:18080/BreedingManager/main/crosses/","",0),
    
    nursery_template_wizard(12, "nursery_template_wizard", "nursery_template_wizard", "Nursery Template Wizard", "1.1.1.0", "WEB", "http://localhost:18080/BreedingManager/main/nursery-template/","",0),
    
    breeding_planner(13, "breeding_planner", "breeding_planner","Breeding Planner","1.0","NATIVE","tools/breeding_planner/breeding_planner.exe","",0),
    
    //ibfb_germplasm_import(14, "ibfb_germplasm_import", "ibfb_germplasm_import","Fieldbook Germplasm Import","4.0.0","NATIVE","tools/fieldbook/IBFb/bin/ibfb.exe","--ibpApplication=GermplasmImport",0)
    
    germplasm_import(15, "germplasm_import", "germplasm_import","Germplasm Import","1.0.0","WEB","http://localhost:18080/BreedingManager/main/germplasm-import/","",0),
    
    //germplasm_head_to_head(16, "germplasm_headtohead", "germplasm_headtohead","Fieldbook Germplasm Head To Head","1.0.0-BETA","WEB","http://localhost:18080/GermplasmStudyBrowser/main/h2h-query?restartApplication","",0),
    
    germplasm_mainheadtohead(17, "germplasm_mainheadtohead", "germplasm_mainheadtohead","Fieldbook Germplasm MAIN Head To Head","1.0.0-BETA","WEB","http://localhost:18080/GermplasmStudyBrowser/main/Head_to_head_comparison","",0),
    
    dataset_importer(18, "dataset_importer", "dataset_importer", "Data Import Tool", "1.0", "WEB", "http://localhost:18080/DatasetImporter/","",0),
    
    query_for_adapted_germplasm(19, "query_for_adapted_germplasm", "query_for_adapted_germplasm","Query For Adapted Germplasm","1.0","WEB","http://localhost:18080/GermplasmStudyBrowser/main/Query_For_Adapted_Germplasm","",0),
    
    breeding_view_wb(20, "breeding_view_wb", "breeding_view","Single-Site Analysis","1.0","WORKBENCH","http://localhost:18080/ibpworkbench/main/#/breeding_view","",0),
    
    breeding_gxe(21, "breeding_gxe", "breeding_gxe", "Multi-Site Analysis","1.0","WORKBENCH","http://localhost:18080/ibpworkbench/main/#/BreedingGxE","",0),
    
    bm_list_manager(22, "bm_list_manager", "bm_list_manager", "List Manager", "1.1.1.0", "WEB", "http://localhost:18080/BreedingManager/main/listmanager/","",0),
    
    fieldbook_web(23, "fieldbook_web", "fieldbook_web", "Fieldbook Web", "1.1.1.0", "WEB", "http://localhost:18080/Fieldbook","",0),
    
    nursery_manager_fieldbook_web(24, "nursery_manager_fieldbook_web", "nursery_manager_fieldbook_web", "Fieldbook Web - Nursery Manager", "1.1.1.0", "WEB", "http://localhost:18080/Fieldbook/NurseryManager","",0),
    
    trial_manager_fieldbook_web(25, "trial_manager_fieldbook_web", "trial_manager_fieldbook_web", "Fieldbook Web - Trial Manager", "1.1.1.0", "WEB", "http://localhost:18080/Fieldbook/TrialManager ","",0),
    
    ontology_browser_fieldbook_web(26, "ontology_browser_fieldbook_web", "ontology_browser_fieldbook_web", "Fieldbook Web - Ontology Browser", "1.1.1.0", "WEB", "http://localhost:18080/Fieldbook/OntologyBrowser","",0),
    
    bv_meta_analysis(27, "bv_meta_analysis", "bv_meta_analysis","Meta Analysis of Field Trials","1.0","WORKBENCH","http://localhost:18080/ibpworkbench/main/#/bv_meta_analysis","",0),
    
    bm_list_manager_main(28, "bm_list_manager_main", "bm_list_manager_main", "List Manager", "1.1.1.0", "WEB", "http://localhost:18080/BreedingManager/main/list-manager/","",0),
    
    study_browser_with_id(29, "study_browser_with_id", "study_browser_with_id", "Browse Studies and Datasets", "1.2.0", "WEB", "http://localhost:18080/GermplasmStudyBrowser/main/studybrowser/","",0);
     
    final int toolId;
    final String toolName;
    final String groupName;
    final String title;
    final String version;
    final String type;
    final String path;
    final String parameter;
    final int userTool;
    
    Tool(int toolId, String toolName, String groupName, String title, String version, String type, String path, String parameter, int userTool) {
        this.toolId = toolId;
        this.toolName = toolName;
        this.groupName = groupName;
        this.title = title;
        this.version = version;
        this.type = type;
        this.path = path;
        this.parameter = parameter;
        this.userTool = userTool;
    }

}

println "\n** Registering IBP Tools in workbench.workbench_tool  **"

for(Tool t : Tool.values()) {

	def toolPath = t.type == "NATIVE" ? installationDir + File.separator + t.path : t.path

	queryRunner.update(conn, "REPLACE INTO workbench.workbench_tool (tool_id, name, group_name, title, version, tool_type, path, parameter, user_tool) VALUES (?,?,?,?,?,?,?,?,?)", 
		t.toolId, t.toolName, t.groupName, t.title, t.version, t.type, toolPath, t.parameter, t.userTool)
}

queryRunner.update(conn, "SET FOREIGN_KEY_CHECKS=1")

def runScriptsInDir(Connection conn, File scriptDir) {

    if(scriptDir.exists()) {  
      File[] sqlFiles = scriptDir.listFiles(new FilenameFilter() {
                  public boolean accept(File dir, String name) {
                      return name.endsWith(".sql");
                  }
              });

      for(File f : sqlFiles) {
          executeScript(conn, f)
      }
  }
}


// PART 4 - Create the central and local schema for one sample crop

println "\n** Creating the central schema for one sample crop **"

String centralCropDB = config["db.crop.central"]

queryRunner.update(conn, "CREATE DATABASE ${centralCropDB} character set utf8 collate utf8_general_ci")
queryRunner.update(conn, "USE ${centralCropDB}")

runScriptsInDir(conn, new File("database/central/common"))


println "\n** Creating the local schema for one sample crop **"

String localCropDB = config["db.crop.local"]
queryRunner.update(conn, "CREATE DATABASE ${localCropDB} character set utf8 collate utf8_general_ci")
queryRunner.update(conn, "USE ${localCropDB}")
runScriptsInDir(conn, new File("database/local/common"))


// PART 5 - Install4JUtil.updateCentralDatabases (Run sqls for central crops from database/central/common-update)

println "\n** Applying updates to the central crop schema just created **"

//def result = queryRunner.query(conn, " SELECT central_db_name FROM workbench.workbench_crop ", rsHandler)

def dbChekResult = queryRunner.query(conn, " SELECT count(*) AS count FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ? ", rsHandler, centralCropDB)

if(dbChekResult [0][0] == 1) {
    queryRunner.update(conn, "USE " + centralCropDB);      
    runScriptsInDir(conn, new File("database/central/common-update"))
}

// PART 6 - Install4JUtil.updateLocalDatabases (Run sqls for central crops from database/local/common-update)

println "\n** Applying updates to the local crop schema just created **"

dbChekResult = queryRunner.query(conn, " SELECT count(*) AS count FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ? ", rsHandler, localCropDB)

if(dbChekResult [0][0] == 1) {
    queryRunner.update(conn, "USE " + localCropDB);      
    runScriptsInDir(conn, new File("database/local/common-update"))
}

DbUtils.close(conn);  

println "All Done! Success!"
