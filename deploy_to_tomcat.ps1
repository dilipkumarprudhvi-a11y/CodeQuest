# ========================================================
# CodeQuest Deploy to Apache Tomcat 10.1
# ========================================================
$sourceWebapp = "C:\Users\DILIP KUMAR\Development\CodeQuest\src\main\webapp"
$targetWebapp = "C:\Users\DILIP KUMAR\Downloads\apache-tomcat-10.1.60-windows-x64 (2)\apache-tomcat-10.1.60\webapps\CodeQuest"

Write-Host "Deploying CodeQuest to Tomcat..." -ForegroundColor Cyan

if (-not (Test-Path $targetWebapp)) {
    New-Item -ItemType Directory -Path $targetWebapp -Force | Out-Null
}

Copy-Item -Path "$sourceWebapp\*" -Destination $targetWebapp -Recurse -Force

Write-Host "Deployment Completed Successfully!" -ForegroundColor Green
Write-Host "Application is available at: http://localhost:8080/CodeQuest" -ForegroundColor Yellow

