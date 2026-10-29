package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codequest.model.Submission;
import com.codequest.model.User;
import com.codequest.util.DBConnection;

public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Session+expired.+Please+log+in.");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        Connection conn = null;
        PreparedStatement userStmt = null;
        PreparedStatement countStmt = null;
        PreparedStatement historyStmt = null;
        PreparedStatement totalMissionsStmt = null;
        ResultSet rsUser = null;
        ResultSet rsCount = null;
        ResultSet rsHistory = null;
        ResultSet rsTotal = null;

        User student = null;
        int completedMissions = 0;
        int totalAvailableMissions = 0;
        List<Submission> recentSubmissions = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();

            // 1. Fetch latest student details from users table
            String userSql = "SELECT id, username, email, password, xp, level, created_at FROM users WHERE id = ?";
            userStmt = conn.prepareStatement(userSql);
            userStmt.setInt(1, userId);
            rsUser = userStmt.executeQuery();

            if (rsUser.next()) {
                student = new User(
                    rsUser.getInt("id"),
                    rsUser.getString("username"),
                    rsUser.getString("email"),
                    rsUser.getString("password"),
                    rsUser.getInt("xp"),
                    rsUser.getInt("level"),
                    rsUser.getTimestamp("created_at")
                );

                // Update session cached stats
                session.setAttribute("xp", student.getXp());
                session.setAttribute("level", student.getLevel());
            } else {
                response.sendRedirect(request.getContextPath() + "/logout");
                return;
            }

            // 2. Fetch number of correctly completed missions
            String countSql = "SELECT COUNT(*) FROM mission_submissions WHERE user_id = ? AND is_correct = 1";
            countStmt = conn.prepareStatement(countSql);
            countStmt.setInt(1, userId);
            rsCount = countStmt.executeQuery();
            if (rsCount.next()) {
                completedMissions = rsCount.getInt(1);
            }

            // 3. Fetch total active missions in platform
            String totalSql = "SELECT COUNT(*) FROM missions";
            totalMissionsStmt = conn.prepareStatement(totalSql);
            rsTotal = totalMissionsStmt.executeQuery();
            if (rsTotal.next()) {
                totalAvailableMissions = rsTotal.getInt(1);
            }

            // 4. Fetch recent submission history
            String historySql = "SELECT ms.id, ms.user_id, ms.mission_id, ms.selected_option, ms.is_correct, "
                              + "ms.xp_awarded, ms.submitted_at, m.title, m.category, m.difficulty "
                              + "FROM mission_submissions ms "
                              + "JOIN missions m ON ms.mission_id = m.id "
                              + "WHERE ms.user_id = ? ORDER BY ms.submitted_at DESC LIMIT 5";
            historyStmt = conn.prepareStatement(historySql);
            historyStmt.setInt(1, userId);
            rsHistory = historyStmt.executeQuery();

            while (rsHistory.next()) {
                Submission sub = new Submission(
                    rsHistory.getInt("id"),
                    rsHistory.getInt("user_id"),
                    rsHistory.getInt("mission_id"),
                    rsHistory.getString("selected_option"),
                    rsHistory.getBoolean("is_correct"),
                    rsHistory.getInt("xp_awarded"),
                    rsHistory.getTimestamp("submitted_at")
                );
                sub.setMissionTitle(rsHistory.getString("title"));
                sub.setCategory(rsHistory.getString("category"));
                sub.setDifficulty(rsHistory.getString("difficulty"));
                recentSubmissions.add(sub);
            }

            request.setAttribute("student", student);
            request.setAttribute("completedMissions", completedMissions);
            request.setAttribute("totalAvailableMissions", totalAvailableMissions);
            request.setAttribute("recentSubmissions", recentSubmissions);

        } catch (SQLException e) {
            System.err.println("[DashboardServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Unable to load student telemetry. Please refresh.");
        } finally {
            DBConnection.close(rsUser, rsCount, rsHistory, rsTotal, userStmt, countStmt, historyStmt, totalMissionsStmt, conn);
        }

        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

