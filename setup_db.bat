@echo off
echo ========================================================
echo CodeQuest: MySQL Database Initialization
echo ========================================================
echo This script will execute database\codequest_db.sql in your local MySQL instance.
echo.
set /p MYSQL_PASS="Enter your MySQL root password (press Enter for default '@123Kumar'): "
if "%MYSQL_PASS%"=="" set "MYSQL_PASS=@123Kumar"

set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if not exist "%MYSQL_EXE%" (
    set "MYSQL_EXE=mysql"
)

"%MYSQL_EXE%" -u root -p"%MYSQL_PASS%" < database\codequest_db.sql

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] codequest_db and all seed missions created successfully!
) else (
    echo.
    echo [NOTE] If access denied, open MySQL Workbench and open database\codequest_db.sql then click Execute (lightning icon).
)
echo.
pause

