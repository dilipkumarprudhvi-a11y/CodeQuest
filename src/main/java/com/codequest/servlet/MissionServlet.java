package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codequest.model.Mission;
import com.codequest.util.DBConnection;

public class MissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Access+restricted.+Please+log+in.");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String categoryFilter = request.getParameter("category");
        String difficultyFilter = request.getParameter("difficulty");

        Connection conn = null;
        PreparedStatement stmt = null;
        PreparedStatement subStmt = null;
        ResultSet rs = null;
        ResultSet rsSub = null;

        List<Mission> missionsList = new ArrayList<>();
        // Map of missionId -> submitted selected option (to track completed quests)
        Map<Integer, String> solvedMap = new HashMap<>();

        try {
            conn = DBConnection.getConnection();

            // 1. Fetch user's prior submissions to flag solved quests
            String subSql = "SELECT mission_id, selected_option FROM mission_submissions WHERE user_id = ?";
            subStmt = conn.prepareStatement(subSql);
            subStmt.setInt(1, userId);
            rsSub = subStmt.executeQuery();
            while (rsSub.next()) {
                solvedMap.put(rsSub.getInt("mission_id"), rsSub.getString("selected_option"));
            }

            // 2. Fetch missions according to filters
            StringBuilder sql = new StringBuilder(
                "SELECT id, title, description, category, difficulty, option_a, option_b, option_c, option_d, xp_reward, created_at "
                + "FROM missions WHERE 1=1 "
            );

            List<String> params = new ArrayList<>();
            if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !"All".equalsIgnoreCase(categoryFilter)) {
                sql.append("AND category = ? ");
                params.add(categoryFilter.trim());
            }
            if (difficultyFilter != null && !difficultyFilter.trim().isEmpty() && !"All".equalsIgnoreCase(difficultyFilter)) {
                sql.append("AND difficulty = ? ");
                params.add(difficultyFilter.trim());
            }

            sql.append("ORDER BY id ASC");

            stmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                stmt.setString(i + 1, params.get(i));
            }

            rs = stmt.executeQuery();

            while (rs.next()) {
                int missionId = rs.getInt("id");
                Mission m = new Mission(
                    missionId,
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getString("category"),
                    rs.getString("difficulty"),
                    rs.getString("option_a"),
                    rs.getString("option_b"),
                    rs.getString("option_c"),
                    rs.getString("option_d"),
                    null, // Strictly OMIT correct answer from student presentation layer
                    rs.getInt("xp_reward"),
                    rs.getTimestamp("created_at")
                );

                if (solvedMap.containsKey(missionId)) {
                    m.setSolved(true);
                    m.setUserChoice(solvedMap.get(missionId));
                } else {
                    m.setSolved(false);
                }

                missionsList.add(m);
            }

            request.setAttribute("missionsList", missionsList);
            request.setAttribute("selectedCategory", categoryFilter != null ? categoryFilter : "All");
            request.setAttribute("selectedDifficulty", difficultyFilter != null ? difficultyFilter : "All");
            request.setAttribute("totalCount", missionsList.size());
            request.setAttribute("solvedCount", solvedMap.size());

        } catch (SQLException e) {
            System.err.println("[MissionServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Unable to load mission arena. Please refresh.");
        } finally {
            DBConnection.close(rs, rsSub, stmt, subStmt, conn);
        }

        // Forward to missions.jsp using RequestDispatcher
        request.getRequestDispatcher("/missions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

