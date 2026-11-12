package com.codequest.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

/**
 * Application Lifecycle Listener for CodeQuest
 * Automatically initializes database connections, verifies schema integrity,
 * and provisions missing tables and missions upon application deployment.
 */
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext ctx = sce.getServletContext();
        System.out.println("==========================================================");
        System.out.println("[AppContextListener] Booting CodeQuest Platform Engine...");

        // 1. Check web.xml context parameters
        String webXmlUrl = ctx.getInitParameter("db.url");
        String webXmlUser = ctx.getInitParameter("db.user");
        String webXmlPass = ctx.getInitParameter("db.password");

        if (webXmlUrl != null && !webXmlUrl.trim().isEmpty()) {
            System.out.println("[AppContextListener] Configuring DB credentials from web.xml context-params");
            DBConnection.configure(webXmlUrl, webXmlUser, webXmlPass);
        }

        // 2. Test database connectivity and auto-provision schema
        String activeUrl = DBConnection.getDbUrl();
        String activeUser = DBConnection.getDbUser();
        System.out.println("[AppContextListener] Active Database URL: " + activeUrl);
        System.out.println("[AppContextListener] Active Database User: " + activeUser);

        try (Connection conn = DBConnection.getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            System.out.println("[AppContextListener] Connected to: " + meta.getDatabaseProductName() + " v" + meta.getDatabaseProductVersion());

            // Check if core tables exist
            if (!tableExists(conn, "users") || !tableExists(conn, "missions")) {
                System.out.println("[AppContextListener] Core tables missing. Executing database bootstrap...");
                executeSchemaBootstrap(conn, ctx);
            } else {
                System.out.println("[AppContextListener] Core tables verified. Database is online and ready.");
            }
        } catch (SQLException e) {
            System.err.println("[AppContextListener WARNING] Database initialization could not complete at startup: " + e.getMessage());
            System.err.println("[AppContextListener WARNING] CodeQuest will continue booting and retry on demand.");
        }

        System.out.println("==========================================================");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AppContextListener] Shutting down CodeQuest Platform Engine...");
        // Deregister JDBC drivers to prevent Tomcat memory leaks
        java.util.Enumeration<java.sql.Driver> drivers = java.sql.DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            java.sql.Driver driver = drivers.nextElement();
            try {
                java.sql.DriverManager.deregisterDriver(driver);
            } catch (SQLException ignored) {
            }
        }
    }

    private boolean tableExists(Connection conn, String tableName) {
        try {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getTables(conn.getCatalog(), null, tableName, new String[]{"TABLE"})) {
                if (rs.next()) return true;
            }
            // Case-insensitive check
            try (ResultSet rs = meta.getTables(conn.getCatalog(), null, tableName.toUpperCase(), new String[]{"TABLE"})) {
                if (rs.next()) return true;
            }
            try (ResultSet rs = meta.getTables(conn.getCatalog(), null, tableName.toLowerCase(), new String[]{"TABLE"})) {
                if (rs.next()) return true;
            }
        } catch (Exception e) {
            System.err.println("[AppContextListener] Error checking table " + tableName + ": " + e.getMessage());
        }
        return false;
    }

    private void executeSchemaBootstrap(Connection conn, ServletContext ctx) {
        InputStream is = getClass().getResourceAsStream("/codequest_db.sql");
        if (is == null) {
            is = ctx.getResourceAsStream("/WEB-INF/classes/codequest_db.sql");
        }
        if (is == null) {
            System.err.println("[AppContextListener] Schema resource /codequest_db.sql not found. Executing manual DDL...");
            createTablesDirectly(conn);
            return;
        }

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
             Statement stmt = conn.createStatement()) {

            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                // Skip comments and empty lines
                if (line.isEmpty() || line.startsWith("--") || line.startsWith("//") || line.startsWith("/*")) {
                    continue;
                }
                // Skip database creation / switching if not supported or redundant
                if (line.toUpperCase().startsWith("CREATE DATABASE") || line.toUpperCase().startsWith("USE ")) {
                    continue;
                }
                sb.append(line).append(" ");
                if (line.endsWith(";")) {
                    String sql = sb.toString().trim();
                    if (sql.endsWith(";")) {
                        sql = sql.substring(0, sql.length() - 1).trim();
                    }
                    if (!sql.isEmpty()) {
                        try {
                            stmt.execute(sql);
                        } catch (SQLException ex) {
                            System.err.println("[AppContextListener] SQL Notice on bootstrap statement: " + ex.getMessage());
                        }
                    }
                    sb.setLength(0);
                }
            }
            System.out.println("[AppContextListener] Schema bootstrap execution finished successfully.");
        } catch (Exception e) {
            System.err.println("[AppContextListener] Error executing schema bootstrap: " + e.getMessage());
            createTablesDirectly(conn);
        }
    }

    private void createTablesDirectly(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            stmt.execute("CREATE TABLE IF NOT EXISTS users ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "username VARCHAR(50) NOT NULL UNIQUE, "
                    + "email VARCHAR(100) NOT NULL UNIQUE, "
                    + "password VARCHAR(255) NOT NULL, "
                    + "xp INT NOT NULL DEFAULT 0, "
                    + "level INT NOT NULL DEFAULT 1, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ") ENGINE=InnoDB");

            stmt.execute("CREATE TABLE IF NOT EXISTS admins ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "username VARCHAR(50) NOT NULL UNIQUE, "
                    + "password VARCHAR(255) NOT NULL, "
                    + "full_name VARCHAR(100) NOT NULL, "
                    + "email VARCHAR(100) NOT NULL UNIQUE, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ") ENGINE=InnoDB");

            stmt.execute("CREATE TABLE IF NOT EXISTS missions ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "type ENUM('code', 'mcq') NOT NULL DEFAULT 'mcq', "
                    + "title VARCHAR(200) NOT NULL, "
                    + "description TEXT NOT NULL, "
                    + "category VARCHAR(50) NOT NULL, "
                    + "difficulty VARCHAR(20) NOT NULL, "
                    + "xp_reward INT NOT NULL DEFAULT 50, "
                    + "function_name VARCHAR(100) NULL, "
                    + "language VARCHAR(50) DEFAULT 'javascript', "
                    + "starter_code TEXT NULL, "
                    + "test_cases TEXT NULL, "
                    + "option_a VARCHAR(255) NULL, "
                    + "option_b VARCHAR(255) NULL, "
                    + "option_c VARCHAR(255) NULL, "
                    + "option_d VARCHAR(255) NULL, "
                    + "correct_option CHAR(1) NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                    + ") ENGINE=InnoDB");

            stmt.execute("CREATE TABLE IF NOT EXISTS mission_submissions ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "user_id INT NOT NULL, "
                    + "mission_id INT NOT NULL, "
                    + "type ENUM('code', 'mcq') NOT NULL DEFAULT 'mcq', "
                    + "selected_option CHAR(1) NULL, "
                    + "submitted_code TEXT NULL, "
                    + "execution_time_ms DOUBLE NULL, "
                    + "is_correct BOOLEAN NOT NULL, "
                    + "xp_awarded INT NOT NULL DEFAULT 0, "
                    + "submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "CONSTRAINT uq_user_mission UNIQUE (user_id, mission_id), "
                    + "FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, "
                    + "FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE"
                    + ") ENGINE=InnoDB");

            // Seed default admin if empty
            stmt.execute("INSERT INTO admins (username, password, full_name, email) "
                    + "SELECT 'admin', 'PBKDF2$65536$vh0v23OvKWBCGqoPGFf22w==$yHInlVZLv5tmmpl4m2w0FA0UbKporwLrCvu09mMmGfk=', 'Chief Game Master', 'admin@codequest.dev' "
                    + "WHERE NOT EXISTS (SELECT 1 FROM admins WHERE username = 'admin')");

            System.out.println("[AppContextListener] Core tables and default admin verified via direct DDL.");
        } catch (SQLException e) {
            System.err.println("[AppContextListener] Direct DDL execution error: " + e.getMessage());
        }
    }
}
