<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - No JSTL / No EL
    String errorMessage = (String) request.getAttribute("errorMessage");
    String formUsername = (String) request.getAttribute("formUsername");
    String consoleTitle = (String) request.getAttribute("consoleTitle");
    if (formUsername == null) formUsername = "";
    if (consoleTitle == null) consoleTitle = "Administrative Command Center";

    String loggedOut = request.getParameter("loggedOut");
    String paramError = request.getParameter("error");

    // Retrieve system telemetry stored in ServletContext
    String appVersion = (String) application.getAttribute("appVersion");
    Integer adminLogins = (Integer) application.getAttribute("adminLoginsCount");
    if (appVersion == null) appVersion = "CodeQuest v2.4 (Enterprise Engine)";
    if (adminLogins == null) adminLogins = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Clearance Gate - CodeQuest</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <nav class="navbar">
            <a href="index.html" class="nav-brand">
                <div class="brand-icon" style="background: linear-gradient(135deg, #ff3366, #ff758c);">AD</div>
                <div class="brand-text">CodeQuest <span style="font-size: 0.8rem; color: #ff3366;">[COMMAND]</span></div>
            </a>
            <ul class="nav-links">
                <li><a href="index.html"><span>🏠</span> Home</a></li>
                <li><a href="missions"><span>⚔️</span> Missions</a></li>
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
                <li><a href="login.jsp"><span>🔑</span> Student Portal</a></li>
                <li><a href="admin-login.jsp" class="active"><span>🛡️</span> Admin Console</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <a href="index.html" class="btn btn-outline btn-sm">Exit to Public</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <div class="auth-wrapper">
                    <div class="card card-admin">
                        <div class="card-header">
                            <span class="section-tagline" style="color: #ff3366;">HIGH CLEARANCE RESTRICTED</span>
                            <h2 class="card-title" style="color: #ffffff;"><%= consoleTitle %></h2>
                            <p class="card-subtitle">Authorize administrative credentials to manage curriculum and system telemetry</p>
                        </div>

                        <% if ("true".equalsIgnoreCase(loggedOut)) { %>
                            <div class="alert alert-info">
                                <span>🔒</span>
                                <div>Administrative session terminated and security tokens revoked.</div>
                            </div>
                        <% } %>

                        <% if (paramError != null && !paramError.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <span>⚠️</span>
                                <div><%= SecurityUtil.encodeHtml(paramError) %></div>
                            </div>
                        <% } %>

                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <span>⚠️</span>
                                <div><%= SecurityUtil.encodeHtml(errorMessage) %></div>
                            </div>
                        <% } %>

                        <form action="admin-login" method="POST">
                            <div class="form-group">
                                <label class="form-label" for="username">Administrator ID</label>
                                <input type="text" id="username" name="username" class="form-control" 
                                       placeholder="Admin Codename (Default: admin)" 
                                       value="<%= SecurityUtil.encodeHtml(formUsername) %>" required autofocus>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="password">Master Security Key</label>
                                <input type="password" id="password" name="password" class="form-control" 
                                       placeholder="Default: admin123" required>
                            </div>

                            <button type="submit" class="btn btn-admin" style="width: 100%; margin-top: 0.75rem;">
                                🛡️ Authenticate Administrator
                            </button>
                        </form>

                        <div style="margin-top: 1.75rem; padding-top: 1.25rem; border-top: 1px solid var(--border-subtle); font-family: var(--font-code); font-size: 0.75rem; color: var(--text-muted); text-align: center;">
                            <div>ServletContext Runtime: <span style="color: var(--cyber-cyan);"><%= appVersion %></span></div>
                            <div style="margin-top: 0.25rem;">Total Admin Sessions Recorded: <span style="color: var(--solar-gold);"><%= adminLogins %></span></div>
                            <div style="margin-top: 0.5rem; color: var(--neon-emerald);">Default credentials: admin / admin123</div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 4: Administrator Authentication.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

