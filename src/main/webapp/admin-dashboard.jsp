<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.codequest.util.DBConnection" %>
<%
    // Strictly scriptlets - Check admin session guard
    Integer adminId = (Integer) session.getAttribute("adminId");
    String adminUsername = (String) session.getAttribute("adminUsername");
    String adminName = (String) session.getAttribute("adminName");
    String adminRole = (String) session.getAttribute("adminRole");

    if (adminId == null || adminRole == null) {
        response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Security+Alert:+Admin+clearance+required");
        return;
    }

    // Live counts for admin cockpit
    int totalQuestions = 0;
    int totalStudents = 0;
    int totalSubmissions = 0;

    Connection conn = null;
    PreparedStatement stmtQ = null, stmtS = null, stmtSub = null;
    ResultSet rsQ = null, rsS = null, rsSub = null;
    try {
        conn = DBConnection.getConnection();
        stmtQ = conn.prepareStatement("SELECT COUNT(*) FROM missions");
        rsQ = stmtQ.executeQuery();
        if (rsQ.next()) totalQuestions = rsQ.getInt(1);

        stmtS = conn.prepareStatement("SELECT COUNT(*) FROM users");
        rsS = stmtS.executeQuery();
        if (rsS.next()) totalStudents = rsS.getInt(1);

        stmtSub = conn.prepareStatement("SELECT COUNT(*) FROM mission_submissions");
        rsSub = stmtSub.executeQuery();
        if (rsSub.next()) totalSubmissions = rsSub.getInt(1);
    } catch (Exception ignored) {
    } finally {
        DBConnection.close(rsQ, rsS, rsSub, stmtQ, stmtS, stmtSub, conn);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Dashboard - CodeQuest</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <!-- Admin Navigation Bar -->
        <nav class="navbar">
            <a href="admin-dashboard.jsp" class="nav-brand">
                <div class="brand-icon" style="background: linear-gradient(135deg, #ff3366, #c9184a);">AD</div>
                <div class="brand-text">CodeQuest <span style="font-size: 0.8rem; color: #ff3366;">[COMMAND]</span></div>
            </a>
            <ul class="nav-links">
                <li><a href="admin-dashboard.jsp" class="active"><span>📊</span> Cockpit</a></li>
                <li><a href="add-question.jsp"><span>➕</span> Add Mission</a></li>
                <li><a href="view-questions"><span>📋</span> Question Vault</a></li>
                <li><a href="leaderboard"><span>🏆</span> Live Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <div class="nav-profile-pill" style="border-color: rgba(255, 51, 102, 0.4);">
                    <span style="color: #ff3366; font-weight: 700;">🛡️ <%= adminUsername %></span>
                </div>
                <a href="admin-logout" class="btn btn-danger btn-sm">Terminate Session</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <!-- Welcome Banner -->
                <div class="profile-banner" style="border-top: 3px solid #ff3366;">
                    <div class="profile-identity">
                        <div class="profile-avatar" style="border-color: #ff3366; box-shadow: 0 0 25px rgba(255, 51, 102, 0.3);">
                            👑
                        </div>
                        <div>
                            <h1 class="profile-name"><%= (adminName != null ? adminName : "Command Master") %></h1>
                            <div style="display: flex; gap: 0.5rem; align-items: center;">
                                <span class="profile-role-tag" style="border-color: #ff3366; color: #ff3366; background: rgba(255, 51, 102, 0.1);">
                                    <%= adminRole %>
                                </span>
                                <span style="font-family: var(--font-code); font-size: 0.8rem; color: var(--text-muted);">
                                    ID #<%= adminId %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="profile-stats-cluster">
                        <div class="stat-block">
                            <div class="stat-block-num emerald"><%= totalQuestions %></div>
                            <div class="stat-block-text">Active Missions</div>
                        </div>
                        <div class="stat-block">
                            <div class="stat-block-num cyan"><%= totalStudents %></div>
                            <div class="stat-block-text">Registered Students</div>
                        </div>
                        <div class="stat-block">
                            <div class="stat-block-num gold"><%= totalSubmissions %></div>
                            <div class="stat-block-text">Logged Attempts</div>
                        </div>
                    </div>
                </div>

                <!-- Admin Action Deck -->
                <div class="section-header" style="text-align: left; margin-bottom: 1.5rem;">
                    <span class="section-tagline" style="color: #ff3366;">Administrative Functions</span>
                    <h2 class="section-title">Mission Forge & Operations</h2>
                </div>

                <div class="features-grid" style="margin-top: 1rem;">
                    <div class="feature-card" style="border-top: 2px solid var(--neon-emerald);">
                        <div class="feature-icon">➕</div>
                        <h3 class="feature-title">Add Programming Question</h3>
                        <p class="feature-desc" style="margin-bottom: 1.5rem;">
                            Author and dynamically insert new Java, SQL, or DSA questions with 4 choices, 
                            configured correct answers, and customizable XP rewards.
                        </p>
                        <a href="add-question.jsp" class="btn btn-primary btn-sm">Forge New Mission &rarr;</a>
                    </div>

                    <div class="feature-card" style="border-top: 2px solid var(--cyber-cyan);">
                        <div class="feature-icon">📋</div>
                        <h3 class="feature-title">Question Vault</h3>
                        <p class="feature-desc" style="margin-bottom: 1.5rem;">
                            View complete inventory of programming missions in a dynamic tabular interface, 
                            track categories, inspect difficulty distributions, and delete old quests.
                        </p>
                        <a href="view-questions" class="btn btn-cyber btn-sm">Inspect All Missions &rarr;</a>
                    </div>

                    <div class="feature-card" style="border-top: 2px solid var(--solar-gold);">
                        <div class="feature-icon">🏆</div>
                        <h3 class="feature-title">Real-Time Leaderboard</h3>
                        <p class="feature-desc" style="margin-bottom: 1.5rem;">
                            Inspect the public student arena rankings, analyze XP progressions, 
                            and examine top 3 podium warriors in real time.
                        </p>
                        <a href="leaderboard" class="btn btn-outline btn-sm">View Leaderboard &rarr;</a>
                    </div>
                </div>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 4: Administrative Dashboard.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

