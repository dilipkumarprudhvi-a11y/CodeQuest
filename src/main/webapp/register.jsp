<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - No JSTL / No EL
    String errorMessage = (String) request.getAttribute("errorMessage");
    String formUsername = (String) request.getAttribute("formUsername");
    String formEmail = (String) request.getAttribute("formEmail");
    if (formUsername == null) formUsername = "";
    if (formEmail == null) formEmail = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Enlist as Code Warrior - CodeQuest</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <!-- Navigation Bar -->
        <nav class="navbar">
            <a href="index.html" class="nav-brand">
                <div class="brand-icon">CQ</div>
                <div class="brand-text">CodeQuest</div>
            </a>
            <ul class="nav-links">
                <li><a href="index.html"><span>🏠</span> Home</a></li>
                <li><a href="missions"><span>⚔️</span> Missions</a></li>
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
                <li><a href="login.jsp"><span>🔑</span> Student Login</a></li>
                <li><a href="admin-login.jsp"><span>🛡️</span> Admin</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <a href="login.jsp" class="btn btn-outline-cyan btn-sm">Sign In</a>
            </div>
        </nav>

        <!-- Main Registration Form -->
        <main class="content-wrapper">
            <div class="container">
                <div class="auth-wrapper">
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">Enlist Warrior</h2>
                            <p class="card-subtitle">Forge your learner profile to start earning XP and climbing the ranks</p>
                        </div>

                        <%-- Display Validation or Error Message Dynamically using Scriptlet --%>
                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <span>⚠️</span>
                                <div><%= SecurityUtil.encodeHtml(errorMessage) %></div>
                            </div>
                        <% } %>

                        <form action="register" method="POST" autocomplete="off">
                            <div class="form-group">
                                <label class="form-label" for="username">Warrior Codename (Username)</label>
                                <input type="text" id="username" name="username" class="form-control" 
                                       placeholder="e.g. CyberNinja, ByteMaster" 
                                       value="<%= SecurityUtil.encodeHtml(formUsername) %>" required autofocus minlength="3" maxlength="30">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="email">Student Comm-Link (Email)</label>
                                <input type="email" id="email" name="email" class="form-control" 
                                       placeholder="cadet@codequest.dev" 
                                       value="<%= SecurityUtil.encodeHtml(formEmail) %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="password">Access Cipher (Password)</label>
                                <input type="password" id="password" name="password" class="form-control" 
                                       placeholder="Minimum 6 characters" required minlength="6">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="confirmPassword">Verify Access Cipher</label>
                                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                                       placeholder="Re-type your password" required minlength="6">
                            </div>

                            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">
                                ⚡ Initialize Account & Enter Arena
                            </button>
                        </form>

                        <div class="card-footer-links">
                            Already enlisted? <a href="login.jsp">Access Student Portal</a>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 2: Student Registration.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

