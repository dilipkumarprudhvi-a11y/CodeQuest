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
    private static final long serialVersionUID = 2L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Admin+clearance+required");
            return;
        }

        // Deletion via GET is intentionally removed to prevent CSRF vulnerabilities.
        // All destructive administrative operations must be processed via POST.

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Mission> missionsList = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT id, title, description, category, difficulty, type, function_name, language, "
                       + "starter_code, test_cases, option_a, option_b, option_c, option_d, correct_option, xp_reward, created_at "
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
                    rs.getString("type"),
                    rs.getString("function_name"),
                    rs.getString("language"),
                    rs.getString("starter_code"),
                    rs.getString("test_cases"),
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
            } catch (NumberFormatException nfe) {
                request.setAttribute("errorMessage", "Invalid mission identifier for deletion.");
            } catch (SQLException sqle) {
                System.err.println("[Delete Mission Error] " + sqle.getMessage());
                request.setAttribute("errorMessage", "Database error while deleting mission: " + sqle.getMessage());
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
