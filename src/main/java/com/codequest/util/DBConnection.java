package com.codequest.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Reusable Singleton Database Connection Manager for CodeQuest
 * Implements resilient JDBC connection creation and resource cleanup.
 */
public class DBConnection {

    // Default configuration (Configurable via web.xml or configure method)
    private static String dbUrl = "jdbc:mysql://localhost:3306/codequest_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static String dbUser = "root";
    private static String dbPassword = "@123Kumar";

    private static boolean driverLoaded = false;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            driverLoaded = true;
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] MySQL JDBC Driver not found in classpath: " + e.getMessage());
        }
    }

    /**
     * Manually configure credentials at runtime
     */
    public static void configure(String url, String user, String pass) {
        if (url != null && !url.trim().isEmpty()) dbUrl = url.trim();
        if (user != null && !user.trim().isEmpty()) dbUser = user.trim();
        if (pass != null) dbPassword = pass.trim();
    }

    /**
     * Obtains an active JDBC Connection to the MySQL database
     */
    public static Connection getConnection() throws SQLException {
        if (!driverLoaded) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                driverLoaded = true;
            } catch (ClassNotFoundException e) {
                throw new SQLException("MySQL JDBC Driver could not be loaded: " + e.getMessage());
            }
        }
        return DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    }

    /**
     * Safely closes one or more JDBC resources (Connection, Statement, ResultSet)
     */
    public static void close(AutoCloseable... resources) {
        if (resources != null) {
            for (AutoCloseable res : resources) {
                if (res != null) {
                    try {
                        res.close();
                    } catch (Exception ignored) {
                        // Suppress cleanup exceptions to prevent masking root causes
                    }
                }
            }
        }
    }

    public static String getDbUrl() {
        return dbUrl;
    }

    public static String getDbUser() {
        return dbUser;
    }
}
