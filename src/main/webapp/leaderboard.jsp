<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.codequest.util.DBConnection" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - Retrieve leaderboard data
    List<Map<String, Object>> leaderboard = (List<Map<String, Object>>) request.getAttribute("leaderboardList");

    // Fallback: If accessed directly as leaderboard.jsp, load data using DBConnection
    if (leaderboard == null) {
        leaderboard = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
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
                Map<String, Object> player = new java.util.HashMap<>();
                player.put("rank", rank++);
                player.put("id", rs.getInt("id"));
                player.put("username", rs.getString("username"));
                player.put("xp", rs.getInt("xp"));
                player.put("level", rs.getInt("level"));
                player.put("completedMissions", rs.getInt("completed_missions"));
                leaderboard.add(player);
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading leaderboard data: " + e.getMessage());
        } finally {
            DBConnection.close(rs, stmt, conn);
        }
    }

    String currentSessionUser = (String) session.getAttribute("username");
    String errorMessage = (String) request.getAttribute("errorMessage");

    // Separate top 3 players for the Olympic 3D podium stage
    Map<String, Object> firstPlace = (leaderboard != null && leaderboard.size() > 0) ? leaderboard.get(0) : null;
    Map<String, Object> secondPlace = (leaderboard != null && leaderboard.size() > 1) ? leaderboard.get(1) : null;
    Map<String, Object> thirdPlace = (leaderboard != null && leaderboard.size() > 2) ? leaderboard.get(2) : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Arena Leaderboard - CodeQuest</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <nav class="navbar">
            <a href="index.html" class="nav-brand">
                <div class="brand-icon">CQ</div>
                <div class="brand-text">CodeQuest</div>
            </a>
            <ul class="nav-links">
                <li><a href="index.html"><span>🏠</span> Home</a></li>
                <li><a href="missions"><span>⚔️</span> Missions</a></li>
                <li><a href="leaderboard" class="active"><span>🏆</span> Leaderboard</a></li>
                <% if (currentSessionUser != null) { %>
                    <li><a href="dashboard"><span>📊</span> Cockpit</a></li>
                <% } else { %>
                    <li><a href="login.jsp"><span>🔑</span> Student Portal</a></li>
                <% } %>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <% if (currentSessionUser != null) { %>
                    <a href="dashboard" class="btn btn-outline-cyan btn-sm"><%= currentSessionUser %> (Cockpit)</a>
                <% } else { %>
                    <a href="login.jsp" class="btn btn-primary btn-sm">Enter Arena</a>
                <% } %>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <div class="section-header">
                    <span class="section-tagline">Module 11: Real-Time Global Ranking</span>
                    <h2 class="section-title">Hall of Grandmasters</h2>
                    <p class="section-desc">
                        Top code warriors ranked by total accumulated XP and completed mission milestones. 
                        Updates dynamically upon every confirmed submission.
                    </p>
                </div>

                <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                    <div class="alert alert-danger">
                        <span>⚠️</span>
                        <div><%= errorMessage %></div>
                    </div>
                <% } %>

                <% if (leaderboard != null && !leaderboard.isEmpty()) { %>
                    <!-- Olympic 3D Gaming Podium Stage for Top 3 -->
                    <div class="podium-stage">
                        <!-- 2nd Place (Silver) -->
                        <% if (secondPlace != null) { %>
                            <div class="podium-place place-2">
                                <div class="podium-avatar">
                                    🥈
                                </div>
                                <div class="podium-name"><%= SecurityUtil.encodeHtml((String) secondPlace.get("username")) %></div>
                                <div class="podium-xp">⚡ <%= secondPlace.get("xp") %> XP</div>
                                <div class="podium-pedestal">
                                    <span>2</span>
                                    <span style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px;">SILVER</span>
                                </div>
                            </div>
                        <% } %>

                        <!-- 1st Place (Gold Crown) -->
                        <% if (firstPlace != null) { %>
                            <div class="podium-place place-1">
                                <div class="podium-avatar">
                                    <span class="podium-crown">👑</span>
                                    🥇
                                </div>
                                <div class="podium-name" style="color: #ffd700;"><%= SecurityUtil.encodeHtml((String) firstPlace.get("username")) %></div>
                                <div class="podium-xp" style="color: #ffd700; font-size: 1rem;">⚡ <%= firstPlace.get("xp") %> XP</div>
                                <div class="podium-pedestal">
                                    <span>1</span>
                                    <span style="font-size: 0.85rem; text-transform: uppercase; letter-spacing: 2px;">CHAMPION</span>
                                </div>
                            </div>
                        <% } %>

                        <!-- 3rd Place (Bronze) -->
                        <% if (thirdPlace != null) { %>
                            <div class="podium-place place-3">
                                <div class="podium-avatar">
                                    🥉
                                </div>
                                <div class="podium-name"><%= SecurityUtil.encodeHtml((String) thirdPlace.get("username")) %></div>
                                <div class="podium-xp">⚡ <%= thirdPlace.get("xp") %> XP</div>
                                <div class="podium-pedestal">
                                    <span>3</span>
                                    <span style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px;">BRONZE</span>
                                </div>
                            </div>
                        <% } %>
                    </div>

                    <!-- Full Ranking Cyber Table -->
                    <div class="card" style="padding: 1.5rem;">
                        <div class="table-responsive">
                            <table class="cyber-table">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">Rank</th>
                                        <th>Warrior</th>
                                        <th>Tier Level</th>
                                        <th>Completed Missions</th>
                                        <th style="text-align: right;">Total Experience (XP)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%-- Scriptlet iteration through full ranked players --%>
                                    <% for (Map<String, Object> p : leaderboard) { 
                                        int r = (Integer) p.get("rank");
                                        String uname = (String) p.get("username");
                                        boolean isCurrent = uname != null && uname.equalsIgnoreCase(currentSessionUser);
                                    %>
                                        <% if (isCurrent) { %>
                                            <tr style="background: rgba(0, 245, 160, 0.08); border-color: var(--neon-emerald);">
                                        <% } else { %>
                                            <tr>
                                        <% } %>
                                            <td>
                                                <% if (r == 1) { %>
                                                    <span class="rank-badge rank-1">🥇 1</span>
                                                <% } else if (r == 2) { %>
                                                    <span class="rank-badge rank-2">🥈 2</span>
                                                <% } else if (r == 3) { %>
                                                    <span class="rank-badge rank-3">🥉 3</span>
                                                <% } else { %>
                                                    <span class="rank-badge">#<%= r %></span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <div style="display: flex; align-items: center; gap: 0.65rem;">
                                                    <strong style="color: var(--text-pure); font-size: 1.05rem;"><%= SecurityUtil.encodeHtml(uname) %></strong>
                                                    <% if (isCurrent) { %>
                                                        <span style="font-family: var(--font-code); font-size: 0.7rem; color: var(--neon-emerald); background: rgba(0,245,160,0.15); border: 1px solid var(--neon-emerald); padding: 0.1rem 0.4rem; border-radius: 4px;">
                                                            YOU
                                                        </span>
                                                    <% } %>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="nav-level-tag">
                                                    Level <%= p.get("level") %>
                                                </span>
                                            </td>
                                            <td>
                                                <span style="font-family: var(--font-code); color: var(--cyber-cyan); font-weight: 600;">
                                                    🎯 <%= p.get("completedMissions") %> Solved
                                                </span>
                                            </td>
                                            <td style="text-align: right;">
                                                <span style="color: var(--solar-gold); font-family: var(--font-code); font-weight: 700; font-size: 1.15rem;">
                                                    ⚡ <%= p.get("xp") %> XP
                                                </span>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <% } else { %>
                    <!-- Empty State Message when no players are available -->
                    <div class="empty-state">
                        <div class="empty-state-icon">🛡️</div>
                        <h3 style="color: var(--text-pure); font-family: var(--font-heading); margin-bottom: 0.5rem;">
                            Arena Roster Empty
                        </h3>
                        <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">
                            No warriors have registered or earned XP in this arena iteration. Be the first hero to claim Rank #1!
                        </p>
                        <a href="register.jsp" class="btn btn-primary">Enlist First Warrior Account</a>
                    </div>
                <% } %>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 11: Global Leaderboard.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

