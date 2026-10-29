<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - Admin session check
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/admin-login.jsp?error=Admin+clearance+required");
        return;
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String formTitle = (String) request.getAttribute("formTitle");
    String formDesc = (String) request.getAttribute("formDesc");
    String formCategory = (String) request.getAttribute("formCategory");
    String formDifficulty = (String) request.getAttribute("formDifficulty");
    String formOptA = (String) request.getAttribute("formOptA");
    String formOptB = (String) request.getAttribute("formOptB");
    String formOptC = (String) request.getAttribute("formOptC");
    String formOptD = (String) request.getAttribute("formOptD");
    String formCorrect = (String) request.getAttribute("formCorrect");
    String formXp = (String) request.getAttribute("formXp");

    if (formTitle == null) formTitle = "";
    if (formDesc == null) formDesc = "";
    if (formCategory == null) formCategory = "Java";
    if (formDifficulty == null) formDifficulty = "Medium";
    if (formOptA == null) formOptA = "";
    if (formOptB == null) formOptB = "";
    if (formOptC == null) formOptC = "";
    if (formOptD == null) formOptD = "";
    if (formCorrect == null) formCorrect = "A";
    if (formXp == null) formXp = "50";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forge Programming Mission - CodeQuest Admin</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <!-- Admin Navbar -->
        <nav class="navbar">
            <a href="admin-dashboard.jsp" class="nav-brand">
                <div class="brand-icon" style="background: linear-gradient(135deg, #ff3366, #c9184a);">AD</div>
                <div class="brand-text">CodeQuest <span style="font-size: 0.8rem; color: #ff3366;">[COMMAND]</span></div>
            </a>
            <ul class="nav-links">
                <li><a href="admin-dashboard.jsp"><span>📊</span> Cockpit</a></li>
                <li><a href="add-question.jsp" class="active"><span>➕</span> Add Mission</a></li>
                <li><a href="view-questions"><span>📋</span> Question Vault</a></li>
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <a href="admin-logout" class="btn btn-danger btn-sm">Terminate Session</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <div class="auth-wrapper-wide">
                    <div class="card card-admin">
                        <div class="card-header" style="text-align: left;">
                            <span class="section-tagline" style="color: #ff3366;">Module 6: Mission Authoring</span>
                            <h2 class="card-title">Forge New Programming Mission</h2>
                            <p class="card-subtitle">Author a battle-ready question, define multiple choice outcomes, and award XP bounties</p>
                        </div>

                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <span>⚠️</span>
                                <div><%= SecurityUtil.encodeHtml(errorMessage) %></div>
                            </div>
                        <% } %>

                        <form action="add-question" method="POST">
                            <div class="form-group">
                                <label class="form-label" for="title">Mission Title / Codename</label>
                                <input type="text" id="title" name="title" class="form-control" 
                                       placeholder="e.g. Relational Index B-Tree Balancing" 
                                       value="<%= SecurityUtil.encodeHtml(formTitle) %>" required autofocus>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="description">Problem Statement / Technical Prompt</label>
                                <textarea id="description" name="description" class="form-control" 
                                          placeholder="Detail the technical dilemma or code scenario that the cadet must analyze..." 
                                          required><%= SecurityUtil.encodeHtml(formDesc) %></textarea>
                            </div>

                            <div class="form-grid-2">
                                <div class="form-group">
                                    <label class="form-label" for="category">Technology Category</label>
                                    <select id="category" name="category" class="form-select" required>
                                        <option value="Java" <%= ("Java".equals(formCategory) ? "selected" : "") %>>☕ Java Fundamentals & JVM</option>
                                        <option value="SQL" <%= ("SQL".equals(formCategory) ? "selected" : "") %>>🗄️ SQL & Relational Databases</option>
                                        <option value="DSA" <%= ("DSA".equals(formCategory) ? "selected" : "") %>>⚡ Data Structures & Algorithms</option>
                                    </select>
                                </div>

                                <div class="form-grid-2">
                                    <div class="form-group">
                                        <label class="form-label" for="difficulty">Difficulty Tier</label>
                                        <select id="difficulty" name="difficulty" class="form-select" required>
                                            <option value="Easy" <%= ("Easy".equals(formDifficulty) ? "selected" : "") %>>🟢 Easy (Novice)</option>
                                            <option value="Medium" <%= ("Medium".equals(formDifficulty) ? "selected" : "") %>>🟡 Medium (Warrior)</option>
                                            <option value="Hard" <%= ("Hard".equals(formDifficulty) ? "selected" : "") %>>🔴 Hard (Grandmaster)</option>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label" for="xpReward">XP Bounty</label>
                                        <input type="number" id="xpReward" name="xpReward" class="form-control" 
                                               min="10" max="500" step="5" value="<%= formXp %>" required>
                                    </div>
                                </div>
                            </div>

                            <div style="margin: 1.5rem 0 1rem; border-top: 1px solid var(--border-subtle); padding-top: 1rem;">
                                <h3 style="font-family: var(--font-heading); font-size: 1.15rem; color: var(--text-pure); margin-bottom: 0.5rem;">
                                    Answer Option Matrices
                                </h3>
                                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1rem;">
                                    Provide 4 plausible choices and designate the single verified solution.
                                </p>
                            </div>

                            <div class="form-grid-2">
                                <div class="form-group">
                                    <label class="form-label" for="optionA">Option A</label>
                                    <input type="text" id="optionA" name="optionA" class="form-control" 
                                           placeholder="Choice A text" value="<%= SecurityUtil.encodeHtml(formOptA) %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="optionB">Option B</label>
                                    <input type="text" id="optionB" name="optionB" class="form-control" 
                                           placeholder="Choice B text" value="<%= SecurityUtil.encodeHtml(formOptB) %>" required>
                                </div>
                            </div>

                            <div class="form-grid-2">
                                <div class="form-group">
                                    <label class="form-label" for="optionC">Option C</label>
                                    <input type="text" id="optionC" name="optionC" class="form-control" 
                                           placeholder="Choice C text" value="<%= SecurityUtil.encodeHtml(formOptC) %>" required>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="optionD">Option D</label>
                                    <input type="text" id="optionD" name="optionD" class="form-control" 
                                           placeholder="Choice D text" value="<%= SecurityUtil.encodeHtml(formOptD) %>" required>
                                </div>
                            </div>

                            <div class="form-group" style="max-width: 300px; margin-top: 0.5rem;">
                                <label class="form-label" for="correctOption">Designated Correct Answer Choice</label>
                                <select id="correctOption" name="correctOption" class="form-select" required>
                                    <option value="A" <%= ("A".equals(formCorrect) ? "selected" : "") %>>Option A is Correct</option>
                                    <option value="B" <%= ("B".equals(formCorrect) ? "selected" : "") %>>Option B is Correct</option>
                                    <option value="C" <%= ("C".equals(formCorrect) ? "selected" : "") %>>Option C is Correct</option>
                                    <option value="D" <%= ("D".equals(formCorrect) ? "selected" : "") %>>Option D is Correct</option>
                                </select>
                            </div>

                            <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                                <button type="submit" class="btn btn-admin btn-lg">
                                    💾 Persist Mission to Database
                                </button>
                                <a href="view-questions" class="btn btn-outline btn-lg">Cancel & Return</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 6: Admin Question Creation.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

