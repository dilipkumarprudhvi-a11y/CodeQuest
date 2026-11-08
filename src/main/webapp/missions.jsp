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
    String selectedType = (String) request.getAttribute("selectedType");
    Integer totalCountObj = (Integer) request.getAttribute("totalCount");
    Integer solvedCountObj = (Integer) request.getAttribute("solvedCount");
    String errorMessage = (String) request.getAttribute("errorMessage");

    if (selectedCategory == null) selectedCategory = "All";
    if (selectedDifficulty == null) selectedDifficulty = "All";
    if (selectedType == null) selectedType = "All";
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
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='https://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='20' fill='%23000000'/%3E%3Ctext x='50' y='65' font-family='sans-serif' font-size='50' font-weight='900' fill='%23FFFF00' text-anchor='middle'%3ECQ%3C/text%3E%3C/svg%3E">
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
                <li><a href="dashboard">Cockpit</a></li>
                <li><a href="missions" class="active">Missions</a></li>
                <li><a href="leaderboard">Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">AUDIO</button>
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
                        Solve domain challenges to harvest XP and ascend tiers. Single-attempt rule strictly enforced for official rankings.
                    </p>
                </div>

                <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                    <div class="alert alert-danger">
                        <div><%= errorMessage %></div>
                    </div>
                <% } %>

                <!-- Interactive Multi-Filter Bar -->
                <div class="mission-filter-bar">
                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <span style="font-family: var(--font-code); font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase;">
                            Challenge Mode:
                        </span>
                        <div class="filter-pills">
                            <a href="missions?type=All&category=<%= selectedCategory %>&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("All".equalsIgnoreCase(selectedType) ? "active" : "") %>">
                               All Modes
                            </a>
                            <a href="missions?type=code&category=<%= selectedCategory %>&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("code".equalsIgnoreCase(selectedType) ? "active" : "") %>">
                               Coding Arena
                            </a>
                            <a href="missions?type=mcq&category=<%= selectedCategory %>&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("mcq".equalsIgnoreCase(selectedType) ? "active" : "") %>">
                               Concept Checks
                            </a>
                        </div>
                    </div>

                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <span style="font-family: var(--font-code); font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase;">
                            Domain Category:
                        </span>
                        <div class="filter-pills">
                            <a href="missions?type=<%= selectedType %>&category=All&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("All".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               All Domains
                            </a>
                            <a href="missions?type=<%= selectedType %>&category=Java&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("Java".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               Java
                            </a>
                            <a href="missions?type=<%= selectedType %>&category=SQL&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("SQL".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               SQL
                            </a>
                            <a href="missions?type=<%= selectedType %>&category=DSA&difficulty=<%= selectedDifficulty %>" 
                               class="filter-pill <%= ("DSA".equalsIgnoreCase(selectedCategory) ? "active" : "") %>">
                               DSA
                            </a>
                        </div>
                    </div>

                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <span style="font-family: var(--font-code); font-size: 0.85rem; color: var(--text-muted); text-transform: uppercase;">
                            Difficulty:
                        </span>
                        <div class="filter-pills">
                            <a href="missions?type=<%= selectedType %>&category=<%= selectedCategory %>&difficulty=All" 
                               class="filter-pill <%= ("All".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               All Tiers
                            </a>
                            <a href="missions?type=<%= selectedType %>&category=<%= selectedCategory %>&difficulty=Easy" 
                               class="filter-pill <%= ("Easy".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               Easy
                            </a>
                            <a href="missions?type=<%= selectedType %>&category=<%= selectedCategory %>&difficulty=Medium" 
                               class="filter-pill <%= ("Medium".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               Medium
                            </a>
                            <a href="missions?type=<%= selectedType %>&category=<%= selectedCategory %>&difficulty=Hard" 
                               class="filter-pill <%= ("Hard".equalsIgnoreCase(selectedDifficulty) ? "active" : "") %>">
                               Hard
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Quest Deck Grid -->
                <% if (missionsList != null && !missionsList.isEmpty()) { %>
                    <div class="missions-deck">
                        <% for (Mission m : missionsList) { %>
                            <div class="quest-card <%= (m.isSolved() ? "solved-card" : "") %>" 
                                 data-category="<%= m.getCategory() %>" 
                                 data-difficulty="<%= m.getDifficulty() %>"
                                 data-type="<%= m.getType() %>">
                                
                                <div>
                                    <div class="quest-card-header">
                                        <div style="display: flex; gap: 0.45rem; align-items: center; flex-wrap: wrap;">
                                            <% if ("code".equalsIgnoreCase(m.getType())) { %>
                                                <span class="badge" style="background: var(--pop-blue); color: #fff; border: 2px solid #000; box-shadow: 2px 2px 0 #000; font-size: 0.7rem; font-weight: 800;">CODING ARENA</span>
                                            <% } else { %>
                                                <span class="badge" style="background: var(--pop-yellow); color: #000; border: 2px solid #000; box-shadow: 2px 2px 0 #000; font-size: 0.7rem; font-weight: 800;">CONCEPT CHECK</span>
                                            <% } %>

                                            <% if ("Java".equalsIgnoreCase(m.getCategory())) { %>
                                                <span class="quest-category-badge category-java">Java</span>
                                            <% } else if ("SQL".equalsIgnoreCase(m.getCategory())) { %>
                                                <span class="quest-category-badge category-sql">SQL</span>
                                            <% } else { %>
                                                <span class="quest-category-badge category-dsa">DSA</span>
                                            <% } %>

                                            <% if ("Easy".equalsIgnoreCase(m.getDifficulty())) { %>
                                                <span class="difficulty-tag diff-easy">Easy</span>
                                            <% } else if ("Medium".equalsIgnoreCase(m.getDifficulty())) { %>
                                                <span class="difficulty-tag diff-medium">Medium</span>
                                            <% } else { %>
                                                <span class="difficulty-tag diff-hard">Hard</span>
                                            <% } %>
                                        </div>

                                        <div style="display: flex; gap: 0.45rem; align-items: center;">
                                            <% if (m.isSolved()) { %>
                                                <span style="font-family: var(--font-code); font-size: 0.72rem; color: var(--neon-emerald); background: rgba(0,245,160,0.15); border: 1px solid var(--neon-emerald); padding: 0.2rem 0.5rem; border-radius: 4px; font-weight: 700;">
                                                    COMPLETED
                                                </span>
                                            <% } %>
                                        </div>
                                    </div>

                                    <h3 class="quest-title"><%= SecurityUtil.encodeHtml(m.getTitle()) %></h3>
                                    <p class="quest-desc"><%= SecurityUtil.encodeHtml(m.getDescription()) %></p>
                                </div>

                                <% if ("code".equalsIgnoreCase(m.getType())) { %>
                                    <!-- MODE A: CODING ARENA PANEL -->
                                    <form action="<%= request.getContextPath() %>/submit-answer" method="POST" id="form-code-<%= m.getId() %>">
                                        <input type="hidden" name="missionId" value="<%= m.getId() %>">
                                        <input type="hidden" name="type" value="code">
                                        <input type="hidden" name="allPassed" id="allPassed-<%= m.getId() %>" value="false">

                                        <div class="code-arena-panel">
                                            <div class="code-editor-header">
                                                <span>Language: <strong><%= SecurityUtil.encodeHtml((m.getLanguage() != null ? m.getLanguage() : "javascript").toUpperCase()) %></strong></span>
                                                <span>Function: <code><%= SecurityUtil.encodeHtml(m.getFunctionName() != null ? m.getFunctionName() : "solve") %>()</code></span>
                                            </div>
                                            <div class="code-editor-wrap">
                                                <textarea class="code-editor-textarea" name="submittedCode" id="editor-<%= m.getId() %>" spellcheck="false" <%= (m.isSolved() ? "readonly" : "") %>><%= SecurityUtil.encodeHtml(m.getStarterCode() != null ? m.getStarterCode() : "// Write solution here") %></textarea>
                                            </div>

                                            <div class="code-actions-bar">
                                                <button type="button" class="btn btn-outline btn-sm jsp-btn-run" data-id="<%= m.getId() %>" data-fn="<%= SecurityUtil.encodeHtml(m.getFunctionName() != null ? m.getFunctionName() : "solve") %>">Run Test Cases</button>
                                                <% if (m.isSolved()) { %>
                                                    <button type="button" class="btn btn-outline btn-sm" disabled style="opacity: 0.6; cursor: not-allowed;">Locked (Solved)</button>
                                                <% } else { %>
                                                    <button type="submit" class="btn btn-primary btn-sm" id="btn-submit-code-<%= m.getId() %>" disabled>Submit Solution</button>
                                                <% } %>
                                            </div>

                                            <!-- Test Cases Output Container -->
                                            <div class="test-results-container" id="results-<%= m.getId() %>" style="display: none; margin-top: 10px;">
                                                <div class="results-summary" id="summary-<%= m.getId() %>"></div>
                                                <div class="test-cases-list" id="cases-<%= m.getId() %>"></div>
                                            </div>

                                            <!-- Hidden element storing raw test cases JSON for client runner -->
                                            <script type="application/json" id="tc-data-<%= m.getId() %>">
                                                <%= (m.getTestCases() != null ? m.getTestCases() : "[]") %>
                                            </script>
                                        </div>

                                        <div class="quest-card-footer">
                                            <div class="quest-xp-badge">
                                                <span>+<%= m.getXpReward() %> XP Bounty</span>
                                            </div>
                                        </div>
                                    </form>

                                <% } else { %>
                                    <!-- MODE B: MCQ CONCEPT CHECK FORM -->
                                    <form action="<%= request.getContextPath() %>/submit-answer" method="POST">
                                        <input type="hidden" name="missionId" value="<%= m.getId() %>">
                                        <input type="hidden" name="type" value="mcq">

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
                                                <span>+<%= m.getXpReward() %> XP Bounty</span>
                                            </div>

                                            <% if (m.isSolved()) { %>
                                                <button type="button" class="btn btn-outline btn-sm" disabled style="opacity: 0.6; cursor: not-allowed;">
                                                    Locked (Attempted)
                                                </button>
                                            <% } else { %>
                                                <button type="submit" class="btn btn-outline btn-sm">
                                                    Submit Choice
                                                </button>
                                            <% } %>
                                        </div>
                                    </form>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">SEARCH</div>
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
    <script src="js/codequest-live.js"></script>
    <script src="js/game-fx.js"></script>
    <script>
        // Interactive code runner hook for JSP coding arena cards
        document.addEventListener('DOMContentLoaded', function() {
            var runButtons = document.querySelectorAll('.jsp-btn-run');
            runButtons.forEach(function(btn) {
                btn.addEventListener('click', function() {
                    var id = btn.getAttribute('data-id');
                    var fnName = btn.getAttribute('data-fn') || 'solve';
                    var editor = document.getElementById('editor-' + id);
                    var tcScript = document.getElementById('tc-data-' + id);
                    var resultsBox = document.getElementById('results-' + id);
                    var summaryBox = document.getElementById('summary-' + id);
                    var casesBox = document.getElementById('cases-' + id);
                    var submitBtn = document.getElementById('btn-submit-code-' + id);
                    var allPassedInput = document.getElementById('allPassed-' + id);

                    if (!editor || !tcScript || !resultsBox) return;

                    var userCode = editor.value;
                    var testCases = [];
                    try {
                        testCases = JSON.parse(tcScript.textContent);
                    } catch (e) {
                        testCases = [];
                    }

                    btn.disabled = true;
                    btn.textContent = 'Evaluating...';

                    CodeQuestEngine.runCodeSandboxed(userCode, fnName, testCases).then(function(res) {
                        btn.disabled = false;
                        btn.textContent = 'Run Test Cases';
                        resultsBox.style.display = 'block';

                        if (res.error) {
                            summaryBox.innerHTML = '<span style="color: var(--danger-crimson); font-weight: 800;">Execution Error: ' + CodeQuestEngine.escapeHTML(res.error) + '</span>';
                            casesBox.innerHTML = '';
                            if (submitBtn) submitBtn.disabled = true;
                            if (allPassedInput) allPassedInput.value = 'false';
                            return;
                        }

                        var total = res.results.length;
                        var passed = res.results.filter(function(r) { return r.passed; }).length;
                        var allPassed = (passed === total && total > 0);

                        summaryBox.innerHTML = '<span style="color: ' + (allPassed ? 'var(--neon-emerald)' : 'var(--danger-crimson)') + '; font-weight: 800;">' +
                            passed + ' / ' + total + ' Tests Passed</span>';

                        var html = '';
                        res.results.forEach(function(r, idx) {
                            html += '<div style="padding: 6px 10px; margin-top: 4px; border-radius: 4px; font-size: 0.8rem; font-family: var(--font-code); background: ' +
                                (r.passed ? 'rgba(0,245,160,0.1)' : 'rgba(255,51,102,0.1)') + '; border-left: 3px solid ' +
                                (r.passed ? 'var(--neon-emerald)' : 'var(--danger-crimson)') + ';">' +
                                'Test #' + (idx + 1) + ': ' + (r.passed ? 'PASSED' : 'FAILED') + ' (' + r.timeMs + 'ms) | Expected: ' +
                                CodeQuestEngine.escapeHTML(r.expected) + ' | Actual: ' + CodeQuestEngine.escapeHTML(r.actual) +
                                '</div>';
                        });
                        casesBox.innerHTML = html;

                        if (allPassedInput) allPassedInput.value = allPassed ? 'true' : 'false';
                        if (submitBtn) {
                            submitBtn.disabled = false;
                            if (allPassed) {
                                submitBtn.className = 'btn btn-primary btn-sm';
                                submitBtn.textContent = 'Submit Flawless Solution';
                            } else {
                                submitBtn.className = 'btn btn-outline btn-sm';
                                submitBtn.textContent = 'Submit Solution (Failed Cases)';
                            }
                        }
                    });
                });
            });
        });
    </script>
</body>
</html>
