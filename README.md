# ⚡ CodeQuest — Web-Based Programming Learning Game

[![Live HUD Preview](https://img.shields.io/badge/Live_HUD_Preview-GitHub_Pages-00f5a0?style=for-the-badge&logo=github)](https://dilipkumarprudhvi-a11y.github.io/CodeQuest/)
[![Local Development Server](https://img.shields.io/badge/Local_Tomcat_URL-http%3A%2F%2Flocalhost%3A8080%2FCodeQuest-00d9f5?style=for-the-badge&logo=apache-tomcat)](http://localhost:8080/CodeQuest/)
[![Jakarta EE 10](https://img.shields.io/badge/Jakarta_EE-10_Servlet_6.0-ffb800?style=for-the-badge&logo=java)](https://jakarta.ee/)
[![Apache Tomcat 10.1](https://img.shields.io/badge/Apache_Tomcat-10.1-ff4444?style=for-the-badge&logo=apache-tomcat)](https://tomcat.apache.org/)

> **Academic Submission Grade**: Enterprise Dynamic Web Project  
> **Repository**: [https://github.com/dilipkumarprudhvi-a11y/CodeQuest](https://github.com/dilipkumarprudhvi-a11y/CodeQuest)  
> **Technologies**: Jakarta EE 10 / Servlets, JSP (Scriptlets strictly, zero JSTL/EL), JDBC, MySQL, HTML5, CSS3, Web Audio API  
> **Container**: Apache Tomcat 10.1 | **JDK**: Java 17 | **IDE**: Eclipse Enterprise IDE

---

## 🌐 Live Deployment & Development Links

| Environment | Purpose | Direct URL |
| :--- | :--- | :--- |
| **Online Live HUD** | Interactive Web Preview (Particle Mesh & Web Audio Synth) | 🔗 [https://dilipkumarprudhvi-a11y.github.io/CodeQuest/](https://dilipkumarprudhvi-a11y.github.io/CodeQuest/) |
| **Local Game Arena** | Full Dynamic Enterprise Runtime (Tomcat 10.1 + MySQL) | 🔗 [http://localhost:8080/CodeQuest/](http://localhost:8080/CodeQuest/) |
| **Student Login** | Authenticate student warrior with session security | 🔗 [http://localhost:8080/CodeQuest/login.jsp](http://localhost:8080/CodeQuest/login.jsp) |
| **Student Registration** | Create new cadet account with 0 XP & Level 1 default | 🔗 [http://localhost:8080/CodeQuest/register.jsp](http://localhost:8080/CodeQuest/register.jsp) |
| **Missions Deck** | Java, SQL & DSA challenges with ACID evaluation | 🔗 [http://localhost:8080/CodeQuest/missions](http://localhost:8080/CodeQuest/missions) |
| **Student Dashboard** | Real-time XP progress bar, rank title & mission log | 🔗 [http://localhost:8080/CodeQuest/dashboard](http://localhost:8080/CodeQuest/dashboard) |
| **Global Leaderboard** | Real-time rankings & 3D Olympic Podium (Gold/Silver/Bronze) | 🔗 [http://localhost:8080/CodeQuest/leaderboard](http://localhost:8080/CodeQuest/leaderboard) |
| **Admin Console** | Question vault, difficulty & XP bounty manager | 🔗 [http://localhost:8080/CodeQuest/admin-login.jsp](http://localhost:8080/CodeQuest/admin-login.jsp) |

---

## 🎮 Project Overview & Modules Implemented

CodeQuest is a high-octane gamified programming platform designed to transform traditional question drills into an engaging combat arena. Students solve Java, SQL, and Data Structure problems, harvest Experience Points (XP), level up their combat rank, and battle for the Top 3 global podium.

### Specification Compliance Grid (Modules 1 – 12)

| Module | Requirement | Key Files | Implementation Status |
|---|---|---|---|
| **Module 1** | Home Page & Gaming HUD | `index.html`, `css/style.css`, `js/game-fx.js` | ✅ **Complete**: Cyber-obsidian canvas mesh, live ticker, navigation links, Web Audio sound toggle. |
| **Module 2** | Student Registration | `register.jsp`, `RegisterServlet.java` | ✅ **Complete**: Unique username/email validation, starts at 0 XP & Level 1, inline badge feedback. |
| **Module 3** | Student Login & Session | `login.jsp`, `LoginServlet.java`, `LogoutServlet.java` | ✅ **Complete**: Dual-mode login (username/email), session guard, `codequest_remembered_user` cookie. |
| **Module 4** | Admin Login & Console | `admin-login.jsp`, `AdminLoginServlet.java`, `admin-dashboard.jsp` | ✅ **Complete**: Role isolation (`SYSTEM_ADMIN`), `ServletConfig` & `ServletContext` runtime telemetry. |
| **Module 5** | Database & JDBC Design | `codequest_db.sql`, `DBConnection.java` | ✅ **Complete**: Reusable singleton, parameterized `PreparedStatement`, foreign keys & unique constraints. |
| **Module 6** | Admin Question Creation | `add-question.jsp`, `AddQuestionServlet.java` | ✅ **Complete**: Dynamic multi-choice creation for Java, SQL, DSA with difficulty and custom XP bounties. |
| **Module 7** | Question Vault Management | `view-questions.jsp`, `ViewQuestionsServlet.java` | ✅ **Complete**: Full tabular inventory with category badges, difficulty tags, deletion action. |
| **Module 8** | Student Cockpit & Progress | `dashboard.jsp`, `DashboardServlet.java` | ✅ **Complete**: Real-time XP, level rank titles, dynamic animated striped progress bar towards next level. |
| **Module 9** | Programming Missions Deck | `missions.jsp`, `MissionServlet.java` | ✅ **Complete**: Dynamic domain/difficulty filters; **strictly omits correct answer from student view**; flags completed quests. |
| **Module 10** | Evaluation & XP Engine | `mission-result.jsp`, `SubmitAnswerServlet.java` | ✅ **Complete**: **Atomic JDBC transaction (`setAutoCommit(false)`)**; **one-attempt rule enforcement**; dynamic level-up triggers. |
| **Module 11** | Global Leaderboard & Podium | `leaderboard.jsp`, `LeaderboardServlet.java` | ✅ **Complete**: Real-time XP descending rank, Olympic 3D podium for Top 3 (Gold crown, Silver, Bronze), handles zero-player state. |
| **Module 12** | Integration & Security | Full Application Stack | ✅ **Complete**: All navigation linked, session invalidation, cookies, RequestDispatcher vs Redirects, zero generic error pages. |

---

## 🎨 Bespoke Senior-Designer Interface Features

- **No AI Clichés**: Avoids washed-out purple/indigo AI gradients. Uses high-contrast Cyber Obsidian (`#070a10`), elevated slate surfaces (`#151e33`), electric emerald (`#00f5a0`), cyber cyan (`#00d9f5`), and solar gold (`#ffb800`).
- **Web Audio API Synth Engine (`js/audio-synth.js`)**: Real-time procedural audio for button hovers, radio select blips, victory fanfares, and defeat buzzes. Includes persistent mute cookie. Zero external MP3/WAV dependencies!
- **Interactive Canvas Mesh (`js/game-fx.js`)**: Dynamic constellation particle grid responding smoothly to layout dimensions.
- **Strict Constraint Adherence**: **100% pure JSP scriptlets (`<% ... %>`, `<%= ... %>`)** — absolutely zero JSTL tags or JSP Expression Language `${...}`.
- **OWASP Hardened**: HTML output encoding via `SecurityUtil.encodeHtml` against XSS, salted SHA-256 (`CQ256`) password hashing, session fixation countermeasures, and SQL exception suppression.

---

## 🚀 Quick Start & How to Run

### 1. Database Setup
1. Open **MySQL Workbench** or run `setup_db.bat`.
2. Open and execute `database/codequest_db.sql`.
3. If your MySQL `root` password is not `root`, update it in:
   - `src/main/webapp/WEB-INF/web.xml` (under `<param-name>db.password</param-name>`), and
   - `src/main/java/com/codequest/util/DBConnection.java` (default constant).

### 2. Run in Apache Tomcat 10.1
1. CodeQuest is already deployed to:  
   `apache-tomcat-10.1.60\webapps\CodeQuest`
2. Start Tomcat by running `startup.bat` from `apache-tomcat-10.1.60\bin\startup.bat`.
3. Open your browser and navigate to:  
   👉 **`http://localhost:8080/CodeQuest/`**

### 3. Open in Eclipse IDE
1. Launch Eclipse IDE for Enterprise Java.
2. Go to **File -> Open Projects from File System...**
3. Select this directory (`C:\Users\DILIP KUMAR\Development\CodeQuest`).
4. Right-click project -> **Run As -> Run on Server** -> Select **Apache Tomcat v10.1**.

---

## 🔑 Default Credentials

### Administrator Portal
- **URL**: `http://localhost:8080/CodeQuest/admin-login.jsp`
- **Username**: `admin`
- **Password**: `admin123`

### Seeded Student Warriors
- `CyberKnight` / `Warrior123!` (Level 3 • 320 XP)
- `NeonCoder` / `Warrior123!` (Level 3 • 250 XP)
- `BinaryPhantom` / `Warrior123!` (Level 2 • 180 XP)
- *(Or register your own new cadet from the registration portal!)*
