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
    Integer userRankObj = (Integer) request.getAttribute("userRank");
    List<Submission> recentSubmissions = (List<Submission>) request.getAttribute("recentSubmissions");
    String errorMessage = (String) request.getAttribute("errorMessage");

    int completedCount = (completedMissionsObj != null) ? completedMissionsObj : 0;
    int totalCount = (totalAvailableObj != null) ? totalAvailableObj : 0;
    int userRank = (userRankObj != null) ? userRankObj : 1;

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
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='https://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='20' fill='%23000000'/%3E%3Ctext x='50' y='65' font-family='sans-serif' font-size='50' font-weight='900' fill='%23FFFF00' text-anchor='middle'%3ECQ%3C/text%3E%3C/svg%3E">
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
                <li><a href="dashboard" class="active">Cockpit</a></li>
                <li><a href="missions">Missions</a></li>
                <li><a href="leaderboard">Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">AUDIO</button>
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
                        <div><%= errorMessage %></div>
                    </div>
                <% } %>

                <!-- Student Profile Banner -->
                <div class="profile-banner">
                    <div class="profile-identity">
                        <div class="profile-avatar">
                            L<%= student.getLevel() %>
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
                        <div class="stat-block">
                            <div class="stat-block-num gold">#<%= userRank %></div>
                            <div class="stat-block-text">Global Standing</div>
                        </div>
                    </div>
                </div>

                <!-- XP & Level Progress Tracker -->
                <div class="xp-tracker-card">
                    <div class="xp-header">
                        <div class="xp-label">
                            <span>Tier Advancement Calibration</span>
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
                                Recent Mission Submissions
                            </h3>
                            <a href="missions" class="btn btn-outline-cyan btn-sm">Enter Arena &rarr;</a>
                        </div>

                        <% if (recentSubmissions != null && !recentSubmissions.isEmpty()) { %>
                            <div class="table-responsive">
                                <table class="cyber-table">
                                    <thead>
                                        <tr>
                                            <th>Mission</th>
                                            <th>Mode / Choice</th>
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
                                                    <% if ("code".equalsIgnoreCase(sub.getType())) { %>
                                                        <span style="font-family: var(--font-code); color: var(--neon-cyan); font-weight: 700;">[CODE ARENA]</span>
                                                    <% } else { %>
                                                        <span style="font-family: var(--font-code); color: var(--cyber-cyan); font-weight: 700;">
                                                            [<%= (sub.getSelectedOption() != null ? sub.getSelectedOption() : "-") %>]
                                                        </span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <% if (sub.isCorrect()) { %>
                                                        <span style="color: var(--neon-emerald); font-weight: 700; font-family: var(--font-code);">
                                                            VICTORY
                                                        </span>
                                                    <% } else { %>
                                                        <span style="color: var(--danger-crimson); font-weight: 700; font-family: var(--font-code);">
                                                            DEFEAT
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
                                <div class="empty-state-icon">ARENA</div>
                                <h4 style="color: var(--text-pure); margin-bottom: 0.4rem;">Zero Combat Telemetry</h4>
                                <p style="color: var(--text-secondary); margin-bottom: 1.25rem; font-size: 0.9rem;">
                                    You have not engaged in algorithmic combat yet. Enter the Arena to harvest XP!
                                </p>
                                <a href="missions" class="btn btn-primary btn-sm">Start First Mission</a>
                            </div>
                        <% } %>
                    </div>

                    <!-- Right: Rank Progression Roadmap -->
                    <div class="card" style="padding: 1.75rem;">
                        <h3 style="font-family: var(--font-heading); font-size: 1.35rem; color: var(--text-pure); margin-bottom: 1.25rem;">
                            Cadet Tier Hierarchy
                        </h3>

                        <div style="display: flex; flex-direction: column; gap: 0.85rem;">
                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.65rem 0.85rem; border-radius: 6px; background: <%= student.getLevel() >= 1 ? "rgba(0, 245, 160, 0.08)" : "transparent" %>; border-left: 3px solid <%= student.getLevel() >= 1 ? "var(--neon-emerald)" : "var(--border-subtle)" %>;">
                                <div>
                                    <div style="font-weight: 700; font-size: 0.9rem; color: var(--text-pure);">Level 1: Novice Cadet</div>
                                    <div style="font-size: 0.75rem; color: var(--text-muted); font-family: var(--font-code);">0 - 99 XP</div>
                                </div>
                                <% if (student.getLevel() >= 1) { %><span style="color: var(--neon-emerald); font-size: 0.8rem; font-weight: 700;">CURRENT</span><% } %>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.65rem 0.85rem; border-radius: 6px; background: <%= student.getLevel() >= 2 ? "rgba(0, 245, 160, 0.08)" : "transparent" %>; border-left: 3px solid <%= student.getLevel() >= 2 ? "var(--neon-emerald)" : "var(--border-subtle)" %>;">
                                <div>
                                    <div style="font-weight: 700; font-size: 0.9rem; color: var(--text-pure);">Level 2: Syntax Apprentice</div>
                                    <div style="font-size: 0.75rem; color: var(--text-muted); font-family: var(--font-code);">100 - 199 XP</div>
                                </div>
                                <% if (student.getLevel() >= 2) { %><span style="color: var(--neon-emerald); font-size: 0.8rem; font-weight: 700;">CURRENT</span><% } %>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.65rem 0.85rem; border-radius: 6px; background: <%= student.getLevel() >= 3 ? "rgba(0, 245, 160, 0.08)" : "transparent" %>; border-left: 3px solid <%= student.getLevel() >= 3 ? "var(--neon-emerald)" : "var(--border-subtle)" %>;">
                                <div>
                                    <div style="font-weight: 700; font-size: 0.9rem; color: var(--text-pure);">Level 3: Kernel Warrior</div>
                                    <div style="font-size: 0.75rem; color: var(--text-muted); font-family: var(--font-code);">200 - 299 XP</div>
                                </div>
                                <% if (student.getLevel() >= 3) { %><span style="color: var(--neon-emerald); font-size: 0.8rem; font-weight: 700;">CURRENT</span><% } %>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.65rem 0.85rem; border-radius: 6px; background: <%= student.getLevel() >= 4 ? "rgba(0, 245, 160, 0.08)" : "transparent" %>; border-left: 3px solid <%= student.getLevel() >= 4 ? "var(--neon-emerald)" : "var(--border-subtle)" %>;">
                                <div>
                                    <div style="font-weight: 700; font-size: 0.9rem; color: var(--text-pure);">Level 4: Code Vanguard</div>
                                    <div style="font-size: 0.75rem; color: var(--text-muted); font-family: var(--font-code);">300 - 399 XP</div>
                                </div>
                                <% if (student.getLevel() >= 4) { %><span style="color: var(--neon-emerald); font-size: 0.8rem; font-weight: 700;">CURRENT</span><% } %>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.65rem 0.85rem; border-radius: 6px; background: <%= student.getLevel() >= 5 ? "rgba(0, 245, 160, 0.08)" : "transparent" %>; border-left: 3px solid <%= student.getLevel() >= 5 ? "var(--solar-gold)" : "var(--border-subtle)" %>;">
                                <div>
                                    <div style="font-weight: 700; font-size: 0.9rem; color: var(--text-pure);">Level 5: Cyber Grandmaster</div>
                                    <div style="font-size: 0.75rem; color: var(--text-muted); font-family: var(--font-code);">400+ XP (Apex Tier)</div>
                                </div>
                                <% if (student.getLevel() >= 5) { %><span style="color: var(--solar-gold); font-size: 0.8rem; font-weight: 700;">APEX</span><% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 8: Cadet Cockpit Telemetry.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>
