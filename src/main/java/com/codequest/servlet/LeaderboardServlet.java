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

import com.codequest.util.DBConnection;

public class LeaderboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        List<Map<String, Object>> leaderboard = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();

            // Retrieve students ranked by total XP, along with correctly completed mission counts
            String sql = "SELECT u.id, u.username, u.xp, u.level, "
                       + "COALESCE(COUNT(CASE WHEN ms.is_correct = 1 THEN 1 END), 0) AS completed_missions "
                       + "FROM users u "
                       + "LEFT JOIN mission_submissions ms ON u.id = ms.user_id "
                       + "GROUP BY u.id, u.username, u.xp, u.level "
                       + "ORDER BY u.xp DESC, u.level DESC, u.id ASC";

            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            int rank = 1;
            while (rs.next()) {
                Map<String, Object> player = new HashMap<>();
                player.put("rank", rank++);
                player.put("id", rs.getInt("id"));
                player.put("username", rs.getString("username"));
                player.put("xp", rs.getInt("xp"));
                player.put("level", rs.getInt("level"));
                player.put("completedMissions", rs.getInt("completed_missions"));
                leaderboard.add(player);
            }

            request.setAttribute("leaderboardList", leaderboard);

        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Leaderboard synchronization failure: " + e.getMessage());
        } finally {
            DBConnection.close(rs, stmt, conn);
        }

        // Forward to leaderboard.jsp via RequestDispatcher
        request.getRequestDispatcher("/leaderboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

