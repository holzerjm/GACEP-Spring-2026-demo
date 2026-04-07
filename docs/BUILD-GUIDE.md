# BriefingClaw Build Guide

## How to Set Up the Multi-Agent Demo for GACEP Spring 2026

This guide walks you through building and configuring the entire BriefingClaw multi-agent system on a MacBook Pro. Estimated setup time: 2-3 hours (most of which is model download time).

> **See also:** [`USER-GUIDE.md`](../USER-GUIDE.md) for day-to-day operation, troubleshooting, and customization.

---

## Prerequisites

### Hardware
- MacBook Pro with Apple Silicon (M1/M2/M3/M4)
- 16 GB RAM minimum (32 GB recommended for smooth model serving)
- 30 GB free disk space (model + containers + workspace)
- USB-C to HDMI adapter for conference projector

### Software (install in order)

#### 1. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. Podman Desktop + CLI
```bash
brew install --cask podman-desktop
brew install podman
```

After installation:
- Open Podman Desktop
- Create a Podman machine: Settings → Resources → Create New
  - CPUs: 4
  - Memory: 12 GB
  - Disk: 60 GB
- Start the machine

#### 3. Podman AI Lab Extension
- In Podman Desktop: Extensions → Install → Search "AI Lab" → Install
- Restart Podman Desktop

#### 4. ZeroClaw
```bash
brew install zeroclaw
```
Verify: `zeroclaw --version`

#### 5. OpenClaw
```bash
git clone https://github.com/openclaw/openclaw.git ~/openclaw
cd ~/openclaw
```

#### 6. jq (for JSON parsing in demo)
```bash
brew install jq
```

---

## Step 1: Start the Model Service

### Download and Serve Granite 8B via Podman AI Lab

1. Open Podman Desktop → AI Lab → Models Catalog
2. Find **Granite 8B Instruct** (or `granite-8b-code-instruct` for code-heavy tasks)
3. Click "Download" — this will take 10-20 minutes depending on connection
4. Once downloaded, click "Start Inference Server"
5. Note the port (default: 8001)

### Verify Model Service
```bash
# Test the model endpoint
curl -s http://127.0.0.1:8001/v1/models | jq .

# Test a completion
curl -s http://127.0.0.1:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "granite-8b",
    "messages": [{"role": "user", "content": "Hello, who are you?"}],
    "max_tokens": 100
  }' | jq .choices[0].message.content
```

You should see a response from the model. If not, check that the Podman machine is running and AI Lab has the model loaded.

---

## Step 2: Configure OpenClaw (Oprah-tor + Déjà View + Draft Punk + Alfred Bitworth)

### Build the OpenClaw Container
```bash
cd ~/openclaw

# Build the container image
podman build -t openclaw:briefingclaw -f Dockerfile .
```

### Copy Demo Data to OpenClaw Workspace
```bash
# Create workspace directory
mkdir -p ~/.openclaw/workspace

# Copy demo data files
cp ~/briefingclaw/demo-data/* ~/.openclaw/workspace/
```

### Copy Skill Files
```bash
# Create skills directory
mkdir -p ~/.openclaw/skills

# Copy all agent skills
cp ~/briefingclaw/agents/orchestrator/SKILL.md ~/.openclaw/skills/orchestrator.md
cp ~/briefingclaw/agents/cab-historian/SKILL.md ~/.openclaw/skills/cab-historian.md
cp ~/briefingclaw/agents/briefing-architect/SKILL.md ~/.openclaw/skills/briefing-architect.md
cp ~/briefingclaw/agents/vvip-protocol/SKILL.md ~/.openclaw/skills/vvip-protocol.md
```

### Run the Onboarding Wizard
```bash
# Start OpenClaw container with workspace and skills mounted
podman run -d \
  --name briefingclaw-openclaw \
  -p 18789:18789 \
  -v ~/.openclaw/workspace:/app/workspace:ro \
  -v ~/.openclaw/skills:/app/skills:ro \
  -v openclaw-memory:/data/memory \
  -e GATEWAY_ENABLED=true \
  -e GATEWAY_PORT=18789 \
  openclaw:briefingclaw

# Run onboarding to connect to local model
podman exec -it briefingclaw-openclaw \
  node dist/index.js onboard \
  --non-interactive \
  --custom-base-url "http://host.containers.internal:8001/v1" \
  --custom-model-id "granite-8b" \
  --custom-api-key "not-needed" \
  --custom-compatibility openai

# Set agent name
podman exec -it briefingclaw-openclaw \
  node dist/index.js config set agent.name "Oprah-tor"
```

### Verify OpenClaw
```bash
# Check container is running
podman ps | grep briefingclaw

# Open the Gateway UI
open http://127.0.0.1:18789

# You should see the OpenClaw chat interface
# Type "Hello, Oprah-tor" — you should get a response
```

---

## Step 3: Configure ZeroClaw (Sherlock Ohms + Bloom-borg)

### Install Configuration
```bash
# Create ZeroClaw config directory
mkdir -p ~/.zeroclaw

# Copy the config file
cp ~/briefingclaw/config/zeroclaw-config.toml ~/.zeroclaw/config.toml

# Create output directories
mkdir -p ~/.zeroclaw/output/sherlock
mkdir -p ~/.zeroclaw/output/sentinel
mkdir -p ~/.zeroclaw/workspace

# Copy demo data to ZeroClaw workspace
cp ~/briefingclaw/demo-data/* ~/.zeroclaw/workspace/
```

### Set Up Search API Key
ZeroClaw needs a web search API for Sherlock Ohms and Bloom-borg. Get a free Tavily API key:

1. Go to https://tavily.com
2. Sign up for a free account (1000 searches/month free)
3. Copy your API key

```bash
# Set the API key
export TAVILY_API_KEY="tvly-your-key-here"

# Add to shell profile for persistence
echo 'export TAVILY_API_KEY="tvly-your-key-here"' >> ~/.zshrc
```

### Test ZeroClaw Profiles
```bash
# Test Sherlock Ohms
ZEROCLAW_PROFILE=sherlock zeroclaw agent \
  -m "Research Satya Nadella, CEO of Microsoft. Brief profile only."

# Test Bloom-borg
ZEROCLAW_PROFILE=sentinel zeroclaw agent \
  -m "Quick snapshot of Microsoft Corporation. Revenue and recent news only."
```

Both should produce structured output within 30-60 seconds.

---

## Step 4: Wire the Multi-Agent Communication

### Option A: Manual Orchestration (Simplest for Demo)
For the live demo, the simplest approach is to run Oprah-tor in the OpenClaw UI and manually trigger Sherlock Ohms/Bloom-borg in terminal tabs. Oprah-tor's skill files tell it what to expect from each agent, and you paste the results.

This is recommended for the GACEP demo because:
- It gives you full control of timing
- You can narrate each agent's work as it happens
- If one agent is slow, you can switch to the others

### Option B: Automated Inter-Agent Communication
For a more sophisticated setup, configure OpenClaw's Agent-to-Agent messaging:

```bash
# In OpenClaw, register ZeroClaw agents as external tools
podman exec -it briefingclaw-openclaw \
  node dist/index.js tools register \
  --name "sherlock" \
  --type "command" \
  --command "zeroclaw agent -p sherlock -m '{{input}}'" \
  --description "Executive research agent — researches a specific person"

podman exec -it briefingclaw-openclaw \
  node dist/index.js tools register \
  --name "sentinel" \
  --type "command" \
  --command "zeroclaw agent -p sentinel -m '{{input}}'" \
  --description "Account intelligence agent — researches a specific company"
```

### Option C: MCP Server Integration (Most Enterprise-Ready)
Set up each agent as an MCP (Model Context Protocol) server that Oprah-tor can call:

```bash
# ZeroClaw supports MCP server mode
ZEROCLAW_PROFILE=sherlock zeroclaw mcp-server --port 3001
ZEROCLAW_PROFILE=sentinel zeroclaw mcp-server --port 3002

# Register MCP servers with OpenClaw
podman exec -it briefingclaw-openclaw \
  node dist/index.js config set mcp.servers.sherlock "http://host.containers.internal:3001"
podman exec -it briefingclaw-openclaw \
  node dist/index.js config set mcp.servers.sentinel "http://host.containers.internal:3002"
```

---

## Step 5: Full System Test

### The Rehearsal Run
Run the exact demo scenario end-to-end:

```bash
# Terminal 1: Start Sherlock Ohms
ZEROCLAW_PROFILE=sherlock zeroclaw agent \
  -m "Research Sarah Chen, CIO of Meridian Health Systems. \
      Compile: career arc, recent public activity, technology priorities, \
      communication style. Return as structured executive profile."

# Terminal 2: Start Bloom-borg
ZEROCLAW_PROFILE=sentinel zeroclaw agent \
  -m "Analyze Meridian Health Systems. \
      Compile: company snapshot, recent news, technology landscape, \
      competitive dynamics. Return as structured company brief."

# Browser: In OpenClaw UI, type the full briefing request from the demo script
```

### Timing Benchmarks
Record how long each phase takes on YOUR hardware:
- Model cold start: _____ seconds
- Sherlock Ohms research: _____ seconds
- Bloom-borg research: _____ seconds
- Déjà View lookup: _____ seconds (should be <5s — it's reading local files)
- Draft Punk assembly: _____ seconds
- Alfred Bitworth protocol: _____ seconds
- Total end-to-end: _____ seconds

**Target**: Under 2 minutes total. If it's consistently over 3 minutes, consider:
- Using a smaller model (Granite 3B or a quantized 8B)
- Pre-warming the model with a test query before the demo
- Pre-caching some results

---

## Step 6: Record the Backup Video

The night before the session (at the hotel):

1. Connect to a reliable network
2. Open QuickTime Player → File → New Screen Recording
3. Run the full demo from Beat 3 through Beat 6
4. Save as `briefingclaw-demo-backup.mp4`
5. Test playback at presentation resolution
6. Keep the video file accessible — NOT buried in folders

---

## Step 7: Conference Day Checklist

### 30 Minutes Before Session
- [ ] Connect to projector, verify display
- [ ] Start Podman machine
- [ ] Start model service (Podman AI Lab → Granite → Start)
- [ ] Verify model endpoint: `curl http://127.0.0.1:8001/v1/models`
- [ ] Start OpenClaw container: `podman start briefingclaw-openclaw`
- [ ] Verify OpenClaw UI: `open http://127.0.0.1:18789`
- [ ] Warm up model with a test query (gets it into memory)
- [ ] Set terminal font size to 18pt+
- [ ] Set browser zoom to 125-150%
- [ ] Open backup video — test play, then pause at frame 1
- [ ] Test mobile hotspot (fallback network)
- [ ] Mute all notifications (Do Not Disturb mode)

### 5 Minutes Before Demo Segment
- [ ] Arrange terminal layout (Sherlock Ohms left, Bloom-borg right, browser bottom)
- [ ] Pre-type the demo prompt in a text editor (ready to paste)
- [ ] Confirm model is still responsive: quick test query
- [ ] Deep breath. You've got this.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Model not responding | Check Podman machine is running. Restart AI Lab model server. |
| OpenClaw container won't start | Check port 18789 isn't in use: `lsof -i :18789`. Kill conflicting process. |
| ZeroClaw can't find config | Verify `~/.zeroclaw/config.toml` exists. Check `ZEROCLAW_PROFILE` env var. |
| Slow responses | Model needs warm-up. Send a test query. Or switch to smaller model. |
| Web search failing | Check Tavily API key. Verify network connectivity. Demo data in workspace is the fallback. |
| Container can't reach model | Use `host.containers.internal` not `localhost` from inside containers. |
| "Permission denied" errors | Check volume mount permissions. May need `:Z` flag for SELinux. |
