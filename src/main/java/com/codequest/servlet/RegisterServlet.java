package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.codequest.util.DBConnection;
import com.codequest.util.SecurityUtil;

public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward to registration view
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Retain input fields on error
        request.setAttribute("formUsername", username);
        request.setAttribute("formEmail", email);

        // Validation
        if (username == null || username.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.isEmpty() ||
                confirmPassword == null || confirmPassword.isEmpty()) {
            request.setAttribute("errorMessage", "All registration fields are strictly required.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        username = username.trim();
        email = email.trim().toLowerCase();

        if (!username.matches("^[A-Za-z0-9_]{3,30}$")) {
            request.setAttribute("errorMessage", "Username must be 3-30 characters and contain only letters, numbers, and underscores.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("errorMessage", "Please provide a valid email address.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("errorMessage", "Security mandate: Password must contain at least 6 characters.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Password confirmation mismatch. Please re-enter.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Verify unique username and email
            String checkSql = "SELECT username, email FROM users WHERE username = ? OR email = ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            checkStmt.setString(2, email);
            rs = checkStmt.executeQuery();

            if (rs.next()) {
                String existingUser = rs.getString("username");
                if (username.equalsIgnoreCase(existingUser)) {
                    request.setAttribute("errorMessage",
                            "Warrior codename '" + SecurityUtil.encodeHtml(username) + "' is already claimed. Choose another.");
                } else {
                    request.setAttribute("errorMessage", "An account linked to email '" + SecurityUtil.encodeHtml(email) + "' already exists.");
                }
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            // Insert new student with hashed password, 0 XP and Level 1
            String insertSql = "INSERT INTO users (username, email, password, xp, level) VALUES (?, ?, ?, 0, 1)";
            insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, username);
            insertStmt.setString(2, email);
            insertStmt.setString(3, SecurityUtil.hashPassword(password));

            int rowsAffected = insertStmt.executeUpdate();
            if (rowsAffected > 0) {
                // Redirect to login with success flash message
                response.sendRedirect(request.getContextPath() + "/login.jsp?registered=true&user="
                        + java.net.URLEncoder.encode(username, "UTF-8"));
            } else {
                request.setAttribute("errorMessage", "Failed to initialize student profile. Please try again.");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            System.err.println("[RegisterServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Database transaction failed. Please try again later.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        } finally {
            DBConnection.close(rs, checkStmt, insertStmt, conn);
        }
    }
}
