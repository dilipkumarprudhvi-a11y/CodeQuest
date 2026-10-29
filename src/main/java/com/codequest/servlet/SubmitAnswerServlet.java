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
    private static final long serialVersionUID = 1L;

    private int lvl2Thresh = 100;
    private int lvl3Thresh = 250;
    private int lvl4Thresh = 450;
    private int lvl5Thresh = 700;
    private String engineName = "Standard Judge";

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        // Demonstrate ServletConfig init parameters
        try {
            lvl2Thresh = Integer.parseInt(config.getInitParameter("level2Threshold"));
            lvl3Thresh = Integer.parseInt(config.getInitParameter("level3Threshold"));
            lvl4Thresh = Integer.parseInt(config.getInitParameter("level4Threshold"));
            lvl5Thresh = Integer.parseInt(config.getInitParameter("level5Threshold"));
        } catch (Exception ignored) {}
        engineName = config.getInitParameter("evaluationEngine");
        if (engineName == null) engineName = "CodeQuest Judge Engine";
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
        String selectedOption = request.getParameter("selectedOption");

        if (missionIdParam == null || selectedOption == null || selectedOption.trim().isEmpty()) {
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

        selectedOption = selectedOption.trim().toUpperCase();
        if (!selectedOption.matches("^[ABCD]$")) {
            response.sendRedirect(request.getContextPath() + "/missions?error=Invalid+option+selected");
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
        int newTotalXp = 0;
        int oldLevel = 1;
        int newLevel = 1;
        boolean leveledUp = false;

        try {
            conn = DBConnection.getConnection();

            // 1. One-attempt-per-mission rule enforcement
            String checkSql = "SELECT id, is_correct, xp_awarded, selected_option FROM mission_submissions WHERE user_id = ? AND mission_id = ?";
            checkSubStmt = conn.prepareStatement(checkSql);
            checkSubStmt.setInt(1, userId);
            checkSubStmt.setInt(2, missionId);
            rsCheck = checkSubStmt.executeQuery();

            if (rsCheck.next()) {
                request.setAttribute("isDuplicate", true);
                request.setAttribute("previousChoice", rsCheck.getString("selected_option"));
                request.setAttribute("wasCorrect", rsCheck.getBoolean("is_correct"));
                request.setAttribute("errorMessage", "Per CodeQuest rules, only one attempt is permitted per mission. Your prior submission has already been logged.");
                request.getRequestDispatcher("/mission-result.jsp").forward(request, response);
                return;
            }

            // 2. Retrieve mission details and correct answer
            String missionSql = "SELECT id, title, description, category, difficulty, option_a, option_b, option_c, option_d, correct_option, xp_reward "
                              + "FROM missions WHERE id = ?";
            missionStmt = conn.prepareStatement(missionSql);
            missionStmt.setInt(1, missionId);
            rsMission = missionStmt.executeQuery();

            if (!rsMission.next()) {
                response.sendRedirect(request.getContextPath() + "/missions?error=Mission+not+found");
                return;
            }

            mission = new Mission(
                rsMission.getInt("id"),
                rsMission.getString("title"),
                rsMission.getString("description"),
                rsMission.getString("category"),
                rsMission.getString("difficulty"),
                rsMission.getString("option_a"),
                rsMission.getString("option_b"),
                rsMission.getString("option_c"),
                rsMission.getString("option_d"),
                rsMission.getString("correct_option"),
                rsMission.getInt("xp_reward"),
                null
            );

            // Compare student choice with correct option
            String correctOption = mission.getCorrectOption();
            isCorrect = selectedOption.equalsIgnoreCase(correctOption);
            if (isCorrect) {
                xpAwarded = mission.getXpReward();
            } else {
                xpAwarded = 0;
            }

            // ====================================================
            // ATOMIC DATABASE TRANSACTION
            // ====================================================
            conn.setAutoCommit(false);

            // A. Insert submission record
            String insertSubSql = "INSERT INTO mission_submissions (user_id, mission_id, selected_option, is_correct, xp_awarded) "
                                + "VALUES (?, ?, ?, ?, ?)";
            insertSubStmt = conn.prepareStatement(insertSubSql);
            insertSubStmt.setInt(1, userId);
            insertSubStmt.setInt(2, missionId);
            insertSubStmt.setString(3, selectedOption);
            insertSubStmt.setBoolean(4, isCorrect);
            insertSubStmt.setInt(5, xpAwarded);
            insertSubStmt.executeUpdate();

            // B. If correct, update user XP and Level
            if (isCorrect) {
                String userSql = "SELECT xp, level FROM users WHERE id = ? FOR UPDATE";
                userStmt = conn.prepareStatement(userSql);
                userStmt.setInt(1, userId);
                rsUser = userStmt.executeQuery();

                if (rsUser.next()) {
                    int currentXp = rsUser.getInt("xp");
                    oldLevel = rsUser.getInt("level");
                    newTotalXp = currentXp + xpAwarded;

                    newLevel = 1;
                    if (newTotalXp >= lvl5Thresh) newLevel = 5;
                    else if (newTotalXp >= lvl4Thresh) newLevel = 4;
                    else if (newTotalXp >= lvl3Thresh) newLevel = 3;
                    else if (newTotalXp >= lvl2Thresh) newLevel = 2;

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
                Object sXp = session.getAttribute("xp");
                newTotalXp = (sXp instanceof Integer) ? (Integer) sXp : 0;
                Object sLvl = session.getAttribute("level");
                newLevel = (sLvl instanceof Integer) ? (Integer) sLvl : 1;
            }

            // Commit transaction
            conn.commit();

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    System.err.println("Rollback error: " + rollbackEx.getMessage());
                }
            }
            System.err.println("[SubmitAnswerServlet Error] " + e.getMessage());
            request.setAttribute("errorMessage", "Database transaction aborted. Please retry your submission.");
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {}
            }
            DBConnection.close(rsCheck, rsMission, rsUser, checkSubStmt, missionStmt, insertSubStmt, userStmt, updateUserStmt, conn);
        }

        // Forward outcome data to mission-result.jsp
        request.setAttribute("mission", mission);
        request.setAttribute("selectedOption", selectedOption);
        request.setAttribute("isCorrect", isCorrect);
        request.setAttribute("xpAwarded", xpAwarded);
        request.setAttribute("newTotalXp", newTotalXp);
        request.setAttribute("oldLevel", oldLevel);
        request.setAttribute("newLevel", newLevel);
        request.setAttribute("leveledUp", leveledUp);
        request.setAttribute("judgeEngine", engineName);

        request.getRequestDispatcher("/mission-result.jsp").forward(request, response);
    }
}
