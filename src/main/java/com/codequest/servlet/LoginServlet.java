package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codequest.util.DBConnection;
import com.codequest.util.SecurityUtil;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward to student login view
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        // Retain identifier on error
        request.setAttribute("formIdentifier", identifier);

        if (identifier == null || identifier.trim().isEmpty() || 
            password == null || password.isEmpty()) {
            request.setAttribute("errorMessage", "Both identification and access key are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        identifier = identifier.trim();

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Support login by either username OR email address
            String sql = "SELECT id, username, email, password, xp, level FROM users WHERE (username = ? OR email = ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, identifier);
            stmt.setString(2, identifier);
            rs = stmt.executeQuery();

            if (rs.next()) {
                String dbPassword = rs.getString("password");
                if (SecurityUtil.verifyPassword(password, dbPassword)) {
                    int userId = rs.getInt("id");
                    String username = rs.getString("username");
                    int xp = rs.getInt("xp");
                    int level = rs.getInt("level");

                    // Rehash legacy passwords transparently
                    if (SecurityUtil.needsRehash(dbPassword)) {
                        try (PreparedStatement updateStmt = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?")) {
                            updateStmt.setString(1, SecurityUtil.hashPassword(password));
                            updateStmt.setInt(2, userId);
                            updateStmt.executeUpdate();
                        } catch (Exception ignored) {}
                    }

                    // Prevent Session Fixation: Invalidate old session before creating new
                    HttpSession oldSession = request.getSession(false);
                    if (oldSession != null) {
                        oldSession.invalidate();
                    }
                    HttpSession session = request.getSession(true);

                    session.setAttribute("userId", userId);
                    session.setAttribute("username", username);
                    session.setAttribute("xp", xp);
                    session.setAttribute("level", level);
                    session.setAttribute("userRole", "STUDENT");

                    // Demonstrate Secure Cookie management
                    String cookiePath = request.getContextPath().isEmpty() ? "/" : request.getContextPath();
                    if ("true".equalsIgnoreCase(rememberMe) || "on".equalsIgnoreCase(rememberMe)) {
                        Cookie userCookie = new Cookie("codequest_remembered_user", username);
                        userCookie.setMaxAge(7 * 24 * 60 * 60); // 7 days
                        userCookie.setPath(cookiePath);
                        userCookie.setHttpOnly(true);
                        response.addCookie(userCookie);
                    } else {
                        // Clear cookie if unchecked
                        Cookie userCookie = new Cookie("codequest_remembered_user", "");
                        userCookie.setMaxAge(0);
                        userCookie.setPath(cookiePath);
                        userCookie.setHttpOnly(true);
                        response.addCookie(userCookie);
                    }

                    // Redirect to student dashboard
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                    return;
                }
            }

            // Authentication failure
            request.setAttribute("errorMessage", "Invalid username/email or password credentials.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("[LoginServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Authentication service error. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } finally {
            DBConnection.close(rs, stmt, conn);
        }
    }
}

