package com.codequest.util;

import java.net.URI;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Reusable Database Connection Manager for CodeQuest
 * Implements cloud-aware JDBC connection management supporting:
 * 1. Railway native environment variables (MYSQLHOST, MYSQLPORT, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE)
 * 2. Standard connection URIs (MYSQL_URL, DATABASE_URL)
 * 3. Standard JDBC environment variables (DB_URL, DB_USER, DB_PASSWORD)
 * 4. Local developer MySQL fallback
 */
public class DBConnection {

    private static final String DEFAULT_HOST = "localhost";
    private static final String DEFAULT_PORT = "3306";
    private static final String DEFAULT_DB = "codequest_db";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "@123Kumar"; // Local developer fallback

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

        // 1. Direct explicit DB_URL
        String env = System.getenv("DB_URL");
        if (env != null && !env.trim().isEmpty()) return env.trim();
        String prop = System.getProperty("DB_URL");
        if (prop != null && !prop.trim().isEmpty()) return prop.trim();

        // 2. Full URL from cloud providers (e.g., MYSQL_URL or DATABASE_URL)
        String rawUrl = System.getenv("MYSQL_URL");
        if (rawUrl == null || rawUrl.trim().isEmpty()) {
            rawUrl = System.getenv("DATABASE_URL");
        }
        if (rawUrl != null && !rawUrl.trim().isEmpty()) {
            try {
                if (rawUrl.startsWith("jdbc:mysql://")) {
                    return rawUrl.trim();
                } else if (rawUrl.startsWith("mysql://")) {
                    URI uri = new URI(rawUrl.trim());
                    String host = uri.getHost();
                    int port = uri.getPort() > 0 ? uri.getPort() : 3306;
                    String path = uri.getPath() != null && uri.getPath().length() > 1 ? uri.getPath().substring(1) : DEFAULT_DB;
                    return "jdbc:mysql://" + host + ":" + port + "/" + path + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
                }
            } catch (Exception e) {
                System.err.println("[DBConnection] Could not parse raw connection URI: " + e.getMessage());
            }
        }

        // 3. Railway / Cloud individual parameters
        String host = getEnvAny("MYSQLHOST", "MYSQL_HOST", "DB_HOST");
        String port = getEnvAny("MYSQLPORT", "MYSQL_PORT", "DB_PORT");
        String dbName = getEnvAny("MYSQLDATABASE", "MYSQL_DATABASE", "DB_NAME");

        if (host != null && !host.trim().isEmpty()) {
            if (port == null || port.trim().isEmpty()) port = DEFAULT_PORT;
            if (dbName == null || dbName.trim().isEmpty()) dbName = DEFAULT_DB;
            return "jdbc:mysql://" + host.trim() + ":" + port.trim() + "/" + dbName.trim() + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
        }

        // 4. Fallback to local default URL
        return "jdbc:mysql://" + DEFAULT_HOST + ":" + DEFAULT_PORT + "/" + DEFAULT_DB + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    }

    public static String getDbUser() {
        if (configuredUser != null) return configuredUser;

        // 1. Direct explicit DB_USER
        String env = System.getenv("DB_USER");
        if (env != null && !env.trim().isEmpty()) return env.trim();
        String prop = System.getProperty("DB_USER");
        if (prop != null && !prop.trim().isEmpty()) return prop.trim();

        // 2. Cloud parameter fallbacks (Railway, etc.)
        String user = getEnvAny("MYSQLUSER", "MYSQL_USER", "DB_USERNAME");
        if (user != null && !user.trim().isEmpty()) return user.trim();

        // 3. Parse from MYSQL_URL or DATABASE_URL if present
        String rawUrl = System.getenv("MYSQL_URL");
        if (rawUrl == null || rawUrl.trim().isEmpty()) rawUrl = System.getenv("DATABASE_URL");
        if (rawUrl != null && rawUrl.startsWith("mysql://")) {
            try {
                URI uri = new URI(rawUrl.trim());
                if (uri.getUserInfo() != null) {
                    String[] parts = uri.getUserInfo().split(":", 2);
                    if (parts.length > 0 && !parts[0].isEmpty()) return parts[0];
                }
            } catch (Exception ignored) {}
        }

        return DEFAULT_USER;
    }

    public static String getDbPassword() {
        if (configuredPassword != null) return configuredPassword;

        // 1. Direct explicit DB_PASSWORD
        String env = System.getenv("DB_PASSWORD");
        if (env != null) return env.trim();
        String prop = System.getProperty("DB_PASSWORD");
        if (prop != null) return prop.trim();

        // 2. Cloud parameter fallbacks (Railway, etc.)
        String pass = getEnvAny("MYSQLPASSWORD", "MYSQL_PASSWORD");
        if (pass != null) return pass.trim();

        // 3. Parse from MYSQL_URL or DATABASE_URL if present
        String rawUrl = System.getenv("MYSQL_URL");
        if (rawUrl == null || rawUrl.trim().isEmpty()) rawUrl = System.getenv("DATABASE_URL");
        if (rawUrl != null && rawUrl.startsWith("mysql://")) {
            try {
                URI uri = new URI(rawUrl.trim());
                if (uri.getUserInfo() != null) {
                    String[] parts = uri.getUserInfo().split(":", 2);
                    if (parts.length > 1) return parts[1];
                }
            } catch (Exception ignored) {}
        }

        return DEFAULT_PASS;
    }

    private static String getEnvAny(String... keys) {
        for (String k : keys) {
            String v = System.getenv(k);
            if (v != null && !v.trim().isEmpty()) return v.trim();
        }
        return null;
    }

    /**
     * Obtains an active JDBC Connection to the MySQL database.
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
                    }
                }
            }
        }
    }
}
