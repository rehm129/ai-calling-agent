@echo off
title AI Calling Agent — First-Time Setup
color 0B
cls

echo.
echo  ====================================================
echo    AI CALLING AGENT — FIRST-TIME SETUP
echo  ====================================================
echo.
echo  This will install all required components.
echo  Make sure you have internet access.
echo.
pause

:: Step 1 — Install backend dependencies
echo.
echo  [STEP 1] Installing backend Node.js dependencies...
cd backend
call npm install
if %errorlevel% neq 0 (
  echo  [ERROR] npm install failed. Make sure Node.js is installed.
  pause
  exit /b 1
)
cd ..
echo  [OK] Backend dependencies installed.

:: Step 2 — Install Python dependencies
echo.
echo  [STEP 2] Installing Python dependencies (Whisper)...
python -m pip install faster-whisper flask flask-cors requests --quiet
if %errorlevel% neq 0 (
  echo  [WARN] Python install had issues. Check Python installation.
) else (
  echo  [OK] Python packages installed.
)

:: Step 3 — Download Ollama model
echo.
echo  [STEP 3] Downloading AI model (llama3.2:3b ~2GB)...
echo  This may take several minutes depending on your internet speed.
ollama pull llama3.2:3b
if %errorlevel% neq 0 (
  echo  [ERROR] Failed to download model. Make sure Ollama is installed.
  pause
  exit /b 1
)
echo  [OK] AI model ready.

:: Step 4 — Setup Piper TTS
echo.
echo  [STEP 4] Setting up Piper TTS (~65 MB download)...
node scripts\setup-piper.js
if %errorlevel% neq 0 (
  echo  [WARN] Piper setup failed. TTS may not work.
  echo  You can retry later by running: node scripts\setup-piper.js
) else (
  echo  [OK] Piper TTS ready.
)

:: Step 5 — Create .env
echo.
echo  [STEP 5] Creating configuration file...
if not exist ".env" (
  copy ".env.example" ".env" >nul
  echo  [OK] .env created from template.
) else (
  echo  [OK] .env already exists.
)

:: Create data directory
mkdir data 2>nul

echo.
echo  ====================================================
echo    SETUP COMPLETE!
echo.
echo    Now run: start.bat
echo  ====================================================
echo.
pause
