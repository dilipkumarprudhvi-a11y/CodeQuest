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
    String formType = (String) request.getAttribute("formType");
    String formFunctionName = (String) request.getAttribute("formFunctionName");
    String formLanguage = (String) request.getAttribute("formLanguage");
    String formStarterCode = (String) request.getAttribute("formStarterCode");
    String formTestCases = (String) request.getAttribute("formTestCases");
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
    if (formType == null) formType = "mcq";
    if (formFunctionName == null) formFunctionName = "solve";
    if (formLanguage == null) formLanguage = "javascript";
    if (formStarterCode == null) formStarterCode = "function solve(nums, target) {\n    // Implement solution\n    return [];\n}";
    if (formTestCases == null) formTestCases = "[\n  {\"input\": [[2,7,11,15], 9], \"expected\": [0,1]},\n  {\"input\": [[3,2,4], 6], \"expected\": [1,2]}\n]";
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
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='https://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='20' fill='%23000000'/%3E%3Ctext x='50' y='65' font-family='sans-serif' font-size='50' font-weight='900' fill='%23FFFF00' text-anchor='middle'%3ECQ%3C/text%3E%3C/svg%3E">
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
                <li><a href="admin-dashboard.jsp">Cockpit</a></li>
                <li><a href="add-question.jsp" class="active">Add Mission</a></li>
                <li><a href="view-questions">Question Vault</a></li>
                <li><a href="leaderboard">Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">AUDIO</button>
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
                            <p class="card-subtitle">Author an algorithmic combat challenge or rapid concept check and configure bounties</p>
                        </div>

                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <div><%= SecurityUtil.encodeHtml(errorMessage) %></div>
                            </div>
                        <% } %>

                        <form action="<%= request.getContextPath() %>/add-question" method="POST" id="mission-form">
                            <div class="form-grid-2">
                                <div class="form-group">
                                    <label class="form-label" for="type">Mission Format</label>
                                    <select id="type" name="type" class="form-select" onchange="toggleMissionFormat(this.value)" required>
                                        <option value="mcq" <%= ("mcq".equals(formType) ? "selected" : "") %>>Concept Check (Multiple Choice Question)</option>
                                        <option value="code" <%= ("code".equals(formType) ? "selected" : "") %>>Interactive Coding Arena (Code Editor + Tests)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="title">Mission Title / Codename</label>
                                    <input type="text" id="title" name="title" class="form-control" 
                                           placeholder="e.g. Relational Index B-Tree Balancing" 
                                           value="<%= SecurityUtil.encodeHtml(formTitle) %>" required autofocus>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="description">Problem Statement / Technical Prompt</label>
                                <textarea id="description" name="description" class="form-control" rows="3"
                                          placeholder="Detail the technical dilemma or algorithmic challenge that the cadet must solve..." 
                                          required><%= SecurityUtil.encodeHtml(formDesc) %></textarea>
                            </div>

                            <div class="form-grid-3">
                                <div class="form-group">
                                    <label class="form-label" for="category">Technology Category</label>
                                    <select id="category" name="category" class="form-select" required>
                                        <option value="Java" <%= ("Java".equals(formCategory) ? "selected" : "") %>>Java Fundamentals & JVM</option>
                                        <option value="SQL" <%= ("SQL".equals(formCategory) ? "selected" : "") %>>SQL & Relational Databases</option>
                                        <option value="DSA" <%= ("DSA".equals(formCategory) ? "selected" : "") %>>Data Structures & Algorithms</option>
                                        <option value="Algorithms" <%= ("Algorithms".equals(formCategory) ? "selected" : "") %>>Algorithmic Puzzles</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="difficulty">Difficulty Tier</label>
                                    <select id="difficulty" name="difficulty" class="form-select" required>
                                        <option value="Easy" <%= ("Easy".equals(formDifficulty) ? "selected" : "") %>>Easy (Novice)</option>
                                        <option value="Medium" <%= ("Medium".equals(formDifficulty) ? "selected" : "") %>>Medium (Warrior)</option>
                                        <option value="Hard" <%= ("Hard".equals(formDifficulty) ? "selected" : "") %>>Hard (Grandmaster)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="xpReward">XP Bounty</label>
                                    <input type="number" id="xpReward" name="xpReward" class="form-control" 
                                           min="10" max="500" step="5" value="<%= formXp %>" required>
                                </div>
                            </div>

                            <!-- CODING ARENA SECTION -->
                            <div id="coding-arena-section" style="display: <%= "code".equals(formType) ? "block" : "none" %>; margin-top: 1rem; border-top: 1px solid var(--border-subtle); padding-top: 1rem;">
                                <h3 style="font-family: var(--font-heading); font-size: 1.15rem; color: var(--neon-cyan); margin-bottom: 0.5rem;">
                                    Coding Arena Configurations
                                </h3>
                                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1rem;">
                                    Define the function signature, language environment, starter template, and automated evaluation test cases.
                                </p>

                                <div class="form-grid-2">
                                    <div class="form-group">
                                        <label class="form-label" for="functionName">Entrypoint Function Name</label>
                                        <input type="text" id="functionName" name="functionName" class="form-control" 
                                               placeholder="e.g. solve, twoSum, isValidBST" 
                                               value="<%= SecurityUtil.encodeHtml(formFunctionName) %>">
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label" for="language">Execution Language</label>
                                        <select id="language" name="language" class="form-select">
                                            <option value="javascript" <%= ("javascript".equalsIgnoreCase(formLanguage) ? "selected" : "") %>>JavaScript (Sandboxed Web Worker)</option>
                                            <option value="python" <%= ("python".equalsIgnoreCase(formLanguage) ? "selected" : "") %>>Python 3</option>
                                            <option value="java" <%= ("java".equalsIgnoreCase(formLanguage) ? "selected" : "") %>>Java 17</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="starterCode">Starter Code Template</label>
                                    <textarea id="starterCode" name="starterCode" class="form-control" rows="5"
                                              style="font-family: var(--font-code); font-size: 0.85rem;"><%= SecurityUtil.encodeHtml(formStarterCode) %></textarea>
                                </div>

                                <div class="form-group">
                                    <label class="form-label" for="testCases">Evaluation Test Cases (JSON Array)</label>
                                    <textarea id="testCases" name="testCases" class="form-control" rows="5"
                                              style="font-family: var(--font-code); font-size: 0.85rem;"><%= SecurityUtil.encodeHtml(formTestCases) %></textarea>
                                    <span style="font-size: 0.75rem; color: var(--text-muted);">
                                        Format: <code>[{"input": [args], "expected": expectedResult}]</code>
                                    </span>
                                </div>
                            </div>

                            <!-- MCQ CONCEPT CHECK SECTION -->
                            <div id="mcq-section" style="display: <%= "code".equals(formType) ? "none" : "block" %>; margin-top: 1rem; border-top: 1px solid var(--border-subtle); padding-top: 1rem;">
                                <h3 style="font-family: var(--font-heading); font-size: 1.15rem; color: var(--text-pure); margin-bottom: 0.5rem;">
                                    Answer Option Matrices
                                </h3>
                                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1rem;">
                                    Provide 4 plausible choices and designate the single verified solution.
                                </p>

                                <div class="form-grid-2">
                                    <div class="form-group">
                                        <label class="form-label" for="optionA">Option A</label>
                                        <input type="text" id="optionA" name="optionA" class="form-control" 
                                               placeholder="Choice A text" value="<%= SecurityUtil.encodeHtml(formOptA) %>">
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label" for="optionB">Option B</label>
                                        <input type="text" id="optionB" name="optionB" class="form-control" 
                                               placeholder="Choice B text" value="<%= SecurityUtil.encodeHtml(formOptB) %>">
                                    </div>
                                </div>

                                <div class="form-grid-2">
                                    <div class="form-group">
                                        <label class="form-label" for="optionC">Option C</label>
                                        <input type="text" id="optionC" name="optionC" class="form-control" 
                                               placeholder="Choice C text" value="<%= SecurityUtil.encodeHtml(formOptC) %>">
                                    </div>

                                    <div class="form-group">
                                        <label class="form-label" for="optionD">Option D</label>
                                        <input type="text" id="optionD" name="optionD" class="form-control" 
                                               placeholder="Choice D text" value="<%= SecurityUtil.encodeHtml(formOptD) %>">
                                    </div>
                                </div>

                                <div class="form-group" style="max-width: 300px; margin-top: 0.5rem;">
                                    <label class="form-label" for="correctOption">Designated Correct Answer Choice</label>
                                    <select id="correctOption" name="correctOption" class="form-select">
                                        <option value="A" <%= ("A".equals(formCorrect) ? "selected" : "") %>>Option A is Correct</option>
                                        <option value="B" <%= ("B".equals(formCorrect) ? "selected" : "") %>>Option B is Correct</option>
                                        <option value="C" <%= ("C".equals(formCorrect) ? "selected" : "") %>>Option C is Correct</option>
                                        <option value="D" <%= ("D".equals(formCorrect) ? "selected" : "") %>>Option D is Correct</option>
                                    </select>
                                </div>
                            </div>

                            <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                                <button type="submit" class="btn btn-admin btn-lg">
                                    Persist Mission to Database
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
    <script>
        function toggleMissionFormat(format) {
            var codeSec = document.getElementById('coding-arena-section');
            var mcqSec = document.getElementById('mcq-section');
            var isCode = (format === 'code');

            if (codeSec) codeSec.style.display = isCode ? 'block' : 'none';
            if (mcqSec) mcqSec.style.display = isCode ? 'none' : 'block';

            // Set required attributes conditionally
            var fn = document.getElementById('functionName');
            var st = document.getElementById('starterCode');
            var tc = document.getElementById('testCases');
            var opA = document.getElementById('optionA');
            var opB = document.getElementById('optionB');
            var opC = document.getElementById('optionC');
            var opD = document.getElementById('optionD');

            if (fn) fn.required = isCode;
            if (st) st.required = isCode;
            if (tc) tc.required = isCode;

            if (opA) opA.required = !isCode;
            if (opB) opB.required = !isCode;
            if (opC) opC.required = !isCode;
            if (opD) opD.required = !isCode;
        }

        // Initialize state on page load
        document.addEventListener('DOMContentLoaded', function() {
            var typeSelect = document.getElementById('type');
            if (typeSelect) toggleMissionFormat(typeSelect.value);
        });
    </script>
</body>
</html>
