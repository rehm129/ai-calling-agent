@echo off
title AI Calling Agent — PearlCare Dental
color 0A
cls

echo.
echo  ====================================================
echo    AI CALLING AGENT — PearlCare Dental Clinic
echo    Maya Voice Agent
echo  ====================================================
echo.

:: Check if .env exists
if not exist ".env" (
  echo  [WARN] .env file not found. Copying from .env.example...
  copy ".env.example" ".env" >nul
  echo  [INFO] .env created. Edit it to customize settings.
  echo.
)

:: Check if node_modules exist
if not exist "backend\node_modules" (
  echo  [INFO] Installing backend dependencies...
  cd backend
  call npm install
  cd ..
  echo.
)

:: Check if Piper exists
if not exist "piper\piper.exe" (
  echo  [INFO] Piper TTS not found. Running setup...
  node scripts\setup-piper.js
  echo.
)

echo  Starting services...
echo.

:: Start Ollama (if not already running)
echo  [1/4] Checking Ollama...
curl -s http://localhost:11434/api/tags >nul 2>&1
if %errorlevel% neq 0 (
  echo  Starting Ollama...
  start "Ollama" /min cmd /c "ollama serve"
  timeout /t 3 >nul
) else (
  echo  Ollama already running.
)

:: Start Backend
echo  [2/4] Starting Backend Server (port 3001)...
start "AI Agent Backend" /min cmd /c "cd backend && node server.js"
timeout /t 2 >nul

:: Start Frontend
echo  [3/4] Starting Frontend Server (port 3000)...
start "AI Agent Frontend" /min cmd /c "cd frontend && node serve.js"
timeout /t 2 >nul

:: Start n8n
echo  [4/4] Starting n8n (port 5678)...
start "n8n Automation" /min cmd /c "n8n start"
timeout /t 3 >nul

echo.
echo  ====================================================
echo    All services are starting...
echo  ====================================================
echo.
echo  Waiting for servers to be ready...
timeout /t 5 >nul

:: Open browser
echo  Opening AI Calling Agent in browser...
start http://localhost:3000

echo.
echo  ====================================================
echo    READY!
echo.
echo    AI Agent:  http://localhost:3000
echo    n8n:       http://localhost:5678
echo    Backend:   http://localhost:3001
echo  ====================================================
echo.
echo  Press any key to close this window.
echo  (Services will continue running in background)
echo.
pause >nul
