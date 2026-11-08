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
    private static final long serialVersionUID = 2L;

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
        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "mcq";
        }
        type = type.trim().toLowerCase();

        String xpRewardStr = request.getParameter("xpReward");

        // Mode A (Coding Arena) specific parameters
        String functionName = request.getParameter("functionName");
        String language = request.getParameter("language");
        String starterCode = request.getParameter("starterCode");
        String testCases = request.getParameter("testCases");

        // Mode B (MCQ) specific parameters
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctOption = request.getParameter("correctOption");

        // Retain inputs for form recovery on error
        request.setAttribute("formTitle", title);
        request.setAttribute("formDesc", description);
        request.setAttribute("formCategory", category);
        request.setAttribute("formDifficulty", difficulty);
        request.setAttribute("formType", type);
        request.setAttribute("formFunctionName", functionName);
        request.setAttribute("formLanguage", language);
        request.setAttribute("formStarterCode", starterCode);
        request.setAttribute("formTestCases", testCases);
        request.setAttribute("formOptA", optionA);
        request.setAttribute("formOptB", optionB);
        request.setAttribute("formOptC", optionC);
        request.setAttribute("formOptD", optionD);
        request.setAttribute("formCorrect", correctOption);
        request.setAttribute("formXp", xpRewardStr);

        // Core parameter validation
        if (title == null || title.trim().isEmpty() ||
            description == null || description.trim().isEmpty() ||
            category == null || category.trim().isEmpty() ||
            difficulty == null || difficulty.trim().isEmpty() ||
            xpRewardStr == null || xpRewardStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "All core mission parameters (title, description, category, difficulty, bounty) are mandatory.");
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

            if ("code".equals(type)) {
                // Validate coding arena parameters
                if (functionName == null || functionName.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Function entrypoint name is mandatory for coding arena challenges.");
                    request.getRequestDispatcher("/add-question.jsp").forward(request, response);
                    return;
                }
                if (starterCode == null || starterCode.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Starter code template is mandatory for coding arena challenges.");
                    request.getRequestDispatcher("/add-question.jsp").forward(request, response);
                    return;
                }
                if (testCases == null || testCases.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Test cases JSON array is mandatory for coding arena challenges.");
                    request.getRequestDispatcher("/add-question.jsp").forward(request, response);
                    return;
                }
                String trimmedTests = testCases.trim();
                if (!trimmedTests.startsWith("[") || !trimmedTests.endsWith("]")) {
                    request.setAttribute("errorMessage", "Test cases must be a valid JSON array format, starting with '[' and ending with ']'.");
                    request.getRequestDispatcher("/add-question.jsp").forward(request, response);
                    return;
                }

                if (language == null || language.trim().isEmpty()) {
                    language = "javascript";
                }

                String sql = "INSERT INTO missions (title, description, category, difficulty, type, function_name, language, starter_code, test_cases, xp_reward) "
                           + "VALUES (?, ?, ?, ?, 'code', ?, ?, ?, ?, ?)";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, title.trim());
                stmt.setString(2, description.trim());
                stmt.setString(3, category.trim());
                stmt.setString(4, difficulty.trim());
                stmt.setString(5, functionName.trim());
                stmt.setString(6, language.trim().toLowerCase());
                stmt.setString(7, starterCode.trim());
                stmt.setString(8, testCases.trim());
                stmt.setInt(9, xpReward);

            } else {
                // Validate MCQ parameters
                if (optionA == null || optionA.trim().isEmpty() ||
                    optionB == null || optionB.trim().isEmpty() ||
                    optionC == null || optionC.trim().isEmpty() ||
                    optionD == null || optionD.trim().isEmpty() ||
                    correctOption == null || correctOption.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "All 4 multiple-choice options and the designated correct answer are mandatory for MCQ missions.");
                    request.getRequestDispatcher("/add-question.jsp").forward(request, response);
                    return;
                }

                correctOption = correctOption.trim().toUpperCase();
                if (!correctOption.matches("^[ABCD]$")) {
                    request.setAttribute("errorMessage", "The designated correct answer must be one of: A, B, C, or D.");
                    request.getRequestDispatcher("/add-question.jsp").forward(request, response);
                    return;
                }

                String sql = "INSERT INTO missions (title, description, category, difficulty, type, option_a, option_b, option_c, option_d, correct_option, xp_reward) "
                           + "VALUES (?, ?, ?, ?, 'mcq', ?, ?, ?, ?, ?, ?)";
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
            }

            int rows = stmt.executeUpdate();
            if (rows > 0) {
                response.sendRedirect(request.getContextPath() + "/view-questions?created=true");
            } else {
                request.setAttribute("errorMessage", "Mission insertion failed. Please retry.");
                request.getRequestDispatcher("/add-question.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            System.err.println("[AddQuestionServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Mission persistence error: " + e.getMessage());
            request.getRequestDispatcher("/add-question.jsp").forward(request, response);
        } finally {
            DBConnection.close(stmt, conn);
        }
    }
}
