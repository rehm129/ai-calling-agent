# ============================================================
# AI CALLING AGENT — PowerShell Startup Script
# Run: .\start.ps1
# ============================================================

# Allow script execution (run once if needed):
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$Host.UI.RawUI.WindowTitle = "AI Calling Agent — PearlCare Dental"
$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "  ====================================================" -ForegroundColor Cyan
Write-Host "    AI CALLING AGENT — PearlCare Dental Clinic" -ForegroundColor White
Write-Host "    Maya Voice Agent v1.0" -ForegroundColor Gray
Write-Host "  ====================================================" -ForegroundColor Cyan
Write-Host ""

# ── Check .env ──────────────────────────────────────────────
if (-not (Test-Path ".\.env")) {
  Write-Host "  [WARN] .env not found. Creating from template..." -ForegroundColor Yellow
  Copy-Item ".\.env.example" ".\.env"
  Write-Host "  [INFO] .env created. Edit it to customize." -ForegroundColor Green
}

# ── Check Node.js ────────────────────────────────────────────
try {
  $nodeVersion = node --version 2>&1
  Write-Host "  [OK] Node.js: $nodeVersion" -ForegroundColor Green
} catch {
  Write-Host "  [ERROR] Node.js not found! Install from: https://nodejs.org" -ForegroundColor Red
  Read-Host "Press Enter to exit"
  exit 1
}

# ── Check Python ─────────────────────────────────────────────
try {
  $pyVersion = python --version 2>&1
  Write-Host "  [OK] Python: $pyVersion" -ForegroundColor Green
} catch {
  Write-Host "  [WARN] Python not found. Speech-to-text may not work." -ForegroundColor Yellow
}

# ── Check Ollama ─────────────────────────────────────────────
try {
  $ollamaVersion = ollama --version 2>&1
  Write-Host "  [OK] Ollama: $ollamaVersion" -ForegroundColor Green
} catch {
  Write-Host "  [ERROR] Ollama not found! Install from: https://ollama.com" -ForegroundColor Red
  Read-Host "Press Enter to exit"
  exit 1
}

# ── Install backend dependencies ─────────────────────────────
if (-not (Test-Path ".\backend\node_modules")) {
  Write-Host ""
  Write-Host "  [INFO] Installing backend dependencies..." -ForegroundColor Cyan
  Set-Location backend
  npm install
  Set-Location ..
}

# ── Setup Piper TTS ──────────────────────────────────────────
if (-not (Test-Path ".\piper\piper.exe")) {
  Write-Host ""
  Write-Host "  [INFO] Piper TTS not found. Running setup (~65 MB download)..." -ForegroundColor Cyan
  node scripts\setup-piper.js
}

Write-Host ""
Write-Host "  Starting services..." -ForegroundColor Cyan
Write-Host ""

# ── Start Ollama ─────────────────────────────────────────────
Write-Host "  [1/4] Checking Ollama..." -ForegroundColor White
try {
  $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 -ErrorAction Stop
  Write-Host "        Ollama already running." -ForegroundColor Green
} catch {
  Write-Host "        Starting Ollama..." -ForegroundColor Yellow
  Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
  Start-Sleep -Seconds 3
}

# ── Start Backend ─────────────────────────────────────────────
Write-Host "  [2/4] Starting Backend Server (port 3001)..." -ForegroundColor White
Start-Process -FilePath "cmd" -ArgumentList "/c cd backend && node server.js" `
  -WindowStyle Minimized -WorkingDirectory (Get-Location).Path
Start-Sleep -Seconds 2

# ── Start Frontend ────────────────────────────────────────────
Write-Host "  [3/4] Starting Frontend Server (port 3000)..." -ForegroundColor White
Start-Process -FilePath "cmd" -ArgumentList "/c cd frontend && node serve.js" `
  -WindowStyle Minimized -WorkingDirectory (Get-Location).Path
Start-Sleep -Seconds 2

# ── Start n8n ─────────────────────────────────────────────────
Write-Host "  [4/4] Starting n8n (port 5678)..." -ForegroundColor White
Start-Process -FilePath "cmd" -ArgumentList "/c n8n start" `
  -WindowStyle Minimized -WorkingDirectory (Get-Location).Path
Start-Sleep -Seconds 5

# ── Wait for backend ──────────────────────────────────────────
Write-Host ""
Write-Host "  Waiting for backend to be ready..." -ForegroundColor Gray
$tries = 0
do {
  Start-Sleep -Seconds 2
  $tries++
  try {
    $r = Invoke-WebRequest -Uri "http://localhost:3001/health" -TimeoutSec 2 -ErrorAction Stop
    Write-Host "  Backend is ready!" -ForegroundColor Green
    break
  } catch {
    Write-Host "  Waiting... ($tries)" -ForegroundColor Gray
  }
} while ($tries -lt 15)

# ── Open browser ──────────────────────────────────────────────
Write-Host ""
Write-Host "  Opening AI Calling Agent..." -ForegroundColor Cyan
Start-Process "http://localhost:3000"

Write-Host ""
Write-Host "  ====================================================" -ForegroundColor Cyan
Write-Host "    READY!" -ForegroundColor Green
Write-Host ""
Write-Host "    AI Agent:  http://localhost:3000" -ForegroundColor White
Write-Host "    n8n:       http://localhost:5678" -ForegroundColor White  
Write-Host "    Backend:   http://localhost:3001" -ForegroundColor White
Write-Host "  ====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Press Ctrl+C or close this window to stop." -ForegroundColor Gray
Write-Host "  (Background services will keep running)" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to close"
