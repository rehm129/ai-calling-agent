# AI Calling Agent — PearlCare Dental Clinic

A fully local, free, open-source AI voice calling agent powered by Ollama, Whisper, and Piper.

**Agent Name:** Maya  
**Business:** PearlCare Dental Clinic  
**All components run locally. No paid APIs required.**

---

## Features

- 🎙️ Real microphone capture in the browser
- 🗣️ Speech-to-text via faster-whisper (local)
- 🤖 AI conversation via Ollama + llama3.2:3b (local)
- 🔊 Text-to-speech via Piper (local)
- 📋 Live conversation transcript
- 💾 SQLite database for call logs and leads
- 🔄 n8n automation for lead processing
- 🪟 Windows-compatible

---

## Architecture

```
Browser (mic/speaker)
       ↕
  Frontend :3000
       ↕
  Backend :3001
    ├── Whisper (STT)
    ├── Ollama (LLM)
    └── Piper (TTS)
       ↕
    n8n :5678
       ↕
   SQLite DB
```

---

## Requirements

- Windows 10/11 (64-bit)
- Node.js 18 or 20+ (https://nodejs.org)
- Python 3.10+ (https://python.org)
- Ollama (https://ollama.com)
- 8 GB RAM minimum (16 GB recommended)
- 10 GB free disk space
- Microphone and speakers

---

## Quick Start

### 1. Install Prerequisites

```powershell
# Install Node.js
winget install OpenJS.NodeJS.LTS

# Install Python 3.11
winget install Python.Python.3.11

# Install Ollama
winget install Ollama.Ollama
```

### 2. Clone / Download Project

Place the project folder at: `C:\ai-calling-agent`

### 3. Run First-Time Setup

```cmd
cd C:\ai-calling-agent
install.bat
```

This will:
- Install Node.js packages
- Install Python packages (faster-whisper)
- Download AI model (~2 GB)
- Download Piper TTS + voice (~65 MB)

### 4. Start Everything

```cmd
start.bat
```

The browser opens automatically at http://localhost:3000

---

## Manual Setup (if install.bat fails)

```powershell
# Backend dependencies
cd C:\ai-calling-agent\backend
npm install
cd ..

# Python packages
pip install faster-whisper flask flask-cors requests

# AI model
ollama pull llama3.2:3b

# Piper TTS
node scripts\setup-piper.js

# Copy config
copy .env.example .env
```

---

## Running Services Individually

Open 4 separate PowerShell windows:

```powershell
# Window 1: Ollama
ollama serve

# Window 2: Backend
cd C:\ai-calling-agent\backend
node server.js

# Window 3: Frontend
cd C:\ai-calling-agent\frontend
node serve.js

# Window 4: n8n
n8n start
```

---

## n8n Setup

1. Open http://localhost:5678
2. Create an account (local only)
3. Click **Import from file**
4. Select `C:\ai-calling-agent\n8n\workflow.json`
5. Click **Activate** to enable the webhook

The webhook URL: `http://localhost:5678/webhook/call-ended`

---

## Configuration

Edit `C:\ai-calling-agent\.env`:

```env
OLLAMA_MODEL=llama3.2:3b    # Change to llama3.2:1b for faster/less RAM
WHISPER_MODEL=tiny           # Change to base or small for better accuracy
PIPER_VOICE=en_US-amy-medium # Change voice
```

---

## Customize for Your Business

Edit `prompts/system-prompt.txt` and replace:
- `[CLINIC_ADDRESS]` → your address
- `[CLINIC_HOURS]` → your hours
- `[CLINIC_PHONE]` → your phone
- `[CLINIC_EMAIL]` → your email
- `[EMERGENCY_PHONE]` → after-hours number

---

## Performance Guide (CPU-only)

| Component | Speed | RAM Usage |
|---|---|---|
| llama3.2:1b | ~3s response | ~2 GB |
| llama3.2:3b | ~8s response | ~4 GB |
| Whisper tiny | ~2s transcribe | ~1 GB |
| Whisper base | ~4s transcribe | ~1.5 GB |
| Piper TTS | ~1s synthesis | ~0.5 GB |

For low-RAM computers: use `llama3.2:1b` and `WHISPER_MODEL=tiny`

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Microphone not working | Allow mic permission in browser; check Windows mic settings |
| Ollama connection refused | Run `ollama serve` in a terminal |
| Model not found | Run `ollama pull llama3.2:3b` |
| n8n not responding | Run `n8n start`, open localhost:5678 and activate workflow |
| TTS not playing | Run `node scripts/setup-piper.js` to download Piper |
| STT not detecting speech | Speak clearly; check mic level in Windows Sound settings |
| CORS error | Make sure backend is running on port 3001 |
| Port in use | Change port in .env, or find and close the conflicting process |
| node not recognized | Reinstall Node.js and check PATH |
| python not recognized | Reinstall Python with "Add to PATH" checked |

---

## Project Structure

```
ai-calling-agent/
├── frontend/
│   ├── index.html       ← Dashboard UI
│   └── serve.js         ← Static file server
├── backend/
│   ├── server.js        ← Express server
│   ├── routes/          ← API endpoints
│   ├── services/        ← Ollama, Whisper, Piper
│   └── database/        ← SQLite setup
├── scripts/
│   ├── transcribe.py    ← Whisper Python script
│   ├── setup-piper.js   ← Piper downloader
│   └── test-health.js   ← Service checker
├── n8n/
│   └── workflow.json    ← Importable n8n workflow
├── prompts/
│   └── system-prompt.txt ← Maya's AI personality
├── data/                ← SQLite database (auto-created)
├── piper/               ← Piper TTS binary (auto-downloaded)
├── .env.example         ← Config template
├── .gitignore
├── install.bat          ← First-time setup
├── start.bat            ← Start all services
└── start.ps1            ← PowerShell alternative
```

---

## SIP Integration (Phase 3)

> Real PSTN calling requires a telecom/SIP provider and is normally not completely free.

For local SIP testing (no real phone needed):
- Install Asterisk or FreeSWITCH as local PBX
- Configure extensions (1001, 1002)
- Use Zoiper or MicroSIP softphone

For real calls:
- Register with a SIP provider (Twilio, VoIP.ms, Telnyx, etc.)
- Costs approximately $1–2/month for a DID number
- Route inbound calls through Asterisk → AI backend

---

## Security

- All services run locally
- No data leaves your machine
- Never commit `.env` to GitHub
- The `.gitignore` excludes secrets, models, and database files

---

## Future Improvements

- [ ] Real-time barge-in interruption
- [ ] WebSocket for lower latency
- [ ] Multiple voice options
- [ ] Google Calendar integration for real booking
- [ ] CRM integration (HubSpot free tier)
- [ ] SIP/PSTN phone number
- [ ] Call recording
- [ ] Multi-language support
- [ ] Dashboard for call history
