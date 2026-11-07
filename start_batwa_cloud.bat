@echo off
title Batwa Cloud Backend & Tunnel
echo ===================================================
echo   BATWA WALLET - 24/7 CLOUD LAUNCHER
echo   Database: Supabase PostgreSQL
echo   Gateway:  Cloudflare Tunnel
echo ===================================================

echo [1/2] Starting Spring Boot Backend with Supabase Database...
start /min "" java -Dserver.port=8080 -Dspring.datasource.url="jdbc:postgresql://aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?sslmode=require" -Dspring.datasource.username="postgres.okohjyjsdoltxwgddolv" -Dspring.datasource.password="Batwa@Secure2026" -Dspring.datasource.driver-class-name="org.postgresql.Driver" -jar backend\target\batwa-wallet-service-1.0.0.jar

timeout /t 5 /nobreak > nul

echo [2/2] Starting Cloudflare Tunnel...
start /min "" "%USERPROFILE%\.gemini\antigravity\cloudflared.exe" tunnel --url http://127.0.0.1:8080

echo.
echo ===================================================
echo   BATWA BACKEND IS LIVE & CONNECTED!
echo ===================================================
timeout /t 3 > nul
