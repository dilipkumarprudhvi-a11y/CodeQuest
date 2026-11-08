package com.codequest.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Reusable Database Connection Manager for CodeQuest
 * Implements environment-aware JDBC connection management, connection verification,
 * and safe resource cleanup.
 *
 * Credentials can be configured via environment variables:
 * - DB_URL
 * - DB_USER
 * - DB_PASSWORD
 */
public class DBConnection {

    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/codequest_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "@123Kumar"; // Safe local developer fallback

    private static String configuredUrl = null;
    private static String configuredUser = null;
    private static String configuredPassword = null;

    private static boolean driverLoaded = false;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            driverLoaded = true;
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] Warning: com.mysql.cj.jdbc.Driver not found on startup: " + e.getMessage());
        }
    }

    /**
     * Manually configure credentials at runtime
     */
    public static void configure(String url, String user, String pass) {
        if (url != null && !url.trim().isEmpty()) configuredUrl = url.trim();
        if (user != null && !user.trim().isEmpty()) configuredUser = user.trim();
        if (pass != null) configuredPassword = pass.trim();
    }

    public static String getDbUrl() {
        if (configuredUrl != null) return configuredUrl;
        String env = System.getenv("DB_URL");
        if (env != null && !env.trim().isEmpty()) return env.trim();
        String prop = System.getProperty("DB_URL");
        if (prop != null && !prop.trim().isEmpty()) return prop.trim();
        return DEFAULT_URL;
    }

    public static String getDbUser() {
        if (configuredUser != null) return configuredUser;
        String env = System.getenv("DB_USER");
        if (env != null && !env.trim().isEmpty()) return env.trim();
        String prop = System.getProperty("DB_USER");
        if (prop != null && !prop.trim().isEmpty()) return prop.trim();
        return DEFAULT_USER;
    }

    public static String getDbPassword() {
        if (configuredPassword != null) return configuredPassword;
        String env = System.getenv("DB_PASSWORD");
        if (env != null) return env.trim();
        String prop = System.getProperty("DB_PASSWORD");
        if (prop != null) return prop.trim();
        return DEFAULT_PASS;
    }

    /**
     * Obtains an active JDBC Connection to the MySQL database.
     * Guaranteed to return a non-null Connection or throw a descriptive SQLException.
     */
    public static Connection getConnection() throws SQLException {
        if (!driverLoaded) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                driverLoaded = true;
            } catch (ClassNotFoundException e) {
                throw new SQLException("MySQL JDBC Driver ('com.mysql.cj.jdbc.Driver') could not be loaded: " + e.getMessage(), e);
            }
        }

        String url = getDbUrl();
        String user = getDbUser();
        String pass = getDbPassword();

        try {
            Connection conn = DriverManager.getConnection(url, user, pass);
            if (conn == null) {
                throw new SQLException("DriverManager returned null Connection for URL: " + url);
            }
            return conn;
        } catch (SQLException e) {
            throw new SQLException("Database connection failure to " + url + " (User: " + user + "): " + e.getMessage(), e);
        }
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
                        // Suppress cleanup exceptions to avoid masking root issues
                    }
                }
            }
        }
    }
}
