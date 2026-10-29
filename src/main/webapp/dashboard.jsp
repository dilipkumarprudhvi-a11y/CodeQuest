<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.codequest.model.User" %>
<%@ page import="com.codequest.model.Submission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - Check student session
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Session+expired.+Please+log+in.");
        return;
    }

    User student = (User) request.getAttribute("student");
    Integer completedMissionsObj = (Integer) request.getAttribute("completedMissions");
    Integer totalAvailableObj = (Integer) request.getAttribute("totalAvailableMissions");
    List<Submission> recentSubmissions = (List<Submission>) request.getAttribute("recentSubmissions");
    String errorMessage = (String) request.getAttribute("errorMessage");

    int completedCount = (completedMissionsObj != null) ? completedMissionsObj : 0;
    int totalCount = (totalAvailableObj != null) ? totalAvailableObj : 0;

    if (student == null) {
        // Fallback to session values if direct navigation occurred
        student = new User();
        student.setId(userId);
        student.setUsername((String) session.getAttribute("username"));
        Object sXp = session.getAttribute("xp");
        student.setXp(sXp instanceof Integer ? (Integer) sXp : 0);
        Object sLvl = session.getAttribute("level");
        student.setLevel(sLvl instanceof Integer ? (Integer) sLvl : 1);
    }

    int nextLvlThreshold = student.getNextLevelThreshold();
    int progressPercent = student.getLevelProgressPercent();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= student.getUsername() %> - Student Cockpit - CodeQuest</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <nav class="navbar">
            <a href="dashboard" class="nav-brand">
                <div class="brand-icon">CQ</div>
                <div class="brand-text">CodeQuest</div>
            </a>
            <ul class="nav-links">
                <li><a href="dashboard" class="active"><span>📊</span> Cockpit</a></li>
                <li><a href="missions"><span>⚔️</span> Missions</a></li>
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <div class="nav-profile-pill">
                    <span class="nav-level-tag">LVL <%= student.getLevel() %></span>
                    <span style="color: var(--text-pure); font-weight: 600;"><%= SecurityUtil.encodeHtml(student.getUsername()) %></span>
                    <span class="nav-xp-counter"><%= student.getXp() %> XP</span>
                </div>
                <a href="logout" class="btn btn-outline btn-sm">Sign Out</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                    <div class="alert alert-danger">
                        <span>⚠️</span>
                        <div><%= errorMessage %></div>
                    </div>
                <% } %>

                <!-- Student Profile Banner -->
                <div class="profile-banner">
                    <div class="profile-identity">
                        <div class="profile-avatar">
                            <% if (student.getLevel() >= 5) { %>🧙‍♂️<% } 
                               else if (student.getLevel() >= 4) { %>⚔️<% } 
                               else if (student.getLevel() >= 3) { %>🛡️<% } 
                               else if (student.getLevel() >= 2) { %>⚡<% } 
                               else { %>🐣<% } %>
                        </div>
                        <div>
                            <h1 class="profile-name"><%= SecurityUtil.encodeHtml(student.getUsername()) %></h1>
                            <div style="display: flex; gap: 0.65rem; align-items: center; flex-wrap: wrap;">
                                <span class="profile-role-tag">
                                    <% if (student.getLevel() >= 5) { %>Grandmaster Architect<% } 
                                       else if (student.getLevel() >= 4) { %>Code Vanguard<% } 
                                       else if (student.getLevel() >= 3) { %>Kernel Warrior<% } 
                                       else if (student.getLevel() >= 2) { %>Syntax Apprentice<% } 
                                       else { %>Novice Cadet<% } %>
                                </span>
                                <span style="font-family: var(--font-code); font-size: 0.8rem; color: var(--text-muted);">
                                    Cadet ID #<%= student.getId() %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="profile-stats-cluster">
                        <div class="stat-block">
                            <div class="stat-block-num gold"><%= student.getXp() %></div>
                            <div class="stat-block-text">Total Accumulated XP</div>
                        </div>
                        <div class="stat-block">
                            <div class="stat-block-num emerald">Level <%= student.getLevel() %></div>
                            <div class="stat-block-text">Current Tier</div>
                        </div>
                        <div class="stat-block">
                            <div class="stat-block-num cyan"><%= completedCount %> / <%= totalCount %></div>
                            <div class="stat-block-text">Missions Conquered</div>
                        </div>
                    </div>
                </div>

                <!-- XP & Level Progress Tracker -->
                <div class="xp-tracker-card">
                    <div class="xp-header">
                        <div class="xp-label">
                            <span>🚀 Tier Advancement Calibration</span>
                            <span style="font-family: var(--font-code); color: var(--neon-emerald); font-size: 0.85rem;">
                                [<%= progressPercent %>% Complete]
                            </span>
                        </div>
                        <div class="xp-numbers">
                            <span class="current"><%= student.getXp() %> XP</span>
                            <span> / <%= nextLvlThreshold %> XP for Level <%= (student.getLevel() + 1) %></span>
                        </div>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill" data-progress="<%= progressPercent %>"></div>
                    </div>
                    <script>
                        (function() {
                            var bar = document.querySelector('.progress-fill');
                            if (bar) bar.style.width = '<%= progressPercent %>%';
                        })();
                    </script>
                </div>

                <!-- Cockpit Actions & Battle History -->
                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 2rem;">
                    <!-- Left: Recent Battle Log -->
                    <div class="card" style="padding: 1.75rem;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem;">
                            <h3 style="font-family: var(--font-heading); font-size: 1.35rem; color: var(--text-pure);">
                                📜 Recent Mission Submissions
                            </h3>
                            <a href="missions" class="btn btn-outline-cyan btn-sm">Enter Arena &rarr;</a>
                        </div>

                        <% if (recentSubmissions != null && !recentSubmissions.isEmpty()) { %>
                            <div class="table-responsive">
                                <table class="cyber-table">
                                    <thead>
                                        <tr>
                                            <th>Mission</th>
                                            <th>Choice</th>
                                            <th>Evaluation</th>
                                            <th>XP Gain</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Submission sub : recentSubmissions) { %>
                                            <tr>
                                                <td>
                                                    <div style="font-weight: 600; color: var(--text-pure);">
                                                        <%= SecurityUtil.encodeHtml(sub.getMissionTitle()) %>
                                                    </div>
                                                    <% if ("Java".equalsIgnoreCase(sub.getCategory())) { %>
                                                        <span class="quest-category-badge category-java" style="font-size: 0.65rem; padding: 0.1rem 0.4rem;"><%= sub.getCategory() %></span>
                                                    <% } else if ("SQL".equalsIgnoreCase(sub.getCategory())) { %>
                                                        <span class="quest-category-badge category-sql" style="font-size: 0.65rem; padding: 0.1rem 0.4rem;"><%= sub.getCategory() %></span>
                                                    <% } else { %>
                                                        <span class="quest-category-badge category-dsa" style="font-size: 0.65rem; padding: 0.1rem 0.4rem;"><%= sub.getCategory() %></span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <span style="font-family: var(--font-code); color: var(--cyber-cyan); font-weight: 700;">
                                                        [<%= sub.getSelectedOption() %>]
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if (sub.isCorrect()) { %>
                                                        <span style="color: var(--neon-emerald); font-weight: 700; font-family: var(--font-code);">
                                                            ✓ VICTORY
                                                        </span>
                                                    <% } else { %>
                                                        <span style="color: var(--danger-crimson); font-weight: 700; font-family: var(--font-code);">
                                                            ✗ DEFEAT
                                                        </span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <span style="color: var(--solar-gold); font-family: var(--font-code); font-weight: 700;">
                                                        +<%= sub.getXpAwarded() %> XP
                                                    </span>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        <% } else { %>
                            <div class="empty-state" style="padding: 2.5rem 1rem;">
                                <div class="empty-state-icon" style="font-size: 2rem;">⚔️</div>
                                <h4 style="color: var(--text-pure); margin-bottom: 0.5rem; font-family: var(--font-heading);">
                                    Zero Quests Undertaken
                                </h4>
                                <p style="color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 1.25rem;">
                                    Your combat log is empty. Deploy to the Programming Missions arena to test your skills!
                                </p>
                                <a href="missions" class="btn btn-primary btn-sm">Launch Available Missions</a>
                            </div>
                        <% } %>
                    </div>

                    <!-- Right: Quick Navigation Card -->
                    <div style="display: flex; flex-direction: column; gap: 1.5rem;">
                        <div class="card" style="padding: 1.75rem; background: linear-gradient(180deg, rgba(0,245,160,0.06), var(--bg-surface));">
                            <h3 style="font-family: var(--font-heading); font-size: 1.25rem; color: var(--neon-emerald); margin-bottom: 0.75rem;">
                                ⚡ Deploy to Missions
                            </h3>
                            <p style="color: var(--text-secondary); font-size: 0.9rem; line-height: 1.5; margin-bottom: 1.25rem;">
                                Ready to earn more XP? Solve Java syntax puzzles, SQL transaction problems, and algorithmic benchmarks.
                            </p>
                            <a href="missions" class="btn btn-primary" style="width: 100%;">
                                Launch Missions Deck
                            </a>
                        </div>

                        <div class="card" style="padding: 1.75rem; background: linear-gradient(180deg, rgba(255,184,0,0.06), var(--bg-surface));">
                            <h3 style="font-family: var(--font-heading); font-size: 1.25rem; color: var(--solar-gold); margin-bottom: 0.75rem;">
                                🏆 Global Ranking
                            </h3>
                            <p style="color: var(--text-secondary); font-size: 0.9rem; line-height: 1.5; margin-bottom: 1.25rem;">
                                Check your placement on the global leaderboard against all registered warriors.
                            </p>
                            <a href="leaderboard" class="btn btn-outline" style="width: 100%; border-color: var(--border-gold); color: var(--solar-gold);">
                                Inspect Leaderboard
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 8: Student Dashboard &amp; Progress Tracking.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

