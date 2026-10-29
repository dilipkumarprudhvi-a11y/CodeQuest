@echo off
setlocal
echo ========================================================
echo CodeQuest: Push to GitHub Helper
echo ========================================================
echo.

set /p REPO_URL="Enter your GitHub Repository URL (or press Enter for default https://github.com/dilipkumarprudhvi-a11y/CodeQuest.git): "
if "%REPO_URL%"=="" (
    set REPO_URL=https://github.com/dilipkumarprudhvi-a11y/CodeQuest.git
)

echo.
echo Linking remote origin to %REPO_URL%...
git remote remove origin 2>nul
git remote add origin %REPO_URL%

echo.
echo Pushing branch 'main' to GitHub...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo [SUCCESS] CodeQuest pushed to GitHub successfully!
    echo ========================================================
) else (
    echo.
    echo [ERROR] Push failed. Please ensure the repository exists on GitHub
    echo and you have authenticated via Git Credential Manager.
)

pause
