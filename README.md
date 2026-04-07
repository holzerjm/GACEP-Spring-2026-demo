# BriefingOps — Multi-Agent Executive Briefing Intelligence

> *"The connective tissue between your programs — automated."*

BriefingOps is a multi-agent AI system that automates executive briefing preparation. Six specialized agents orchestrate in parallel to transform a single briefing request into a complete intelligence package — executive dossier, company brief, sponsor talking points, recommended agenda, VVIP protocol checklist, and engagement log — in approximately 90 seconds.

Built for the **GACEP Spring 2026 Conference** session: *"One Customer, Many Doors: Aligning EBC, Advisory & Executive Programs for Maximum Impact"*

**Presenters**: Jan Mark Holzer (Red Hat CTO Office) & Kristin Waitkus

---

## Table of Contents

- [Why BriefingOps](#why-briefingops)
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

## Why BriefingOps

Executive briefing preparation typically requires 4-6 hours of manual work per visitor: researching the executive, analyzing the company, reviewing past engagement history across disconnected systems (CRM, CAB records, EBC logs, ESP tracking), assembling documents, and coordinating VVIP protocol. Information silos between programs mean critical context gets lost — overdue commitments, unmet promises, relationship history.

BriefingOps demonstrates that agentic AI can:

- **Collapse that 4-6 hour workflow into ~90 seconds**
- **Connect the dots across programs** that humans routinely miss (the "connective tissue")
- **Surface risk signals** like overdue action items before they become trust-destroying moments
- **Run entirely on a laptop** with no data leaving the device for sensitive operations

The system is not just about speed — it is about cross-program awareness that no single human consistently achieves across Executive Briefing Centers (EBC), Customer Advisory Boards (CAB), and Executive Sponsorship Programs (ESP).

---

## Architecture Overview

BriefingOps uses a hub-and-spoke multi-agent architecture. A central orchestrator decomposes requests and dispatches work to five specialized agents across three execution phases.

> **Interactive diagram:** Open [`briefingops-architecture.html`](briefingops-architecture.html) in a browser for a detailed, interactive visualization of the architecture, execution flow, and infrastructure stack.

![BriefingOps Multi-Agent Architecture](docs/images/architecture-diagram.png)

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

BriefingOps uses a dual-model strategy that balances capability with data privacy:

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
+-- briefingops.sh                         Interactive CLI for demo management
+-- briefingops-architecture.html          Visual architecture diagram (HTML)
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
+-- demo-data/                             Simulated data for the demo scenario
|   +-- cab-meeting-notes.md               CAB meeting records (Q1 2026, Q4 2025)
|   +-- crm-export.json                    CRM account & contact records
|   +-- vvip-roster.json                   VVIP tier assignments & preferences
|   +-- engagement-history.md              Past briefing & engagement timeline
|
+-- docs/                                  Extended documentation
    +-- ARCHITECTURE.md                    System design document
    +-- BUILD-GUIDE.md                     Step-by-step setup instructions
    +-- DEMO-SCRIPT.md                     Beat-by-beat presentation script
```

### Key Files Explained

**`briefingops.sh`** — Interactive CLI wrapper for the entire demo lifecycle. Provides commands for setup, infrastructure startup, demo environment configuration, system health checks, preflight validation, standalone agent runs, and backup video recording. Designed so a non-technical presenter can operate the system.

**`briefingops-architecture.html`** — Standalone HTML page with an interactive visualization of the multi-agent execution flow. Shows the three-phase pipeline, model routing decisions, and infrastructure stack. Useful as a visual aid during presentations.

**`config/env.example`** — Template for API keys. Supports multiple frontier providers (Anthropic, OpenAI, Google) and the Tavily web search API. The local Granite model requires no API key. Copy to `.env` and fill in your keys.

**`config/openclaw-config.yml`** — Configures the OpenClaw gateway: which skills to load, model routing overrides (frontier vs. local per agent), workspace file mounts, external agent invocation (ZeroClaw subprocesses), and tool permissions.

**`config/zeroclaw-config.toml`** — Configures ZeroClaw agent profiles for Sherlock Ohms and Bloom-borg: model provider, skill file path, iteration limits, and web search parameters.

**`config/podman-compose.yml`** — Container manifest for the OpenClaw service. Mounts agent skill files and demo data as read-only volumes, exposes the gateway on port 18789, and connects to the Granite model served by Podman AI Lab on port 8001.

---

## Demo Scenario

The built-in demo scenario centers on a briefing request for **Sarah Chen**, CIO of **Meridian Health Systems**, with executive sponsor **Maria Torres** (VP Engineering).

The demo data is crafted to showcase the system's cross-program intelligence capabilities:

- **Sarah is a Gold-tier VVIP** and active CAB member who led the AI Governance discussion at the most recent board meeting
- **An action item from that CAB meeting is overdue** (AI governance reference architecture, due March 1) — Deja View catches this before anyone walks into the room
- **An open follow-up from a past briefing is still unresolved** (healthcare customer reference connection, promised September 2025)
- **A new stakeholder opportunity exists** — Dr. Priya Kapoor (CMIO) has not yet been engaged despite clinical AI use case potential
- **Sarah's relationship stage is "Trusted, approaching Champion"** with an NPS score of 9/10 from her last briefing

This scenario demonstrates the core value proposition: it is not the speed that matters — it is that the system connected dots across CAB records, EBC history, CRM data, and VVIP protocol that no single person would have assembled.

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
./briefingops.sh start

# 6. Run the demo
./briefingops.sh demo
# Or open http://127.0.0.1:18789 and type your briefing request
```

Alternatively, use the automated setup:
```bash
./briefingops.sh setup    # First-time configuration wizard
./briefingops.sh start    # Launch all infrastructure
./briefingops.sh demo     # Set up the demo environment
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Multi-agent system design, agent roster, execution flow, infrastructure stack |
| [`docs/BUILD-GUIDE.md`](docs/BUILD-GUIDE.md) | Complete setup instructions from prerequisites through conference-day checklist |
| [`docs/DEMO-SCRIPT.md`](docs/DEMO-SCRIPT.md) | Beat-by-beat presentation script with timing, narrative cues, and contingency plans |
| [`USER-GUIDE.md`](USER-GUIDE.md) | Practical guide for operating BriefingOps: installation, configuration, running demos, troubleshooting |

---

## Session Context

This system was designed for the **GACEP Spring 2026 Conference** session demonstrating how agentic AI can operationalize the "Program of Programs" framework — connecting Executive Briefing Centers, Customer Advisory Boards, and Executive Sponsorship Programs through automated intelligence and cross-program awareness.

The demo shows that the tooling to build this kind of multi-agent system exists today, runs on commodity hardware, and uses entirely open-source components. The path from laptop prototype to enterprise deployment runs through Red Hat OpenShift AI.

---

*Built with open source. Runs on your laptop. No data leaves the building.*
