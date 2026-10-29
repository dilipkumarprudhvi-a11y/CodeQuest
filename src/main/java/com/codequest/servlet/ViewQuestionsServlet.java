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

import com.codequest.model.Mission;
import com.codequest.util.DBConnection;

public class ViewQuestionsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Admin+clearance+required");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        // Optional Delete Action
        if ("delete".equalsIgnoreCase(action) && idParam != null) {
            try {
                int missionId = Integer.parseInt(idParam.trim());
                deleteMission(missionId);
                response.sendRedirect(request.getContextPath() + "/view-questions?deleted=true");
                return;
            } catch (Exception e) {
                request.setAttribute("errorMessage", "Failed to delete mission: " + e.getMessage());
            }
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Mission> missionsList = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT id, title, description, category, difficulty, option_a, option_b, option_c, option_d, correct_option, xp_reward, created_at "
                       + "FROM missions ORDER BY id DESC";
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Mission m = new Mission(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getString("category"),
                    rs.getString("difficulty"),
                    rs.getString("option_a"),
                    rs.getString("option_b"),
                    rs.getString("option_c"),
                    rs.getString("option_d"),
                    rs.getString("correct_option"),
                    rs.getInt("xp_reward"),
                    rs.getTimestamp("created_at")
                );
                missionsList.add(m);
            }

            request.setAttribute("missionsList", missionsList);

        } catch (SQLException e) {
            System.err.println("[ViewQuestionsServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Unable to retrieve question catalog. Please retry.");
        } finally {
            DBConnection.close(rs, stmt, conn);
        }

        // Forward to JSP page using RequestDispatcher
        request.getRequestDispatcher("/view-questions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Admin+clearance+required");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if ("delete".equalsIgnoreCase(action) && idParam != null) {
            try {
                int missionId = Integer.parseInt(idParam.trim());
                deleteMission(missionId);
                response.sendRedirect(request.getContextPath() + "/view-questions?deleted=true");
                return;
            } catch (Exception e) {
                System.err.println("[Delete Mission Error] " + e.getMessage());
            }
        }
        doGet(request, response);
    }

    private void deleteMission(int missionId) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "DELETE FROM missions WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, missionId);
            stmt.executeUpdate();
        } finally {
            DBConnection.close(stmt, conn);
        }
    }
}

