package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codequest.util.DBConnection;

public class AddQuestionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Admin+clearance+required");
            return;
        }
        request.getRequestDispatcher("/add-question.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Admin+clearance+required");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String difficulty = request.getParameter("difficulty");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctOption = request.getParameter("correctOption");
        String xpRewardStr = request.getParameter("xpReward");

        // Retain inputs for recovery
        request.setAttribute("formTitle", title);
        request.setAttribute("formDesc", description);
        request.setAttribute("formCategory", category);
        request.setAttribute("formDifficulty", difficulty);
        request.setAttribute("formOptA", optionA);
        request.setAttribute("formOptB", optionB);
        request.setAttribute("formOptC", optionC);
        request.setAttribute("formOptD", optionD);
        request.setAttribute("formCorrect", correctOption);
        request.setAttribute("formXp", xpRewardStr);

        // Validation
        if (title == null || title.trim().isEmpty() ||
            description == null || description.trim().isEmpty() ||
            category == null || category.trim().isEmpty() ||
            difficulty == null || difficulty.trim().isEmpty() ||
            optionA == null || optionA.trim().isEmpty() ||
            optionB == null || optionB.trim().isEmpty() ||
            optionC == null || optionC.trim().isEmpty() ||
            optionD == null || optionD.trim().isEmpty() ||
            correctOption == null || correctOption.trim().isEmpty() ||
            xpRewardStr == null || xpRewardStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All mission parameters and answer options are mandatory.");
            request.getRequestDispatcher("/add-question.jsp").forward(request, response);
            return;
        }

        correctOption = correctOption.trim().toUpperCase();
        if (!correctOption.matches("^[ABCD]$")) {
            request.setAttribute("errorMessage", "The designated correct answer must be one of: A, B, C, or D.");
            request.getRequestDispatcher("/add-question.jsp").forward(request, response);
            return;
        }

        int xpReward = 50;
        try {
            xpReward = Integer.parseInt(xpRewardStr.trim());
            if (xpReward <= 0 || xpReward > 500) {
                request.setAttribute("errorMessage", "XP reward value must be between 10 and 500.");
                request.getRequestDispatcher("/add-question.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "XP reward must be a valid integer number.");
            request.getRequestDispatcher("/add-question.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnection.getConnection();
            String sql = "INSERT INTO missions (title, description, category, difficulty, option_a, option_b, option_c, option_d, correct_option, xp_reward) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, title.trim());
            stmt.setString(2, description.trim());
            stmt.setString(3, category.trim());
            stmt.setString(4, difficulty.trim());
            stmt.setString(5, optionA.trim());
            stmt.setString(6, optionB.trim());
            stmt.setString(7, optionC.trim());
            stmt.setString(8, optionD.trim());
            stmt.setString(9, correctOption);
            stmt.setInt(10, xpReward);

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/view-questions?created=true");
            } else {
                request.setAttribute("errorMessage", "Mission insertion failed. Please retry.");
                request.getRequestDispatcher("/add-question.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            System.err.println("[AddQuestionServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Mission persistence error. Please check parameters and retry.");
            request.getRequestDispatcher("/add-question.jsp").forward(request, response);
        } finally {
            DBConnection.close(stmt, conn);
        }
    }
}

