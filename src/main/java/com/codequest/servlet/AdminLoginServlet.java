package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codequest.util.DBConnection;
import com.codequest.util.SecurityUtil;

public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String consoleTitle;
    private String maxFailedAttempts;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        // Demonstrate ServletConfig usage
        consoleTitle = config.getInitParameter("adminConsoleTitle");
        maxFailedAttempts = config.getInitParameter("maxFailedAttempts");

        // Demonstrate ServletContext usage
        ServletContext context = config.getServletContext();
        if (context.getAttribute("appVersion") == null) {
            context.setAttribute("appVersion", "CodeQuest v2.4 (Enterprise Engine)");
        }
        if (context.getAttribute("adminLoginsCount") == null) {
            context.setAttribute("adminLoginsCount", 0);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setAttribute("consoleTitle", consoleTitle);
        request.getRequestDispatcher("/admin-login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        request.setAttribute("formUsername", username);
        request.setAttribute("consoleTitle", consoleTitle);

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Administrator identification credentials cannot be empty.");
            request.getRequestDispatcher("/admin-login.jsp").forward(request, response);
            return;
        }

        username = username.trim();

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT id, username, password, full_name, email FROM admins WHERE username = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            rs = stmt.executeQuery();

            if (rs.next()) {
                String dbPass = rs.getString("password");
                if (SecurityUtil.verifyPassword(password, dbPass)) {
                    int adminId = rs.getInt("id");

                    // Rehash legacy plaintext admin password
                    if (SecurityUtil.needsRehash(dbPass)) {
                        try (PreparedStatement updateStmt = conn.prepareStatement("UPDATE admins SET password = ? WHERE id = ?")) {
                            updateStmt.setString(1, SecurityUtil.hashPassword(password));
                            updateStmt.setInt(2, adminId);
                            updateStmt.executeUpdate();
                        } catch (Exception ignored) {}
                    }

                    // Prevent Session Fixation: Invalidate old session before creating new
                    HttpSession oldSession = request.getSession(false);
                    if (oldSession != null) {
                        oldSession.invalidate();
                    }
                    HttpSession session = request.getSession(true);

                    session.setAttribute("adminId", adminId);
                    session.setAttribute("adminUsername", rs.getString("username"));
                    session.setAttribute("adminName", rs.getString("full_name"));
                    session.setAttribute("adminEmail", rs.getString("email"));
                    session.setAttribute("adminRole", "SYSTEM_ADMIN");

                    // Demonstrate ServletContext update
                    ServletContext ctx = getServletContext();
                    synchronized (ctx) {
                        Integer count = (Integer) ctx.getAttribute("adminLoginsCount");
                        if (count == null) count = 0;
                        ctx.setAttribute("adminLoginsCount", count + 1);
                    }

                    response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
                    return;
                }
            }

            request.setAttribute("errorMessage", "Access Denied: Invalid administrator credentials or clearance level.");
            request.getRequestDispatcher("/admin-login.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("[AdminLoginServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Security communication failure. Please try again.");
            request.getRequestDispatcher("/admin-login.jsp").forward(request, response);
        } finally {
            DBConnection.close(rs, stmt, conn);
        }
    }
}
