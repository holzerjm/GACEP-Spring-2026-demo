# BriefingClaw User Guide

A practical guide for installing, configuring, and operating the BriefingClaw multi-agent executive briefing system.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Installation](#2-installation)
3. [Configuration](#3-configuration)
4. [Starting the System](#4-starting-the-system)
5. [Running a Briefing Request](#5-running-a-briefing-request)
6. [Using the Dashboard](#6-using-the-dashboard)
7. [Using the CLI (briefingclaw.sh)](#7-using-the-cli-briefingclawsh)
8. [Running Individual Agents](#8-running-individual-agents)
9. [Understanding the Output](#9-understanding-the-output)
10. [Demo Data Reference](#10-demo-data-reference)
11. [Conference Day Checklist](#11-conference-day-checklist)
12. [Troubleshooting](#12-troubleshooting)
13. [Customization](#13-customization)

---

## 1. Prerequisites

### Hardware
- MacBook Pro (Apple Silicon or Intel)
- 16 GB RAM minimum (Granite 8B requires ~6 GB)
- 30 GB free disk space (model weights, containers, and workspace)
- USB-C adapter for venue projection (if presenting live)

### Software (installed in Section 2)
- macOS with Homebrew
- Podman Desktop with Podman CLI
- Podman AI Lab extension
- ZeroClaw CLI
- OpenClaw container image
- jq (JSON processor)

### API Keys
You need at minimum:
- **One frontier LLM provider** — Anthropic (Claude), OpenAI (GPT), or Google (Gemini)
- **Tavily API key** — for web search capabilities used by Sherlock Ohms and Bloom-borg

> **Tip:** After cloning, open `index.html` in a browser to navigate between all demo pages and resources. It's the fastest way to get oriented.

Sign up for keys at:
- Anthropic: https://console.anthropic.com
- OpenAI: https://platform.openai.com
- Google AI: https://aistudio.google.com
- Tavily: https://tavily.com

---

## 2. Installation

### Step 2.1 — Install core tools

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Podman and utilities
brew install podman podman-compose jq
```

### Step 2.2 — Install Podman Desktop and AI Lab

1. Download Podman Desktop from https://podman-desktop.io
2. Open Podman Desktop and complete the initial setup
3. Go to **Extensions** and install **Podman AI Lab**
4. In AI Lab, download the **IBM Granite 8B Instruct** model
5. Start the model service — it will serve on `http://127.0.0.1:8001/v1`

Verify the model is running:
```bash
curl -s http://127.0.0.1:8001/v1/models | jq '.data[0].id'
```
You should see the Granite model ID in the output.

### Step 2.3 — Install ZeroClaw

```bash
curl -fsSL https://install.zeroclaw.dev | sh
```

Verify:
```bash
zeroclaw --version
```

### Step 2.4 — Install OpenClaw

Pull the OpenClaw container image:
```bash
podman pull openclaw/openclaw:latest
```

### Step 2.5 — Clone this repository

```bash
git clone https://github.com/<your-account>/GACEP-Spring-2026-demo.git
cd GACEP-Spring-2026-demo
```

---

## 3. Configuration

### Step 3.1 — Set up API keys

```bash
cp config/env.example config/.env
```

Edit `config/.env` and add your API keys:

```bash
# Choose ONE frontier provider (uncomment the one you're using):
ANTHROPIC_API_KEY=sk-ant-your-key-here
# OPENAI_API_KEY=sk-your-key-here
# GOOGLE_API_KEY=your-key-here

# Web search (required for Sherlock Ohms and Bloom-borg):
TAVILY_API_KEY=tvly-your-key-here
```

The local Granite model does not require an API key.

### Step 3.2 — Configure ZeroClaw

```bash
mkdir -p ~/.config/zeroclaw
cp config/zeroclaw-config.toml ~/.config/zeroclaw/config.toml
```

The ZeroClaw config defines two agent profiles:
- **sherlock-ohms** — Executive research agent (uses frontier model + web search)
- **bloom-borg** — Account intelligence agent (uses frontier model + web search)

Both profiles point to their respective `SKILL.md` files and use the Tavily API for web search.

### Step 3.3 — Set up the workspace

Create the workspace directory structure that OpenClaw expects:

```bash
mkdir -p ~/briefingclaw/agents
mkdir -p ~/briefingclaw/workspace

# Copy agent skill files
cp -r agents/* ~/briefingclaw/agents/

# Copy demo data to workspace
cp demo-data/* ~/briefingclaw/workspace/
```

### Step 3.4 — Verify configuration

Check that the OpenClaw config references are correct:
- `config/openclaw-config.yml` — skill directories and workspace paths
- `config/podman-compose.yml` — volume mounts match your local paths

---

## 4. Starting the System

### Option A — Using the CLI wrapper (recommended)

```bash
# First-time setup (interactive wizard)
./briefingclaw.sh setup

# Start all infrastructure
./briefingclaw.sh start

# Check system health
./briefingclaw.sh status
```

For quick rehearsal without booting infrastructure: `./briefingclaw.sh preview`. This opens the dashboards in a browser and lets you rehearse the demo beats against the animated simulation. It skips all the Podman/model/OpenClaw health checks and is ideal for practicing narration, timing, and persona switching at your desk or on a plane.

### Option B — Manual startup

```bash
# 1. Start Podman machine (if not running)
podman machine start

# 2. Ensure Granite 8B is serving via Podman AI Lab
#    (Open Podman Desktop > AI Lab > Models > Start)

# 3. Start OpenClaw container
cd config
podman-compose up -d

# 4. Verify OpenClaw is healthy
curl -s http://127.0.0.1:18789/health | jq .
```

### Verifying the stack

| Component | How to check | Expected result |
|-----------|-------------|-----------------|
| Podman | `podman machine info` | Machine running |
| Granite 8B | `curl -s http://127.0.0.1:8001/v1/models` | Model ID returned |
| OpenClaw | `curl -s http://127.0.0.1:18789/health` | `{"status": "healthy"}` |
| ZeroClaw | `zeroclaw --version` | Version string |
| API keys | `./briefingclaw.sh status` | Keys configured |

---

## 5. Running a Briefing Request

### Via the OpenClaw Gateway UI

1. Open your browser to `http://127.0.0.1:18789`
2. You will see the Oprah-tor orchestrator chat interface
3. Type (or paste) a briefing request:

```
I have a briefing tomorrow with Sarah Chen, CIO of Meridian Health Systems.
She is a SAB member. Her executive sponsor is Maria Torres.
```

4. Oprah-tor will:
   - Parse the request and identify key entities
   - Dispatch Sherlock Ohms, Bloom-borg, and Deja View in parallel (Phase 1)
   - Validate returned intelligence
   - Dispatch Draft Punk and Alfred Bitworth (Phase 2)
   - Synthesize and deliver the final briefing package

5. The complete output appears in the chat as structured markdown documents

### Via the CLI

```bash
# Full demo environment (opens terminal tabs + browser)
./briefingclaw.sh demo

# Or run a quick request directly through the CLI
./briefingclaw.sh sherlock "Sarah Chen CIO Meridian Health Systems"
./briefingclaw.sh bloomborg "Meridian Health Systems"
```

---

## 6. Using the Dashboard

The interactive dashboard (`briefingclaw-dashboard.html`) provides an animated visualization of the entire agent pipeline. It is designed for conference presentations and works both as a live monitoring tool and as a standalone animated simulation.

### Opening the Dashboard

```bash
# Open in your default browser
open briefingclaw-dashboard.html

# Or with autostart (simulation begins immediately)
open "briefingclaw-dashboard.html?autostart"
```

### Dashboard Layout

| Section | Description |
|---------|-------------|
| **Pipeline Visualization** | Top section. Shows all 8 agents as animated nodes with particle flow along connection paths. Agents glow when working and get a green checkmark when complete. |
| **Control Bar** | Pre-populated briefing request, "Start Demo" and "Reset" buttons, elapsed timer, mode badge (LIVE / LOCAL ONLY / SIMULATED), and PDF Export button. |
| **Infrastructure Status** | Bottom-left panel. Pulsing status dots for Podman, Granite 8B, OpenClaw, and ZeroClaw. Green = connected, red = disconnected. |
| **Agent Activity** | Bottom-right panel. Scrolling log with typewriter animation showing each agent's work in real time. |
| **Deliverables** | Cards that light up gold as each document is completed. Completed cards show risk badges summarizing the outcome and are clickable to open the full formatted document. |
| **Critical Flags** | Slide-in alerts for overdue action items, open follow-ups, and opportunities. |
| **Footer** | Contains a GitHub repository link for attendees who want to try the system themselves. |

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space / Enter | Start the demo simulation |
| Escape | Reset to initial state |
| F | Toggle fullscreen (ideal for projectors) |
| T | Download telemetry JSON for the current session |

### Risk Badges on Deliverable Cards

Completed deliverable cards show a coloured badge summarising the outcome so the audience can read the story at a glance without opening each card:

| Badge colour | Meaning |
|--------------|---------|
| Red | Critical — an overdue commitment, escalation, or blocker surfaced in the briefing |
| Amber | Warning — an open follow-up, unresolved risk, or stress signal |
| Green | Positive — strong relationship signals, untapped opportunities, champion momentum |

Badges appear as each card completes and carry the same colour into the PDF export.

### PDF Export

A **PDF Export** button in the control bar produces a printable briefing package for the currently selected persona. The export includes the executive dossier, backgrounder, talking points, agenda, VVIP protocol checklist, sponsor readiness brief, and the Oddsfather's success verdict. Use this to hand a polished artefact to attendees who ask to take the output home.

### Mode Badge: LIVE / LOCAL ONLY / SIMULATED

The dashboard polls `http://127.0.0.1:8001` (Granite model) and `http://127.0.0.1:18789` (OpenClaw gateway) every 5 seconds and shows one of three mode badges in the header:

| Badge | Meaning |
|-------|---------|
| **LIVE** (green) | Both the Granite 8B model and the OpenClaw gateway are responding. Full stack available. |
| **LOCAL ONLY** (amber) | Granite 8B is reachable but the OpenClaw gateway is down. Local agents (Deja View, Draft Punk, Alfred Bitworth, Sponsor Coach, The Oddsfather) can still run via direct model calls; frontier agents are unavailable. |
| **SIMULATED** (gold) | Neither service is responding. The animated scripted sequence runs standalone with no backend. |

The animated simulation runs identically in all three modes. It is a scripted 42-second sequence sourced from the real demo data files, designed to match the timing of the live demo script.

### Telemetry Logging

Every session event — button clicks, persona switches, phase transitions, mode changes, PDF exports — is captured to the browser's `localStorage` as a rolling telemetry log. Press **T** at any time to download the full session log as JSON. This is useful for debugging a rehearsal that went sideways, for comparing timing across venues, and for post-session instrumentation reviews.

### Contact Dropdown

The dashboard includes a dropdown selector to switch between three demo scenarios:

| Contact | Company | Tier | Scenario |
|---------|---------|------|----------|
| Sarah Chen | Meridian Health Systems | Gold | Overdue commitments, approaching champion |
| David Park | Apex Financial Group | Gold | Retention crisis, Azure competitor, failed migration |
| Rachel Morrison | TerraScale Energy | Platinum | P1 outage, champion under stress, board presentation |
| Pepper Minton | SnackStack Technologies | Gold | Viral TikTok scaling crisis, production crashed |
| Ziggy Stardust-Chen | Quantum Pretzel Corp | Silver | SAB alumni win-back, AWS courting, renewal at risk |
| Luna Wavelength | GalactiCorp Space Industries | Platinum | $8M deal blocked by CISO security audit |
| Max Bandwidth | Thunderbolt Logistics | Gold | AI pilot $4M savings, VP Ops blocking scale-up |
| Sage Cloudberry | WonderPaws Pet Wellness | Standard | First briefing, evaluating Red Hat vs VMware |

Select a contact from the dropdown, then click "Start Demo". Each scenario has its own timeline with distinct activity feed messages, critical flags, and narrative arc.

### Clickable Deliverables

After the simulation completes (or while running), all 8 completed deliverable cards are clickable. Clicking opens a formatted modal viewer with complete HTML content for that deliverable. Key deliverables for all 8 contacts are embedded in the dashboard with clickable modal content. Close the modal with the X button, clicking the overlay, or pressing Escape.

> **Red Hat variant:** For Red Hat-affiliated presentations, use `briefingclaw-dashboard-redhat.html` instead. It has identical functionality with Red Hat Display/Text/Mono fonts, PatternFly dark theme, and Red Hat Red accents.

### Key Moments in the Simulation

All eight scenarios follow the same phase structure but surface different intelligence:

| Time | Event |
|------|-------|
| 0-7s | Oprah-tor parses the request and dispatches Phase 1 agents |
| 7-20s | Sherlock, Bloom-borg, and Deja View work in parallel |
| ~15s | Deja View flags the **critical issue** (varies by contact) |
| 21-37s | Draft Punk and Alfred Bitworth produce deliverables progressively |
| 38-42s | Oprah-tor synthesizes the final package (8/8 deliverables) |

---

## 7. Using the CLI (briefingclaw.sh)

The `briefingclaw.sh` script provides an interactive menu for managing the entire demo lifecycle.

### Available Commands

| Command | Description |
|---------|-------------|
| `./briefingclaw.sh setup` | First-time configuration wizard. Creates directories, copies files, prompts for API keys. |
| `./briefingclaw.sh start` | Launches Podman machine, AI Lab model server, and OpenClaw container. |
| `./briefingclaw.sh stop` | Stops the OpenClaw container and optionally the model server. |
| `./briefingclaw.sh status` | Displays system health: Podman status, model serving, API key configuration, container state. |
| `./briefingclaw.sh demo` | Sets up the full demo environment with pre-configured terminal tabs and browser window. |
| `./briefingclaw.sh preview` | Rehearsal mode. Opens the dashboards without running any infrastructure checks, so you can practise narration, timing, and persona switching against the animated simulation. |
| `./briefingclaw.sh preflight` | Conference-day checklist. Run 30 minutes before your session. Validates all components. |
| `./briefingclaw.sh sherlock "<query>"` | Run Sherlock Ohms standalone for executive research. |
| `./briefingclaw.sh bloomborg "<query>"` | Run Bloom-borg standalone for company research. |
| `./briefingclaw.sh record` | Guides recording a backup demo video (fallback if live demo fails). |

### Typical workflow

```bash
# Day before the conference
./briefingclaw.sh setup          # Configure if not done yet
./briefingclaw.sh start          # Start everything
./briefingclaw.sh status         # Verify all green
./briefingclaw.sh record         # Record backup video

# 30 minutes before your session
./briefingclaw.sh preflight      # Run the full checklist

# Showtime
./briefingclaw.sh demo           # Launch the demo environment
```

---

## 8. Running Individual Agents

Each agent can be run independently for testing or targeted research.

### Sherlock Ohms (Executive Research)

```bash
zeroclaw agent -p sherlock-ohms
# Then type: "Research Sarah Chen, CIO of Meridian Health Systems"
```

Produces: executive profile with career arc, recent activity, tech priorities, communication style, and conversation starters.

### Bloom-borg (Account Intelligence)

```bash
zeroclaw agent -p bloom-borg
# Then type: "Research Meridian Health Systems"
```

Produces: company brief with business overview, financials, recent news, technology landscape, competitive dynamics, and briefing relevance.

### Deja View (SAB Historian)

Runs inside the OpenClaw container. Accessed through the Oprah-tor orchestrator or directly via the OpenClaw gateway API.

Reads from workspace files:
- `sab-meeting-notes.md`
- `engagement-history.md`
- `crm-export.json`
- `vvip-roster.json`

### Draft Punk (Briefing Architect)

Runs inside the OpenClaw container. Receives synthesized intelligence from Oprah-tor and assembles the five document deliverables.

### Alfred Bitworth (VVIP Protocol)

Runs inside the OpenClaw container. Reads VVIP roster and engagement history to generate protocol checklists and sponsor alerts.

### Sponsor Coach

Runs inside the OpenClaw container. Scores the executive sponsor's readiness for the drop-in, flags coaching gaps, and produces a short prep brief the sponsor can read in under two minutes.

### The Oddsfather

Runs inside the OpenClaw container during Phase 3. Reviews the full deliverable package and the critical flags to generate a success probability verdict with the top risks and top levers that could shift the outcome.

---

## 9. Understanding the Output

A complete briefing package contains the following deliverables:

### From Draft Punk

| Deliverable | Description | Length |
|-------------|-------------|--------|
| **Executive Dossier** | Quick-reference card with visitor snapshot, key talking points, and critical flags | 1 page |
| **Briefing Backgrounder** | Comprehensive prep document weaving executive research, company intel, and engagement history | 2 pages |
| **Sponsor Talking Points** | Prep sheet for the executive sponsor's drop-in, with context, relationship notes, and suggested topics | 1 page |
| **Recommended Agenda** | Time-blocked agenda with rationale for each session, informed by visitor interests and engagement history | 1 page |
| **Conversation Starters** | Three personalized, non-generic openers drawn from recent activity, shared interests, or SAB themes | Short list |

### From Alfred Bitworth

| Deliverable | Description |
|-------------|-------------|
| **VVIP Protocol Checklist** | Actionable checklist with assignees and deadlines covering pre-briefing setup, day-of arrival, and post-briefing follow-up |
| **Sponsor Alert Draft** | Email template for notifying the executive sponsor with context and talking points reference |
| **Engagement Log Entry** | Structured record of the upcoming briefing for future cross-program reference |

### From Sponsor Coach

| Deliverable | Description |
|-------------|-------------|
| **Sponsor Readiness Brief** | Short coaching brief with the sponsor's readiness score, what to review before the drop-in, what to avoid, and the exact phrases that should show up in the conversation |

### From The Oddsfather

| Deliverable | Description |
|-------------|-------------|
| **Success Probability Verdict** | Percentage likelihood of a successful briefing outcome, plain-language verdict, top 3 risks, and top 3 levers that could shift the outcome |

### Critical Flags

The system surfaces flags that require immediate attention:

| Flag | Meaning |
|------|---------|
| Red / OVERDUE | A commitment or action item has passed its deadline |
| Yellow / OPEN | An unresolved follow-up from a past engagement |
| Green / POSITIVE | Strong relationship signals (high NPS, engagement score, champion trajectory) |
| Blue / OPPORTUNITY | Untapped potential (new stakeholder, unengaged contact, adjacent use case) |

---

## 10. Demo Data Reference

The repository includes simulated data for eight demo scenarios — three serious enterprise contacts and five fun personas with whimsical names but realistic relationship dynamics.

### Contact Scenarios

| Contact | Company | Industry | Tier | Key Tension |
|---------|---------|----------|------|-------------|
| Sarah Chen | Meridian Health | Healthcare | Gold | Overdue AI governance commitment |
| David Park | Apex Financial | Financial Services | Gold | Failed migration, Azure threat, renewal at risk |
| Rachel Morrison | TerraScale Energy | Energy/Utilities | Platinum | P1 outage, champion credibility at stake |
| Pepper Minton | SnackStack Technologies | Food Tech | Gold | Viral TikTok crash, scaling crisis |
| Ziggy Stardust-Chen | Quantum Pretzel Corp | FinTech/Crypto | Silver | SAB alumni, AWS courting, broken promises |
| Luna Wavelength | GalactiCorp Space Industries | Aerospace | Platinum | $8M deal blocked by CISO |
| Max Bandwidth | Thunderbolt Logistics | Supply Chain | Gold | AI champion vs internal politics |
| Sage Cloudberry | WonderPaws Pet Wellness | Veterinary | Standard | First briefing, greenfield opportunity |

### Data Files

**sab-meeting-notes.md** — Q1 2026 and Q4 2025 Strategic Advisory Board meetings with 8 contacts. Sarah led AI Governance, David led Hybrid Cloud, Rachel co-chairs, Pepper/Luna/Max contributed. Includes alumni roster (Ziggy).

**crm-export.json** — Eight account records with 20+ contacts, open opportunities, and support escalations. Ranges from $780M (WonderPaws) to $14.5B (GalactiCorp).

**vvip-roster.json** — Full VVIP profiles for all eight contacts with comprehensive preferences and protocol requirements across all tiers (Platinum, Gold, Silver, Standard).

**engagement-history.md** — Eight complete engagement timelines with relationship stage progression, open items, and flags. Ranges from multi-year champion relationships to first-time briefings.

### Demo Deliverables

The `demo-deliverables/` directory contains 7 sample markdown reference files for the original 3 contacts. Key deliverables for all 8 contacts (3 per contact) are embedded directly in both HTML dashboards as formatted modal content. The markdown files serve as templates for customization.

| Deliverable Type | Agent | All 3 Contacts |
|-----------------|-------|:---:|
| Executive Dossier | Draft Punk | Embedded |
| Briefing Backgrounder | Draft Punk | Embedded |
| Sponsor Talking Points | Draft Punk | Embedded |
| Recommended Agenda | Draft Punk | Embedded |
| Conversation Starters | Draft Punk | Embedded |
| VVIP Protocol Checklist | Alfred Bitworth | Embedded |
| Sponsor Alert Email | Alfred Bitworth | Embedded |
| Engagement Log Entry | Alfred Bitworth | Embedded |

### Customizing demo data

To adapt the demo for a different scenario, edit the files in `demo-data/`. The agents read these files at runtime, so changes take effect immediately (restart the OpenClaw container if it caches workspace files).

Key consistency rules:
- Names and companies must match across all four data files
- SAB meeting dates in `sab-meeting-notes.md` should align with entries in `engagement-history.md`
- VVIP roster entries should reference contacts that exist in `crm-export.json`
- Each contact should have distinct relationship challenges and engagement history
- Overdue action items, open follow-ups, and escalations provide the "dramatic tension"

---

## 11. Conference Day Checklist

### 30 minutes before your session

```bash
./briefingclaw.sh preflight
```

This checks:
- [ ] Podman machine is running
- [ ] Granite 8B model is serving and responsive
- [ ] OpenClaw container is healthy
- [ ] ZeroClaw binary is available
- [ ] API keys are configured and valid
- [ ] Demo data files are in the workspace
- [ ] Gateway UI loads at http://127.0.0.1:18789
- [ ] Wi-Fi is connected (for frontier model agents)
- [ ] Backup video is accessible and tested
- [ ] Dashboard loads: `open briefingclaw-dashboard.html` (or `briefingclaw-dashboard-redhat.html` for Red Hat branding)

### 5 minutes before demo

- [ ] Terminal tabs are arranged (use `./briefingclaw.sh demo`)
- [ ] Browser is open to the gateway UI
- [ ] Dashboard tab open as fallback (briefingclaw-dashboard.html)
- [ ] Font size is large enough for projection
- [ ] Briefing request text is ready to paste
- [ ] Backup video is one click away

### If things go wrong

| Problem | Fallback |
|---------|----------|
| Model is slow | Switch to the dashboard (`briefingclaw-dashboard.html?autostart` or `briefingclaw-dashboard-redhat.html?autostart`) |
| OpenClaw crashes | Use the dashboard for visual demo, ZeroClaw CLI for live research |
| Web search fails | Sherlock and Bloom-borg will note limited results; Deja View and local agents still work |
| Wi-Fi down | Local agents (Deja View, Draft Punk, Alfred Bitworth) still function; skip frontier agents |
| Everything fails | Switch to slides with screenshots of the output |

---

## 12. Troubleshooting

### Common Issues

**"Cannot connect to Podman machine"**
```bash
podman machine start
podman machine info    # Verify status
```

**"Model not responding on port 8001"**
- Open Podman Desktop > AI Lab > Models
- Verify Granite 8B is downloaded and the service is started
- Check with: `curl -s http://127.0.0.1:8001/v1/models`

**"OpenClaw container won't start"**
```bash
cd config
podman-compose logs openclaw    # Check error output
podman-compose down
podman-compose up -d            # Restart
```

**"ZeroClaw profile not found"**
```bash
# Verify config file location
ls ~/.config/zeroclaw/config.toml

# Test profiles
zeroclaw agent -p sherlock-ohms --dry-run
zeroclaw agent -p bloom-borg --dry-run
```

**"Tavily API key invalid"**
- Verify the key in `config/.env`
- Test directly: `curl -s https://api.tavily.com/search -d '{"api_key":"YOUR_KEY","query":"test"}'`

**"Gateway UI shows blank page"**
- Verify the container is running: `podman ps`
- Check the health endpoint: `curl -s http://127.0.0.1:18789/health`
- Inspect container logs: `podman logs <container-id>`

**"Agents return empty or incomplete results"**
- Check that workspace files are mounted: verify volume mounts in `podman-compose.yml`
- Confirm demo data files exist in `~/briefingclaw/workspace/`
- Review agent logs in the OpenClaw gateway for error messages

### System Resource Issues

**High memory usage:**
- Granite 8B uses approximately 6 GB of RAM
- Close unnecessary applications before running the demo
- Monitor with: `top -l 1 | head -15`

**Slow model responses:**
- First request after model startup is slower (cold start)
- Run a warmup request before the demo: `./briefingclaw.sh preflight`
- Apple Silicon Macs will run significantly faster than Intel

---

## 13. Customization

### Using a different frontier model provider

Edit `config/.env` to switch providers. Then update the model references:
- In `config/zeroclaw-config.toml`: change the `[providers.frontier]` section
- In `config/openclaw-config.yml`: change the `model_providers.frontier` section

### Adding new agent skills

1. Create a new directory under `agents/` with a `SKILL.md` file
2. Follow the format of existing skill files (identity, methodology, output format, rules)
3. Register the skill in `config/openclaw-config.yml` under the `skills.active` section
4. Add a volume mount in `config/podman-compose.yml`
5. Rebuild the OpenClaw container

### Modifying VVIP tiers

Edit `demo-data/vvip-roster.json`. The four tiers are:
- **Platinum** — SAB Chair/Co-Chair, board-level executives
- **Gold** — Active SAB members, VP+ at strategic accounts
- **Silver** — SAB alumni, Director+ at growth accounts
- **Standard** — No advisory membership

Each tier maps to a specific protocol level in Alfred Bitworth's checklist generation.

### Adapting for a different use case

The agent architecture is generalizable beyond executive briefings. To adapt:
1. Replace the agent `SKILL.md` files with domain-specific instructions
2. Replace the demo data with your domain's data sources
3. Adjust the orchestrator's dispatch logic for your workflow phases
4. Update the config files to reflect new skill names and triggers

The core pattern — orchestrator dispatching specialist agents with a mix of web research and local data lookup — applies to any multi-source intelligence synthesis task.

---

*For architecture details, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). For the presentation script, see [`docs/DEMO-SCRIPT.md`](docs/DEMO-SCRIPT.md). For build instructions, see [`docs/BUILD-GUIDE.md`](docs/BUILD-GUIDE.md).*
