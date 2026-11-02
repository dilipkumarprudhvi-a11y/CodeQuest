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
    <!-- Security Headers & HTTPS Enforcement -->
    <meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">
    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <meta name="referrer" content="strict-origin-when-cross-origin">
    <title>Administrator Clearance Gate - CodeQuest</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='https://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='20' fill='%23FF007F'/%3E%3Ctext x='50' y='65' font-family='sans-serif' font-size='45' font-weight='900' fill='%23FFFFFF' text-anchor='middle'%3EAD%3C/text%3E%3C/svg%3E">
</head>
<body>
    <canvas id="cyber-canvas"></canvas>

    <div class="hud-layout">
        <nav class="navbar" style="border-bottom-color: rgba(255, 59, 92, 0.4);">
            <a href="index.html" class="nav-brand">
                <div class="brand-icon" style="background: var(--neon-crimson); box-shadow: 0 0 15px rgba(255,59,92,0.4);">AD</div>
                <div class="brand-text">CodeQuest <span style="font-size: 0.8rem; color: var(--neon-crimson);">[COMMAND]</span></div>
            </a>
            <ul class="nav-links">
                <li><a href="index.html">Home</a></li>
                <li><a href="missions">Missions</a></li>
                <li><a href="leaderboard">Leaderboard</a></li>
                <li><a href="login.jsp">Student Portal</a></li>
                <li><a href="admin-login.jsp" class="active">Admin Console</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">AUDIO</button>
                <a href="index.html" class="btn btn-outline btn-sm">Exit to Public</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <div class="auth-wrapper">
                    <div class="card card-admin">
                        <div class="card-header">
                            <span class="section-tagline" style="color: var(--neon-crimson);">HIGH CLEARANCE RESTRICTED</span>
                            <h2 class="card-title" style="color: #000000;"><%= consoleTitle %></h2>
                            <p class="card-subtitle">Authorize administrative credentials to manage curriculum and system telemetry</p>
                        </div>

                        <% if ("true".equalsIgnoreCase(loggedOut)) { %>
                            <div class="alert alert-info">
                                <div>Administrative session terminated and security tokens revoked.</div>
                            </div>
                        <% } %>

                        <% if (paramError != null && !paramError.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <div><%= SecurityUtil.encodeHtml(paramError) %></div>
                            </div>
                        <% } %>

                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <div><%= SecurityUtil.encodeHtml(errorMessage) %></div>
                            </div>
                        <% } %>

                        <form action="<%= request.getContextPath() %>/admin-login" method="POST">
                            <div class="form-group">
                                <label class="form-label" for="username">Administrator ID or Email</label>
                                <input type="text" id="username" name="username" class="form-control" 
                                       placeholder="Admin Codename or Email (Default: admin)" 
                                       value="<%= SecurityUtil.encodeHtml(formUsername) %>" required autofocus autocomplete="username">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="password">Master Security Key</label>
                                <input type="password" id="password" name="password" class="form-control" 
                                       placeholder="Default: admin123" required autocomplete="current-password">
                            </div>

                            <button type="submit" class="btn btn-admin" style="width: 100%; margin-top: 0.75rem;">
                                Authenticate Administrator
                            </button>
                        </form>

                        <div style="margin-top: 1.75rem; padding-top: 1.25rem; border-top: 1px solid var(--border-subtle); font-family: var(--font-code); font-size: 0.75rem; color: var(--text-muted); text-align: center;">
                            <div>ServletContext Runtime: <span style="color: var(--pop-blue); font-weight: 700;"><%= appVersion %></span></div>
                            <div style="margin-top: 0.25rem;">Total Admin Sessions Recorded: <span style="color: var(--neon-emerald); font-weight: 700;"><%= adminLogins %></span></div>
                            <div style="margin-top: 0.5rem; color: #000000; font-weight: 700;">Default credentials: admin / admin123</div>
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
