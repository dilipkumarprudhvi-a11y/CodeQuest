@echo off
echo ========================================================
echo CodeQuest: Build and Compile Script (JDK 17 + Tomcat 10.1)
echo ========================================================

set "TOMCAT_HOME=C:\Users\DILIP KUMAR\Downloads\apache-tomcat-10.1.60-windows-x64 (2)\apache-tomcat-10.1.60"
set "SERVLET_JAR=%TOMCAT_HOME%\lib\servlet-api.jar"
set "MYSQL_JAR=src\main\webapp\WEB-INF\lib\mysql-connector-j-8.4.0.jar"
set "CLASSES_DIR=src\main\webapp\WEB-INF\classes"

if not exist "%CLASSES_DIR%" mkdir "%CLASSES_DIR%"

echo Compiling Java Sources into %CLASSES_DIR%...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f = (Get-ChildItem -Recurse -Filter *.java src\main\java).FullName; & javac -encoding UTF-8 -d '%CLASSES_DIR%' -cp '%SERVLET_JAR%;%MYSQL_JAR%' $f"

if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] Compilation complete. All classes compiled!
) else (
    echo [ERROR] Compilation failed with error code %ERRORLEVEL%.
)

echo ========================================================
