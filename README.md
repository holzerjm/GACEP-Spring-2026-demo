# BriefingClaw — Multi-Agent Executive Briefing Intelligence

> *"The connective tissue between your programs — automated."*

BriefingClaw is a multi-agent AI system that automates executive briefing preparation. Six specialized agents orchestrate in parallel to transform a single briefing request into a complete intelligence package — executive dossier, company brief, sponsor talking points, recommended agenda, VVIP protocol checklist, and engagement log — in approximately 90 seconds.

Built for the **GACEP Spring 2026 Conference** session: *"One Customer, Many Doors: Aligning EBC, Advisory & Executive Programs for Maximum Impact"*

**Presenters**: Jan Mark Holzer (Red Hat CTO Office) & Kristin Waitkus

---

## Table of Contents

- [Why BriefingClaw](#why-briefingclaw)
- [Architecture Overview](#architecture-overview)
- [The Six Agents](#the-six-agents)
- [Execution Flow](#execution-flow)
- [Model Routing](#model-routing)
- [Technology Stack](#technology-stack)
- [Repository Structure](#repository-structure)
- [Demo Scenario](#demo-scenario)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Session Context](#session-context)

---

## Why BriefingClaw

Executive briefing preparation typically requires 4-6 hours of manual work per visitor: researching the executive, analyzing the company, reviewing past engagement history across disconnected systems (CRM, CAB records, EBC logs, ESP tracking), assembling documents, and coordinating VVIP protocol. Information silos between programs mean critical context gets lost — overdue commitments, unmet promises, relationship history.

BriefingClaw demonstrates that agentic AI can:

- **Collapse that 4-6 hour workflow into ~90 seconds**
- **Connect the dots across programs** that humans routinely miss (the "connective tissue")
- **Surface risk signals** like overdue action items before they become trust-destroying moments
- **Run entirely on a laptop** with no data leaving the device for sensitive operations

The system is not just about speed — it is about cross-program awareness that no single human consistently achieves across Executive Briefing Centers (EBC), Customer Advisory Boards (CAB), and Executive Sponsorship Programs (ESP).

---

## Architecture Overview

BriefingClaw uses a hub-and-spoke multi-agent architecture. A central orchestrator decomposes requests and dispatches work to five specialized agents across three execution phases.

> **Interactive diagram:** Open [`briefingclaw-architecture.html`](briefingclaw-architecture.html) in a browser for a detailed, interactive visualization of the architecture, execution flow, and infrastructure stack.

![BriefingClaw Multi-Agent Architecture](docs/images/architecture-diagram.png)

```
                          +-----------------+
                          |   Briefing      |
                          |   Request       |
                          +--------+--------+
                                   |
                          Phase 0: Trigger
                                   |
                          +--------v--------+
                          |   Oprah-tor     |
                          |  (Orchestrator) |
                          +--------+--------+
                                   |
                 Phase 1: Intelligence Gathering (parallel)
                    /              |              \
          +--------v---+   +------v------+   +----v--------+
          | Sherlock    |   | Bloom-borg  |   | Deja View   |
          | Ohms        |   | (Account    |   | (CAB        |
          | (Executive  |   |  Intel)     |   |  Historian) |
          |  Research)  |   +------+------+   +----+--------+
          +--------+---+          |                |
                    \             |               /
                     +------------+-------------+
                                  |
                 Phase 2: Assembly (parallel)
                        /                  \
              +--------v--------+   +-------v--------+
              |  Draft Punk     |   | Alfred Bitworth |
              |  (Briefing      |   | (VVIP Protocol) |
              |   Architect)    |   +-------+--------+
              +--------+--------+           |
                        \                  /
                         +--------+-------+
                                  |
                         Phase 3: Synthesis
                                  |
                          +-------v--------+
                          |   Complete     |
                          |   Briefing     |
                          |   Package      |
                          +----------------+
```

---

## The Six Agents

| # | Agent | Codename | Role | Model | Framework |
|---|-------|----------|------|-------|-----------|
| 1 | Orchestrator | **Oprah-tor** | Decomposes requests, dispatches agents, validates outputs, synthesizes final package | Frontier (cloud) | OpenClaw Gateway |
| 2 | Executive Research | **Sherlock Ohms** | Deep person-level intelligence: career arc, recent activity, communication style, tech priorities | Frontier (cloud) | ZeroClaw CLI |
| 3 | Account Intelligence | **Bloom-borg** | Company-level intelligence: financials, tech stack, competitive landscape, strategic priorities | Frontier (cloud) | ZeroClaw CLI |
| 4 | CAB Historian | **Deja View** | Cross-program memory: CAB membership, past briefings, engagement stage, open follow-ups | Local (Granite 8B) | OpenClaw Skill |
| 5 | Briefing Architect | **Draft Punk** | Document assembly: dossier, backgrounder, talking points, agenda, conversation starters | Local (Granite 8B) | OpenClaw Skill |
| 6 | VVIP Protocol | **Alfred Bitworth** | Operational protocol: VVIP tier, checklist, sponsor alerts, scheduling, engagement logging | Local (Granite 8B) | OpenClaw Skill |

### Agent Details

**Oprah-tor (Orchestrator)** — The air traffic controller. Parses incoming briefing requests, extracts key entities (visitor name, company, date, sponsor), dispatches work to the five specialist agents in the correct phase order, validates that returned data meets quality thresholds, and synthesizes the final deliverable package.

**Sherlock Ohms (Executive Research)** — Performs deep web research on the visiting executive. Produces a profile covering career arc, recent public activity (last 6 months prioritized), technology priorities, communication style indicators, and personalized conversation starters. Every claim is sourced and confidence-rated.

**Bloom-borg (Account Intelligence)** — Researches the visitor's company. Delivers a structured brief covering business overview, financial highlights, recent news (last 90 days), technology landscape (derived from job postings and announcements), competitive dynamics, and strategic opportunities with briefing relevance.

**Deja View (CAB Historian)** — The "connective tissue" agent and the critical differentiator. Reads from internal program data (CAB meeting notes, CRM records, engagement history, VVIP roster) to build a cross-program relationship view. Identifies CAB membership, past briefing outcomes, overdue commitments, open follow-ups, and relationship stage progression. This agent catches what humans miss.

**Draft Punk (Briefing Architect)** — Synthesizes intelligence from all agents into five polished deliverables: (1) Executive Dossier (1-page quick reference), (2) Briefing Backgrounder (2-page comprehensive prep), (3) Sponsor Talking Points (for executive sponsor drop-in), (4) Recommended Agenda (time-blocked with rationales), (5) Conversation Starters (3 personalized openers).

**Alfred Bitworth (VVIP Protocol)** — Handles the operational layer. Determines VVIP tier (Platinum/Gold/Silver/Standard), generates a protocol checklist with assignees and deadlines, drafts a sponsor alert email, performs scheduling conflict checks, and creates an engagement log entry for future reference.

---

## Execution Flow

**Input example:**
```
I have a briefing tomorrow with Sarah Chen, CIO of Meridian Health Systems.
She is a CAB member. Her sponsor is Maria Torres.
```

**Phase 0 — Trigger:** Request enters the OpenClaw Gateway (port 18789).

**Phase 1 — Intelligence Gathering (parallel):**
- Sherlock Ohms researches Sarah Chen via web (frontier model + Tavily search)
- Bloom-borg researches Meridian Health Systems via web (frontier model + Tavily search)
- Deja View queries internal data files for CAB records, past briefings, CRM data, VVIP status (local Granite model)

**Phase 2 — Assembly (parallel):**
- Draft Punk synthesizes all Phase 1 outputs into five documents (local Granite model)
- Alfred Bitworth generates protocol checklist and sponsor alert (local Granite model)

**Phase 3 — Synthesis:**
- Oprah-tor validates all outputs and assembles the final briefing package

**Output:** Complete briefing package with 8 deliverables plus critical flags:
- Executive Dossier
- Briefing Backgrounder
- Sponsor Talking Points
- Recommended Agenda
- Conversation Starters
- VVIP Protocol Checklist
- Sponsor Alert Draft
- Engagement Log Entry

---

## Model Routing

BriefingClaw uses a dual-model strategy that balances capability with data privacy:

| Tier | Model | Agents | Rationale |
|------|-------|--------|-----------|
| **Frontier (cloud)** | Claude / GPT / Gemini (configurable) | Oprah-tor, Sherlock Ohms, Bloom-borg | Complex reasoning, web search, multi-step research |
| **Local (on-device)** | IBM Granite 8B (via Podman AI Lab) | Deja View, Draft Punk, Alfred Bitworth | Private data never leaves the laptop; structured tasks that fit a smaller model |

This split ensures that sensitive customer data (CAB records, CRM exports, VVIP preferences, engagement history) is processed exclusively by the local model. The frontier model only handles publicly available information gathered via web search.

---

## Technology Stack

| Component | Technology | Role |
|-----------|-----------|------|
| Local Model | IBM Granite 8B | Open-source LLM served locally via Podman AI Lab |
| Agent Framework (container) | OpenClaw | Gateway + skill-based agents (Oprah-tor, Deja View, Draft Punk, Alfred Bitworth) |
| Agent Framework (native) | ZeroClaw | Lightweight CLI agents (Sherlock Ohms, Bloom-borg) — ~3.4 MB binary |
| Containers | Podman | Rootless, daemonless container engine (Docker-compatible) |
| Web Search | Tavily API | Real-time web research for frontier agents |
| Enterprise Path | Red Hat OpenShift AI | Production-scale deployment (referenced, not required for demo) |

**Key properties:**
- **Fully open source** — every component from model to runtime
- **Laptop-portable** — runs on a MacBook Pro with 16 GB RAM
- **Air-gap capable** — local agents work without internet
- **No data exfiltration** — sensitive data processed only by the on-device model

---

## Repository Structure

```
gacep-demo/
|
+-- briefingclaw.sh                         Interactive CLI for demo management
+-- briefingclaw-dashboard.html            Live demo dashboard (original dark theme)
+-- briefingclaw-dashboard-redhat.html     Live demo dashboard (Red Hat branded edition)
+-- briefingclaw-architecture.html          Visual architecture diagram (HTML)
+-- README.md                              This file
|
+-- agents/                                Agent skill definitions
|   +-- orchestrator/SKILL.md              Oprah-tor: request decomposition & synthesis
|   +-- executive-research/SKILL.md        Sherlock Ohms: person-level web research
|   +-- account-intelligence/SKILL.md      Bloom-borg: company-level web research
|   +-- cab-historian/SKILL.md             Deja View: cross-program history lookup
|   +-- briefing-architect/SKILL.md        Draft Punk: document assembly
|   +-- vvip-protocol/SKILL.md             Alfred Bitworth: protocol & notifications
|
+-- config/                                Infrastructure configuration
|   +-- env.example                        API key template (copy to .env)
|   +-- openclaw-config.yml                OpenClaw gateway & skill routing
|   +-- zeroclaw-config.toml               ZeroClaw agent profiles
|   +-- podman-compose.yml                 Container orchestration manifest
|
+-- demo-data/                             Simulated data for three contact scenarios
|   +-- cab-meeting-notes.md               CAB meeting records (Q1 2026, Q4 2025, 3 contacts)
|   +-- crm-export.json                    CRM records (3 accounts, 9 contacts)
|   +-- vvip-roster.json                   VVIP tiers & full preferences (3 contacts)
|   +-- engagement-history.md              Engagement timelines (3 complete narratives)
|
+-- demo-deliverables/                     Pre-generated sample deliverables
|   +-- sarah-chen/                        Executive dossier, agenda, VVIP checklist
|   +-- david-park/                        Executive dossier, agenda
|   +-- rachel-morrison/                   Executive dossier, agenda
|
+-- docs/                                  Extended documentation
    +-- ARCHITECTURE.md                    System design document
    +-- BUILD-GUIDE.md                     Step-by-step setup instructions
    +-- DEMO-SCRIPT.md                     Beat-by-beat presentation script
```

### Key Files Explained

**`briefingclaw.sh`** — Interactive CLI wrapper for the entire demo lifecycle. Provides commands for setup, infrastructure startup, demo environment configuration, system health checks, preflight validation, standalone agent runs, and backup video recording. Designed so a non-technical presenter can operate the system.

**`briefingclaw-dashboard.html`** — Live demo dashboard with animated pipeline visualization (original dark theme). Features a contact dropdown selector (Sarah Chen, David Park, Rachel Morrison) with unique simulation timelines for each scenario. Shows all six agents working through the briefing preparation flow with particle animations, real-time activity feed, deliverable tracking, and critical flag alerts. Completed deliverables are clickable, opening a formatted modal viewer with sample content. Polls live infrastructure when services are running, falls back to a polished animated simulation. Open in a browser and click "Start Demo", or append `?autostart` to the URL. Keyboard shortcuts: Space/Enter to start, Escape to reset, F for fullscreen.

**`briefingclaw-dashboard-redhat.html`** — Red Hat branded edition of the demo dashboard. Identical functionality to the original, reskinned with official Red Hat design language: Red Hat Display, Red Hat Text, and Red Hat Mono fonts; PatternFly dark theme surfaces (#151515/#1F1F1F/#292929); Red Hat Red (#EE0000) as the primary accent; PatternFly blue for frontier agents; PatternFly teal for local agents. Use this version for Red Hat-affiliated presentations.

**`briefingclaw-architecture.html`** — Standalone HTML page with an interactive visualization of the multi-agent execution flow. Shows the three-phase pipeline, model routing decisions, and infrastructure stack. Useful as a visual aid during presentations.

**`config/env.example`** — Template for API keys. Supports multiple frontier providers (Anthropic, OpenAI, Google) and the Tavily web search API. The local Granite model requires no API key. Copy to `.env` and fill in your keys.

**`config/openclaw-config.yml`** — Configures the OpenClaw gateway: which skills to load, model routing overrides (frontier vs. local per agent), workspace file mounts, external agent invocation (ZeroClaw subprocesses), and tool permissions.

**`config/zeroclaw-config.toml`** — Configures ZeroClaw agent profiles for Sherlock Ohms and Bloom-borg: model provider, skill file path, iteration limits, and web search parameters.

**`config/podman-compose.yml`** — Container manifest for the OpenClaw service. Mounts agent skill files and demo data as read-only volumes, exposes the gateway on port 18789, and connects to the Granite model served by Podman AI Lab on port 8001.

---

## Demo Scenarios

The system includes three distinct demo scenarios, each showcasing different relationship challenges and cross-program intelligence patterns:

| Scenario | Contact | Company | Tier | Challenge | Key Drama |
|----------|---------|---------|------|-----------|-----------|
| **Overdue Commitments** | Sarah Chen, CIO | Meridian Health Systems | Gold | AI governance architecture overdue from Feb CAB | Trust-critical miss before briefing |
| **Retention Crisis** | David Park, SVP Technology | Apex Financial Group | Gold | Failed migration, Azure pitching, 3-month renewal | Account at risk of competitive displacement |
| **Champion Under Stress** | Rachel Morrison, CTO | TerraScale Energy | Platinum | P1 outage damaged trust, board presentation in 30 days | Highest-value relationship under threat |

Each scenario demonstrates that the system connects dots across CAB records, EBC history, CRM data, support escalations, and VVIP protocol that no single person would consistently assemble. The dashboard includes a contact dropdown to switch between scenarios during a live demo.

---

## Quick Start

> Full step-by-step instructions: [`docs/BUILD-GUIDE.md`](docs/BUILD-GUIDE.md)

### Prerequisites
- macOS with Homebrew
- 16 GB RAM minimum, 30 GB free disk
- API key for at least one frontier provider (Anthropic, OpenAI, or Google)
- Tavily API key for web search

### Steps

```bash
# 1. Install dependencies
brew install podman podman-compose jq

# 2. Install Podman Desktop + AI Lab extension, download Granite 8B

# 3. Install ZeroClaw
curl -fsSL https://install.zeroclaw.dev | sh

# 4. Clone and configure
cp config/env.example config/.env
# Edit config/.env with your API keys

# 5. Start infrastructure
./briefingclaw.sh start

# 6. Run the demo
./briefingclaw.sh demo
# Or open http://127.0.0.1:18789 and type your briefing request
```

Alternatively, use the automated setup:
```bash
./briefingclaw.sh setup    # First-time configuration wizard
./briefingclaw.sh start    # Launch all infrastructure
./briefingclaw.sh demo     # Set up the demo environment
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Multi-agent system design, agent roster, execution flow, infrastructure stack |
| [`docs/BUILD-GUIDE.md`](docs/BUILD-GUIDE.md) | Complete setup instructions from prerequisites through conference-day checklist |
| [`docs/DEMO-SCRIPT.md`](docs/DEMO-SCRIPT.md) | Beat-by-beat presentation script with timing, narrative cues, and contingency plans |
| [`USER-GUIDE.md`](USER-GUIDE.md) | Practical guide for operating BriefingClaw: installation, configuration, running demos, troubleshooting |

---

## Session Context

This system was designed for the **GACEP Spring 2026 Conference** session demonstrating how agentic AI can operationalize the "Program of Programs" framework — connecting Executive Briefing Centers, Customer Advisory Boards, and Executive Sponsorship Programs through automated intelligence and cross-program awareness.

The demo shows that the tooling to build this kind of multi-agent system exists today, runs on commodity hardware, and uses entirely open-source components. The path from laptop prototype to enterprise deployment runs through Red Hat OpenShift AI.

---

*Built with open source. Runs on your laptop. No data leaves the building.*
