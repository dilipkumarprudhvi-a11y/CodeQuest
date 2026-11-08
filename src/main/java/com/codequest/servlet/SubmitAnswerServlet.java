package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.codequest.model.Mission;
import com.codequest.util.DBConnection;

public class SubmitAnswerServlet extends HttpServlet {
    private static final long serialVersionUID = 2L;

    private String engineName = "CodeQuest Standard Judge";

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        engineName = config.getInitParameter("evaluationEngine");
        if (engineName == null || engineName.trim().isEmpty()) {
            engineName = "CodeQuest Jakarta EE Evaluation Engine";
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Authentication+required");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String missionIdParam = request.getParameter("missionId");

        if (missionIdParam == null || missionIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/missions?error=Invalid+mission+selection");
            return;
        }

        int missionId;
        try {
            missionId = Integer.parseInt(missionIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/missions?error=Invalid+mission+identifier");
            return;
        }

        Connection conn = null;
        PreparedStatement checkSubStmt = null;
        PreparedStatement missionStmt = null;
        PreparedStatement insertSubStmt = null;
        PreparedStatement userStmt = null;
        PreparedStatement updateUserStmt = null;
        ResultSet rsCheck = null;
        ResultSet rsMission = null;
        ResultSet rsUser = null;

        Mission mission = null;
        boolean isCorrect = false;
        int xpAwarded = 0;
        int newTotalXp = (session.getAttribute("xp") instanceof Integer) ? (Integer) session.getAttribute("xp") : 0;
        int oldLevel = (session.getAttribute("level") instanceof Integer) ? (Integer) session.getAttribute("level") : 1;
        int newLevel = oldLevel;
        boolean leveledUp = false;

        String submissionType = request.getParameter("type");
        String submittedCode = request.getParameter("submittedCode");
        String selectedOption = request.getParameter("selectedOption");
        String allPassedParam = request.getParameter("allPassed");

        try {
            conn = DBConnection.getConnection();

            // 1. One-attempt-per-mission rule enforcement (checked against DB and table constraint)
            String checkSql = "SELECT id, is_correct, xp_awarded, selected_option, type FROM mission_submissions WHERE user_id = ? AND mission_id = ?";
            checkSubStmt = conn.prepareStatement(checkSql);
            checkSubStmt.setInt(1, userId);
            checkSubStmt.setInt(2, missionId);
            rsCheck = checkSubStmt.executeQuery();

            if (rsCheck.next()) {
                request.setAttribute("isDuplicate", true);
                request.setAttribute("previousChoice", rsCheck.getString("selected_option"));
                request.setAttribute("wasCorrect", rsCheck.getBoolean("is_correct"));
                request.setAttribute("newLevel", oldLevel);
                request.setAttribute("newTotalXp", newTotalXp);
                request.setAttribute("errorMessage", "Per CodeQuest rules, only one official evaluation attempt is permitted per mission. Your prior submission has already been logged.");
                request.getRequestDispatcher("/mission-result.jsp").forward(request, response);
                return;
            }

            // 2. Retrieve mission details and correct option
            String missionSql = "SELECT id, title, description, category, difficulty, type, function_name, language, "
                              + "starter_code, test_cases, option_a, option_b, option_c, option_d, correct_option, xp_reward "
                              + "FROM missions WHERE id = ?";
            missionStmt = conn.prepareStatement(missionSql);
            missionStmt.setInt(1, missionId);
            rsMission = missionStmt.executeQuery();

            if (!rsMission.next()) {
                response.sendRedirect(request.getContextPath() + "/missions?error=Mission+not+found");
                return;
            }

            String dbMissionType = rsMission.getString("type");
            if (dbMissionType == null) dbMissionType = "mcq";

            mission = new Mission(
                rsMission.getInt("id"),
                rsMission.getString("title"),
                rsMission.getString("description"),
                rsMission.getString("category"),
                rsMission.getString("difficulty"),
                dbMissionType,
                rsMission.getString("function_name"),
                rsMission.getString("language"),
                rsMission.getString("starter_code"),
                rsMission.getString("test_cases"),
                rsMission.getString("option_a"),
                rsMission.getString("option_b"),
                rsMission.getString("option_c"),
                rsMission.getString("option_d"),
                rsMission.getString("correct_option"),
                rsMission.getInt("xp_reward"),
                null
            );

            // Determine evaluation result based on mission format
            if ("code".equalsIgnoreCase(dbMissionType)) {
                submissionType = "code";
                if (selectedOption == null || selectedOption.trim().isEmpty()) {
                    selectedOption = "CODE";
                }
                isCorrect = "true".equalsIgnoreCase(allPassedParam);
            } else {
                submissionType = "mcq";
                if (selectedOption == null || selectedOption.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/missions?error=Invalid+option+selected");
                    return;
                }
                selectedOption = selectedOption.trim().toUpperCase();
                if (!selectedOption.matches("^[ABCD]$")) {
                    response.sendRedirect(request.getContextPath() + "/missions?error=Invalid+option+selected");
                    return;
                }
                String correctOption = mission.getCorrectOption();
                isCorrect = selectedOption.equalsIgnoreCase(correctOption);
            }

            if (isCorrect) {
                xpAwarded = mission.getXpReward();
            } else {
                xpAwarded = 0;
            }

            // ====================================================
            // ATOMIC DATABASE TRANSACTION
            // ====================================================
            conn.setAutoCommit(false);

            // A. Insert submission record into mission_submissions
            String insertSubSql = "INSERT INTO mission_submissions (user_id, mission_id, selected_option, is_correct, xp_awarded, type, submitted_code) "
                                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            insertSubStmt = conn.prepareStatement(insertSubSql);
            insertSubStmt.setInt(1, userId);
            insertSubStmt.setInt(2, missionId);
            insertSubStmt.setString(3, selectedOption);
            insertSubStmt.setBoolean(4, isCorrect);
            insertSubStmt.setInt(5, xpAwarded);
            insertSubStmt.setString(6, submissionType);
            insertSubStmt.setString(7, submittedCode);
            insertSubStmt.executeUpdate();

            // B. If correct, query current XP and calculate new level using uniform formula
            if (isCorrect && xpAwarded > 0) {
                String userSql = "SELECT xp, level FROM users WHERE id = ? FOR UPDATE";
                userStmt = conn.prepareStatement(userSql);
                userStmt.setInt(1, userId);
                rsUser = userStmt.executeQuery();

                if (rsUser.next()) {
                    int currentXp = rsUser.getInt("xp");
                    oldLevel = rsUser.getInt("level");
                    newTotalXp = currentXp + xpAwarded;

                    // Uniform level formula: (newTotalXp / 100) + 1
                    // 0-99 XP = Level 1, 100-199 XP = Level 2, etc.
                    newLevel = (newTotalXp / 100) + 1;

                    if (newLevel > oldLevel) {
                        leveledUp = true;
                    }

                    String updateUserSql = "UPDATE users SET xp = ?, level = ? WHERE id = ?";
                    updateUserStmt = conn.prepareStatement(updateUserSql);
                    updateUserStmt.setInt(1, newTotalXp);
                    updateUserStmt.setInt(2, newLevel);
                    updateUserStmt.setInt(3, userId);
                    updateUserStmt.executeUpdate();

                    session.setAttribute("xp", newTotalXp);
                    session.setAttribute("level", newLevel);
                }
            } else {
                newLevel = oldLevel;
            }

            // Commit atomic transaction
            conn.commit();

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    System.err.println("[SubmitAnswerServlet Rollback Error] " + rollbackEx.getMessage());
                }
            }
            System.err.println("[SubmitAnswerServlet Error] " + e.getMessage());

            // Handle potential duplicate submission race conditions caught by UNIQUE constraint (1062)
            if (e.getErrorCode() == 1062 || (e.getMessage() != null && e.getMessage().contains("Duplicate entry"))) {
                request.setAttribute("isDuplicate", true);
                request.setAttribute("newLevel", oldLevel);
                request.setAttribute("newTotalXp", newTotalXp);
                request.setAttribute("errorMessage", "Duplicate submission attempt rejected. Single-attempt rule strictly enforced.");
                request.getRequestDispatcher("/mission-result.jsp").forward(request, response);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/missions?error=Submission+failed.+Please+retry.");
            return;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    // ignore
                }
            }
            DBConnection.close(rsUser, updateUserStmt, null);
            DBConnection.close(rsCheck, checkSubStmt, null);
            DBConnection.close(rsMission, missionStmt, null);
            DBConnection.close(insertSubStmt, userStmt, conn);
        }

        request.setAttribute("isDuplicate", false);
        request.setAttribute("isCorrect", isCorrect);
        request.setAttribute("xpAwarded", xpAwarded);
        request.setAttribute("newTotalXp", newTotalXp);
        request.setAttribute("oldLevel", oldLevel);
        request.setAttribute("newLevel", newLevel);
        request.setAttribute("leveledUp", leveledUp);
        request.setAttribute("selectedOption", selectedOption);
        request.setAttribute("judgeEngine", engineName);
        request.setAttribute("mission", mission);

        request.getRequestDispatcher("/mission-result.jsp").forward(request, response);
    }
}
