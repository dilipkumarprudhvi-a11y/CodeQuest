<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.Cookie" %>
<%@ page import="com.codequest.util.SecurityUtil" %>
<%
    // Strictly scriptlets - No JSTL / No EL
    String errorMessage = (String) request.getAttribute("errorMessage");
    String formIdentifier = (String) request.getAttribute("formIdentifier");
    if (formIdentifier == null) formIdentifier = "";

    // Query parameters
    String registered = request.getParameter("registered");
    String registeredUser = request.getParameter("user");
    String loggedOut = request.getParameter("loggedOut");
    String sessionExpired = request.getParameter("error");

    // Cookie demonstration: Read remembered user cookie
    String rememberedUser = "";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("codequest_remembered_user".equals(c.getName())) {
                rememberedUser = c.getValue();
                break;
            }
        }
    }
    if (formIdentifier.isEmpty() && !rememberedUser.isEmpty()) {
        formIdentifier = rememberedUser;
    }
    if (registeredUser != null && !registeredUser.isEmpty()) {
        formIdentifier = registeredUser;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Terminal Access - CodeQuest</title>
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
                <li><a href="leaderboard"><span>🏆</span> Leaderboard</a></li>
                <li><a href="login.jsp" class="active"><span>🔑</span> Student Login</a></li>
                <li><a href="admin-login.jsp"><span>🛡️</span> Admin</a></li>
            </ul>
            <div class="nav-actions">
                <button id="sound-toggle-btn" class="sound-toggle" title="Toggle Sound FX">🔊</button>
                <a href="register.jsp" class="btn btn-primary btn-sm">Enlist</a>
            </div>
        </nav>

        <main class="content-wrapper">
            <div class="container">
                <div class="auth-wrapper">
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">Student Portal</h2>
                            <p class="card-subtitle">Authenticate credentials to resume your programming quest</p>
                        </div>

                        <%-- Dynamic Notification Banners via Scriptlets --%>
                        <% if ("true".equalsIgnoreCase(registered)) { %>
                            <div class="alert alert-success">
                                <span>🎉</span>
                                <div>Warrior profile forged! Please authenticate below to deploy.</div>
                            </div>
                        <% } %>

                        <% if ("true".equalsIgnoreCase(loggedOut)) { %>
                            <div class="alert alert-info">
                                <span>🔒</span>
                                <div>Session terminated safely. Your quest state is persisted.</div>
                            </div>
                        <% } %>

                        <% if (sessionExpired != null && !sessionExpired.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <span>⚠️</span>
                                <div><%= SecurityUtil.encodeHtml(sessionExpired) %></div>
                            </div>
                        <% } %>

                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                            <div class="alert alert-danger">
                                <span>⚠️</span>
                                <div><%= SecurityUtil.encodeHtml(errorMessage) %></div>
                            </div>
                        <% } %>

                        <form action="login" method="POST">
                            <div class="form-group">
                                <label class="form-label" for="identifier">Warrior Codename or Comm-Link (Username / Email)</label>
                                <input type="text" id="identifier" name="identifier" class="form-control" 
                                       placeholder="Username or Email" 
                                       value="<%= SecurityUtil.encodeHtml(formIdentifier) %>" required autofocus>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="password">Access Cipher (Password)</label>
                                <input type="password" id="password" name="password" class="form-control" 
                                       placeholder="Enter your password" required>
                            </div>

                            <div class="form-group">
                                <label class="form-check">
                                    <input type="checkbox" name="rememberMe" value="true" <%= (!rememberedUser.isEmpty() ? "checked" : "") %>>
                                    <span>Remember warrior codename via secure cookie</span>
                                </label>
                            </div>

                            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 0.5rem;">
                                🚀 Access Dashboard & Missions
                            </button>
                        </form>

                        <div class="card-footer-links">
                            Need a warrior identity? <a href="register.jsp">Enlist as new student</a>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <footer class="footer">
            <p>&copy; 2026 CodeQuest Learning Game. Module 3: Student Login & Authentication.</p>
        </footer>
    </div>

    <script src="js/audio-synth.js"></script>
    <script src="js/game-fx.js"></script>
</body>
</html>

