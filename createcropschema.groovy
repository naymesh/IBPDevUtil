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

// -------- START SCRIPT HERE -------------------
//-----------------------------------------------
//-----------------------------------------------

def config = new Properties()
new File("config.properties").withInputStream { 
  stream -> config.load(stream) 
}

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

def runScriptsInDir(Connection conn, File scriptDir) {

    // We need to implicitly sort by name, because on Linux alphanumeric name sort is seemingly not the default
    if(scriptDir.exists()) {  
      File[] sqlFiles = scriptDir.listFiles(new FilenameFilter() {
                  public boolean accept(File dir, String name) {
                      return name.endsWith(".sql");
                  }
              }).sort{ file -> file.getName() };
 
      for(File f : sqlFiles) {
          executeScript(conn, f)
      }
  }
}

String connectionUrl = String.format("jdbc:mysql://%s:%s/?user=%s&password=%s&useUnicode=true&characterEncoding=utf8", 
    
                                    config["db.host"], config["db.port"], config["db.user"], config["db.password"])

String installationDir = config["misc.IBPInstallDir"];

println("Read config");
println("Connection : " + connectionUrl);
println("Installation Dir : " + installationDir);

Class.forName("com.mysql.jdbc.Driver");
Connection conn = DriverManager.getConnection(connectionUrl);

QueryRunner queryRunner = new QueryRunner()

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

// PART 4 - Create the central and local schema for one sample crop

String centralCropDB = config["db.crop.central"]
String localCropDB = config["db.crop.local"]

println "\n**** Dropping Crop DBs in order to refreh ***"

queryRunner.update(conn, "DROP SCHEMA IF EXISTS ${centralCropDB}")
queryRunner.update(conn, "DROP SCHEMA IF EXISTS ${localCropDB}")

println "\n** Creating the central schema for one sample crop **"


queryRunner.update(conn, "CREATE DATABASE ${centralCropDB} character set utf8 collate utf8_general_ci")
queryRunner.update(conn, "USE ${centralCropDB}")

runScriptsInDir(conn, new File("database/central/common"))


println "\n** Creating the local schema for one sample crop **"

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

println "Loaded " + centralCropDB
println "Loaded " + localCropDB
println "All Done! Success! "
