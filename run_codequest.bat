@echo off
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
set "JRE_HOME=%JAVA_HOME%"
set "CATALINA_HOME=C:\Users\DILIP KUMAR\Downloads\apache-tomcat-10.1.60-windows-x64 (2)\apache-tomcat-10.1.60"
set "CATALINA_BASE=%CATALINA_HOME%"

echo ========================================================
echo  CodeQuest - Starting Apache Tomcat 10.1 Engine
echo ========================================================
echo Starting Tomcat Server...
start "Tomcat 10.1" "%CATALINA_HOME%\bin\startup.bat"

echo Waiting for server to initialize...
timeout /t 4 /nobreak >nul

echo Launching CodeQuest in Default Browser...
start http://localhost:8080/CodeQuest/index.html

echo.
echo ========================================================
echo  CodeQuest is running at: http://localhost:8080/CodeQuest
echo  Admin Credentials: admin / admin123
echo ========================================================
pause

