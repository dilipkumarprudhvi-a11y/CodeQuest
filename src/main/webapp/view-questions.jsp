<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - Admin session check
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Admin+clearance+required");
        return;
    }

    // Retrieve list forwarded by ViewQuestionsServlet via RequestDispatcher
    List<Mission> missionsList = (List<Mission>) request.getAttribute("missionsList");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String created = request.getParameter("created");
    String deleted = request.getParameter("deleted");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Question Vault Management - CodeQuest Admin</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <nav class="navbar">
            <a href="admin-dashboard.jsp" class="nav-brand">
                <div class="brand-icon" style="background: linear-gradient(135deg, #ff3366, #c9184a);">AD</div>
                <div class="brand-text">CodeQuest <span style="font-size: 0.8rem; color: #ff3366;">[COMMAND]</span></div>
            </a>
            <ul class="nav-links">
                <li><a href="admin-dashboard.jsp"><span>📊</span> Cockpit</a></li>
                <li><a href="add-question.jsp"><span>➕</span> Add Mission</a></li>
                <li><a href="view-questions" class="active"><span>📋</span> Question Vault</a></li>
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <a href="add-question.jsp" class="btn btn-admin btn-sm">➕ Add Mission</a>
                <a href="admin-logout" class="btn btn-danger btn-sm">Exit</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <div class="section-header" style="text-align: left; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <span class="section-tagline" style="color: #ff3366;">Module 7: Admin Question Management</span>
                        <h2 class="section-title">Programming Question Vault</h2>
                        <p class="section-desc" style="margin: 0.25rem 0 0;">
                            Live catalog of stored programming missions retrieved dynamically via JDBC.
                        </p>
                    </div>
                    <a href="add-question.jsp" class="btn btn-primary">➕ Forge New Mission</a>
                </div>

                <% if ("true".equalsIgnoreCase(created)) { %>
                    <div class="alert alert-success">
                        <span>✨</span>
                        <div>New mission persisted and deployed into curriculum registry!</div>
                    </div>
                <% } %>

                <% if ("true".equalsIgnoreCase(deleted)) { %>
                    <div class="alert alert-info">
                        <span>🗑️</span>
                        <div>Mission record eradicated from database.</div>
                    </div>
                <% } %>

                <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                    <div class="alert alert-danger">
                        <span>⚠️</span>
                        <div><%= errorMessage %></div>
                    </div>
                <% } %>

                <% if (missionsList != null && !missionsList.isEmpty()) { %>
                    <div class="card" style="padding: 1.5rem;">
                        <div class="table-responsive">
                            <table class="cyber-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Mission Title</th>
                                        <th>Domain</th>
                                        <th>Difficulty</th>
                                        <th>XP Bounty</th>
                                        <th>Correct Key</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%-- Scriptlet iteration through missions list --%>
                                    <% for (Mission m : missionsList) { %>
                                        <tr>
                                            <td style="font-family: var(--font-code); color: var(--text-muted);">
                                                #<%= m.getId() %>
                                            </td>
                                            <td>
                                                <strong style="color: var(--text-pure);"><%= SecurityUtil.encodeHtml(m.getTitle()) %></strong>
                                                <div style="font-size: 0.8rem; color: var(--text-muted); max-width: 420px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-top: 0.2rem;">
                                                    <%= SecurityUtil.encodeHtml(m.getDescription()) %>
                                                </div>
                                            </td>
                                            <td>
                                                <% if ("Java".equalsIgnoreCase(m.getCategory())) { %>
                                                    <span class="quest-category-badge category-java">☕ Java</span>
                                                <% } else if ("SQL".equalsIgnoreCase(m.getCategory())) { %>
                                                    <span class="quest-category-badge category-sql">🗄️ SQL</span>
                                                <% } else { %>
                                                    <span class="quest-category-badge category-dsa">⚡ DSA</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <% if ("Easy".equalsIgnoreCase(m.getDifficulty())) { %>
                                                    <span class="difficulty-tag diff-easy">🟢 Easy</span>
                                                <% } else if ("Medium".equalsIgnoreCase(m.getDifficulty())) { %>
                                                    <span class="difficulty-tag diff-medium">🟡 Medium</span>
                                                <% } else { %>
                                                    <span class="difficulty-tag diff-hard">🔴 Hard</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <span style="color: var(--solar-gold); font-family: var(--font-code); font-weight: 700;">
                                                    +<%= m.getXpReward() %> XP
                                                </span>
                                            </td>
                                            <td>
                                                <span style="font-family: var(--font-code); color: var(--neon-emerald); font-weight: 700; background: rgba(0,245,160,0.1); padding: 0.2rem 0.5rem; border-radius: 4px;">
                                                    [<%= m.getCorrectOption() %>]
                                                </span>
                                            </td>
                                            <td>
                                                <form action="view-questions" method="POST" style="display: inline;" onsubmit="return confirm('Are you certain you wish to eliminate Mission #<%= m.getId() %>?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= m.getId() %>">
                                                    <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                                </form>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">📭</div>
                        <h3 style="color: var(--text-pure); font-family: var(--font-heading); margin-bottom: 0.5rem;">
                            No Programming Missions Found
                        </h3>
                        <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">
                            The curriculum registry is currently devoid of challenges. Use the Mission Forge to seed your first questions.
                        </p>
                        <a href="add-question.jsp" class="btn btn-primary">➕ Forge First Mission</a>
                    </div>
                <% } %>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 7: Admin Question Management.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

