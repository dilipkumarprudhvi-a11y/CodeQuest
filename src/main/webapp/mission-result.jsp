<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.model.Mission" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - Check student session
    Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Authentication+required");
        return;
    }

    Boolean isDuplicate = (Boolean) request.getAttribute("isDuplicate");
    Boolean isCorrect = (Boolean) request.getAttribute("isCorrect");
    Integer xpAwardedObj = (Integer) request.getAttribute("xpAwarded");
    Integer newTotalXpObj = (Integer) request.getAttribute("newTotalXp");
    Integer oldLevelObj = (Integer) request.getAttribute("oldLevel");
    Integer newLevelObj = (Integer) request.getAttribute("newLevel");
    Boolean leveledUpObj = (Boolean) request.getAttribute("leveledUp");
    String selectedOption = (String) request.getAttribute("selectedOption");
    String judgeEngine = (String) request.getAttribute("judgeEngine");
    String errorMessage = (String) request.getAttribute("errorMessage");
    Mission mission = (Mission) request.getAttribute("mission");

    boolean duplicate = (isDuplicate != null && isDuplicate);
    boolean correct = (isCorrect != null && isCorrect);
    int xpAwarded = (xpAwardedObj != null) ? xpAwardedObj : 0;
    int newTotalXp = (newTotalXpObj != null) ? newTotalXpObj : 0;
    int oldLevel = (oldLevelObj != null) ? oldLevelObj : 1;
    int newLevel = (newLevelObj != null) ? newLevelObj : 1;
    boolean leveledUp = (leveledUpObj != null && leveledUpObj);
    if (judgeEngine == null) judgeEngine = "CodeQuest Judge Engine";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mission Evaluation - CodeQuest</title>
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
                <li><a href="dashboard"><span>📊</span> Cockpit</a></li>
                <li><a href="missions"><span>⚔️</span> Missions</a></li>
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <div class="nav-profile-pill">
                    <span class="nav-level-tag">LVL <%= newLevel %></span>
                    <span style="color: var(--text-pure); font-weight: 600;"><%= SecurityUtil.encodeHtml(username) %></span>
                    <span class="nav-xp-counter"><%= newTotalXp %> XP</span>
                </div>
                <a href="logout" class="btn btn-outline btn-sm">Sign Out</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <% if (duplicate) { %>
                    <!-- Duplicate Submission Screen -->
                    <div class="result-card failure-card">
                        <div class="result-icon-orb">🔒</div>
                        <h2 class="result-headline" style="color: var(--danger-crimson);">One-Attempt Rule Enforced</h2>
                        <p class="result-lead">
                            <%= (errorMessage != null ? SecurityUtil.encodeHtml(errorMessage) : "You have already submitted an answer for this mission.") %>
                        </p>
                        <div style="margin-bottom: 2rem; font-family: var(--font-code); color: var(--text-secondary);">
                            Prior choice logged. Duplicate submissions are rejected to maintain leaderboard integrity.
                        </div>
                        <div style="display: flex; justify-content: center; gap: 1rem;">
                            <a href="missions" class="btn btn-primary">Return to Mission Deck</a>
                            <a href="dashboard" class="btn btn-outline">Go to Cockpit</a>
                        </div>
                    </div>

                <% } else if (correct) { %>
                    <!-- Victory & XP Reward Screen -->
                    <div class="result-card success-card">
                        <div class="result-icon-orb">⚡</div>
                        <h2 class="result-headline" style="color: var(--neon-emerald);">Protocol Solved: Victory!</h2>
                        <p class="result-lead">
                            Your selected answer <strong style="color: var(--cyber-cyan);">[Option <%= SecurityUtil.encodeHtml(selectedOption) %>]</strong> was evaluated as 
                            flawless by <%= SecurityUtil.encodeHtml(judgeEngine) %>.
                        </p>

                        <% if (leveledUp) { %>
                            <div class="level-up-banner">
                                🎖️ TIER PROMOTION: ADVANCED FROM LEVEL <%= oldLevel %> TO LEVEL <%= newLevel %>!
                            </div>
                        <% } %>

                        <div class="xp-awarded-pill">
                            <span>⚡</span>
                            <span>+<%= xpAwarded %> XP AWARDED</span>
                        </div>

                        <div style="margin-bottom: 2.5rem; font-family: var(--font-code); color: var(--text-secondary);">
                            New Total XP: <span style="color: var(--solar-gold); font-weight: 700;"><%= newTotalXp %> XP</span> 
                            &nbsp;|&nbsp; Current Rank Tier: <span style="color: var(--neon-emerald); font-weight: 700;">Level <%= newLevel %></span>
                        </div>

                        <div style="display: flex; justify-content: center; gap: 1.25rem; flex-wrap: wrap;">
                            <a href="missions" class="btn btn-primary btn-lg">Next Mission ⚔️</a>
                            <a href="dashboard" class="btn btn-outline-cyan btn-lg">View Cockpit 📊</a>
                            <a href="leaderboard" class="btn btn-outline btn-lg">Check Rankings 🏆</a>
                        </div>
                    </div>

                    <script>
                        // Sensory audio feedback
                        window.addEventListener('DOMContentLoaded', function() {
                            setTimeout(function() {
                                if (window.GameAudio) {
                                    <% if (leveledUp) { %>
                                        window.GameAudio.playLevelUp();
                                    <% } else { %>
                                        window.GameAudio.playSuccess();
                                    <% } %>
                                }
                            }, 200);
                        });
                    </script>

                <% } else { %>
                    <!-- Defeat Screen (Zero XP awarded, Feedback provided) -->
                    <div class="result-card failure-card">
                        <div class="result-icon-orb">💀</div>
                        <h2 class="result-headline" style="color: var(--danger-crimson);">Compilation Defeat</h2>
                        <p class="result-lead">
                            Your submitted choice <strong style="color: var(--text-pure);">[Option <%= SecurityUtil.encodeHtml(selectedOption) %>]</strong> did not satisfy 
                            the algorithmic invariants.
                        </p>

                        <div style="background: rgba(255, 51, 102, 0.08); border: 1px solid rgba(255, 51, 102, 0.25); border-radius: 10px; padding: 1.25rem; margin-bottom: 2rem; text-align: left;">
                            <h4 style="color: var(--danger-crimson); font-family: var(--font-heading); margin-bottom: 0.35rem;">
                                Technical Debrief:
                            </h4>
                            <p style="font-size: 0.9rem; color: var(--text-secondary); line-height: 1.5;">
                                Zero XP was awarded for this attempt. Per project rules, your attempt has been recorded. Review core language concepts, analyze memory diagrams, and conquer the remaining missions!
                            </p>
                        </div>

                        <div style="display: flex; justify-content: center; gap: 1.25rem; flex-wrap: wrap;">
                            <a href="missions" class="btn btn-primary btn-lg">Resume Quests ⚔️</a>
                            <a href="dashboard" class="btn btn-outline btn-lg">Return to Cockpit</a>
                        </div>
                    </div>

                    <script>
                        window.addEventListener('DOMContentLoaded', function() {
                            setTimeout(function() {
                                if (window.GameAudio) {
                                    window.GameAudio.playError();
                                }
                            }, 200);
                        });
                    </script>
                <% } %>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 10: Answer Evaluation & XP Rewards.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

