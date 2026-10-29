<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - Check student session
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    Integer xp = (Integer) session.getAttribute("xp");
    Integer level = (Integer) session.getAttribute("level");

    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Access+restricted.+Please+authenticate.");
        return;
    }

    List<Mission> missionsList = (List<Mission>) request.getAttribute("missionsList");
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    String selectedDifficulty = (String) request.getAttribute("selectedDifficulty");
    Integer totalCountObj = (Integer) request.getAttribute("totalCount");
    Integer solvedCountObj = (Integer) request.getAttribute("solvedCount");
    String errorMessage = (String) request.getAttribute("errorMessage");

    if (selectedCategory == null) selectedCategory = "All";
    if (selectedDifficulty == null) selectedDifficulty = "All";
    int totalCount = (totalCountObj != null) ? totalCountObj : 0;
    int solvedCount = (solvedCountObj != null) ? solvedCountObj : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Programming Missions Arena - CodeQuest</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <!-- Navigation Bar -->
        <nav class="navbar">
            <a href="dashboard" class="nav-brand">
                <div class="brand-icon">CQ</div>
                <div class="brand-text">CodeQuest</div>
            </a>
            <ul class="nav-links">
                <li><a href="dashboard"><span>📊</span> Cockpit</a></li>
                <li><a href="missions" class="active"><span>⚔️</span> Missions</a></li>
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <div class="nav-profile-pill">
                    <span class="nav-level-tag">LVL <%= (level != null ? level : 1) %></span>
                    <span style="color: var(--text-pure); font-weight: 600;"><%= username %></span>
                    <span class="nav-xp-counter"><%= (xp != null ? xp : 0) %> XP</span>
                </div>
                <a href="logout" class="btn btn-outline btn-sm">Sign Out</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <div class="section-header" style="text-align: left; margin-bottom: 2rem;">
                    <span class="section-tagline">Module 9: Programming Missions Arena</span>
                    <h2 class="section-title">Algorithmic Mission Deck</h2>
                    <p class="section-desc" style="margin: 0.25rem 0 0;">
                        Solve domain challenges to harvest XP and ascend tiers. Remember: <strong>One attempt allowed per mission</strong>.
                    </p>
                </div>

                <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                    <div class="alert alert-danger">
                        <span>⚠️</span>
                        <div><%= errorMessage %></div>
                    </div>
                <% } %>

                <!-- Interactive Multi-Filter Bar -->
                <div class="mission-filter-bar">
                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <span style="font-family: var(--font-code); font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase;">
                            Domain Category:
                        </span>
                        <div class="filter-pills">
                            <a href="missions?category=All&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("All".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               🌐 All Domains
                            </a>
                            <a href="missions?category=Java&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("Java".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               ☕ Java
                            </a>
                            <a href="missions?category=SQL&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("SQL".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               🗄️ SQL
                            </a>
                            <a href="missions?category=DSA&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("DSA".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               ⚡ DSA
                            </a>
                        </div>
                    </div>

                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <span style="font-family: var(--font-code); font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase;">
                            Difficulty:
                        </span>
                        <div class="filter-pills">
                            <a href="missions?category=<%= selectedCategory %>&difficulty=All" 
                               class="filter-pill <%= ("All".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               All Tiers
                            </a>
                            <a href="missions?category=<%= selectedCategory %>&difficulty=Easy" 
                               class="filter-pill <%= ("Easy".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               🟢 Easy
                            </a>
                            <a href="missions?category=<%= selectedCategory %>&difficulty=Medium" 
                               class="filter-pill <%= ("Medium".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               🟡 Medium
                            </a>
                            <a href="missions?category=<%= selectedCategory %>&difficulty=Hard" 
                               class="filter-pill <%= ("Hard".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               🔴 Hard
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Quest Deck Grid -->
                <% if (missionsList != null && !missionsList.isEmpty()) { %>
                    <div class="missions-deck">
                        <%-- Scriptlet iteration through missions --%>
                        <% for (Mission m : missionsList) { %>
                            <div class="quest-card <%= (m.isSolved() ? "solved-card" : "") %>" 
                                 data-category="<%= m.getCategory() %>" 
                                 data-difficulty="<%= m.getDifficulty() %>">
                                
                                <div>
                                    <div class="quest-card-header">
                                        <% if ("Java".equalsIgnoreCase(m.getCategory())) { %>
                                            <span class="quest-category-badge category-java">☕ Java</span>
                                        <% } else if ("SQL".equalsIgnoreCase(m.getCategory())) { %>
                                            <span class="quest-category-badge category-sql">🗄️ SQL</span>
                                        <% } else { %>
                                            <span class="quest-category-badge category-dsa">⚡ DSA</span>
                                        <% } %>

                                        <div style="display: flex; gap: 0.45rem; align-items: center;">
                                            <% if ("Easy".equalsIgnoreCase(m.getDifficulty())) { %>
                                                <span class="difficulty-tag diff-easy">🟢 Easy</span>
                                            <% } else if ("Medium".equalsIgnoreCase(m.getDifficulty())) { %>
                                                <span class="difficulty-tag diff-medium">🟡 Medium</span>
                                            <% } else { %>
                                                <span class="difficulty-tag diff-hard">🔴 Hard</span>
                                            <% } %>

                                            <% if (m.isSolved()) { %>
                                                <span style="font-family: var(--font-code); font-size: 0.72rem; color: var(--neon-emerald); background: rgba(0,245,160,0.15); border: 1px solid var(--neon-emerald); padding: 0.2rem 0.5rem; border-radius: 4px; font-weight: 700;">
                                                    ✓ COMPLETED
                                                </span>
                                            <% } %>
                                        </div>
                                    </div>

                                    <h3 class="quest-title"><%= SecurityUtil.encodeHtml(m.getTitle()) %></h3>
                                    <p class="quest-desc"><%= SecurityUtil.encodeHtml(m.getDescription()) %></p>
                                </div>

                                <!-- Answer Submission Form -->
                                <form action="submit-answer" method="POST">
                                    <input type="hidden" name="missionId" value="<%= m.getId() %>">

                                    <div class="options-cluster">
                                        <label class="option-item <%= (m.isSolved() && "A".equalsIgnoreCase(m.getUserChoice()) ? "selected" : "") %>">
                                            <input type="radio" name="selectedOption" value="A" required <%= (m.isSolved() ? "disabled" : "") %>>
                                            <span class="option-key">A</span>
                                            <span class="option-text"><%= SecurityUtil.encodeHtml(m.getOptionA()) %></span>
                                        </label>

                                        <label class="option-item <%= (m.isSolved() && "B".equalsIgnoreCase(m.getUserChoice()) ? "selected" : "") %>">
                                            <input type="radio" name="selectedOption" value="B" required <%= (m.isSolved() ? "disabled" : "") %>>
                                            <span class="option-key">B</span>
                                            <span class="option-text"><%= SecurityUtil.encodeHtml(m.getOptionB()) %></span>
                                        </label>

                                        <label class="option-item <%= (m.isSolved() && "C".equalsIgnoreCase(m.getUserChoice()) ? "selected" : "") %>">
                                            <input type="radio" name="selectedOption" value="C" required <%= (m.isSolved() ? "disabled" : "") %>>
                                            <span class="option-key">C</span>
                                            <span class="option-text"><%= SecurityUtil.encodeHtml(m.getOptionC()) %></span>
                                        </label>

                                        <label class="option-item <%= (m.isSolved() && "D".equalsIgnoreCase(m.getUserChoice()) ? "selected" : "") %>">
                                            <input type="radio" name="selectedOption" value="D" required <%= (m.isSolved() ? "disabled" : "") %>>
                                            <span class="option-key">D</span>
                                            <span class="option-text"><%= SecurityUtil.encodeHtml(m.getOptionD()) %></span>
                                        </label>
                                    </div>

                                    <div class="quest-card-footer">
                                        <div class="quest-xp-badge">
                                            <span>⚡</span>
                                            <span>+<%= m.getXpReward() %> XP</span>
                                        </div>

                                        <% if (m.isSolved()) { %>
                                            <button type="button" class="btn btn-outline btn-sm" disabled style="opacity: 0.6; cursor: not-allowed;">
                                                🔒 Locked (Attempted)
                                            </button>
                                        <% } else { %>
                                            <button type="submit" class="btn btn-outline btn-sm" disabled>
                                                Select Choice & Submit
                                            </button>
                                        <% } %>
                                    </div>
                                </form>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">🔍</div>
                        <h3 style="color: var(--text-pure); font-family: var(--font-heading); margin-bottom: 0.5rem;">
                            No Matches in Registry
                        </h3>
                        <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">
                            No programming quests match the selected category (<%= selectedCategory %>) and difficulty (<%= selectedDifficulty %>).
                        </p>
                        <a href="missions?category=All&difficulty=All" class="btn btn-outline-cyan">Reset All Filters</a>
                    </div>
                <% } %>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 9: Programming Missions Display.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

