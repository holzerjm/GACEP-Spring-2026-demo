# BriefingClaw: Multi-Agent Executive Engagement Intelligence System

## Architecture Overview

BriefingClaw is a multi-agent system built on OpenClaw and ZeroClaw that automates executive briefing preparation by orchestrating eight specialized agents. Each agent handles a distinct domain of the briefing preparation workflow, coordinated by a central Orchestrator.

```
                    ┌─────────────────────────────┐
                    │     BRIEFING REQUEST         │
                    │  (Slack / CLI / CRM Trigger) │
                    └──────────────┬──────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │     🎯 OPRAH-TOR             │
                    │     Orchestrator              │
                    │  Task decomposition &         │
                    │  result synthesis             │
                    │  25s timeout + degradation    │
                    │  ☁️  FRONTIER MODEL            │
                    └──┬───┬───┬───┬───┬──────────┘
                       │   │   │   │   │
          ┌────────────┘   │   │   │   └────────────┐
          │                │   │   │                 │
    ┌─────▼─────┐   ┌─────▼───▼─────┐   ┌──────────▼──────────┐
    │ 🔍 SHERLOCK│   │ 🏢 BLOOM-BORG │   │ 📋 DÉJÀ VIEW        │
    │ OHMS       │   │               │   │                     │
    │ Exec       │   │ Account       │   │ SAB Historian        │
    │ Research   │   │ Intelligence  │   │ + Theme Trend        │
    │ ☁️ FRONTIER │   │ ☁️ FRONTIER    │   │ 💻 LOCAL MODEL       │
    └─────┬─────┘   └──────┬────────┘   └──────────┬──────────┘
          │                │                        │
          └────────┬───────┘────────────────────────┘
                   │
           Phase 2: Assembly (parallel)
         /         │          \
  ┌──────▼───┐ ┌───▼──────┐ ┌──▼──────────┐
  │ 📄 DRAFT │ │ ⭐ ALFRED │ │ 🎤 SPONSOR  │
  │ PUNK     │ │ BITWORTH │ │ COACH       │
  │ Briefing │ │ VVIP     │ │ Readiness   │
  │ Architect│ │ Protocol │ │ Assessment  │
  │ 💻 LOCAL │ │ 💻 LOCAL │ │ 💻 LOCAL    │
  └──────┬───┘ └───┬──────┘ └──┬──────────┘
         │         │            │
         └─────────┼────────────┘
                   │
         Phase 3: Synthesis
                   │
          ┌────────▼────────┐
          │ 🎲 THE          │
          │ ODDSFATHER       │
          │ Success          │
          │ Probability      │
          │ 💻 LOCAL MODEL   │
          └────────┬────────┘
                   │
          ┌────────▼────────┐
          │  FINAL BRIEFING  │
          │  PACKAGE         │
          └─────────────────┘
```

## Agent Roster

| Agent | Codename | Role | Model | Framework | Runs On |
|-------|----------|------|-------|-----------|---------|
| Orchestrator | **Oprah-tor** | Decomposes briefing requests, dispatches tasks to specialists, enforces 25s hard timeouts on research agents with graceful degradation, synthesizes final package | ☁️ Frontier (Claude/GPT/Gemini) | OpenClaw (Gateway) | Podman container |
| Executive Research | **Sherlock Ohms** | Deep research on visiting executive: career, news, social, conference appearances | ☁️ Frontier (Claude/GPT/Gemini) | ZeroClaw (CLI) | Native binary |
| Account Intelligence | **Bloom-borg** | Company-level intelligence: financials, news, tech stack, competitive landscape | ☁️ Frontier (Claude/GPT/Gemini) | ZeroClaw (CLI) | Native binary |
| SAB Historian | **Déjà View** | Cross-references SAB membership, retrieves past themes, flags relationship history, analyses SAB theme trends across the last four board meetings | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |
| Briefing Architect | **Draft Punk** | Assembles all intelligence into formatted deliverables: dossier, talking points, agenda | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |
| VVIP Protocol | **Alfred Bitworth** | Checks VVIP status, generates protocol checklist, drafts sponsor notifications | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |
| Sponsor Coach | **Sponsor Coach** | Scores executive sponsor readiness, produces a coaching brief with review items and talking-point drills | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |
| Success Prediction | **The Oddsfather** | Phase 3 synthesis: generates briefing success probability verdict with top risks and top levers | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |

## Execution Flow

### Phase 1: Intake & Decomposition (Oprah-tor)
```
INPUT: "Briefing tomorrow with Sarah Chen, CIO of Meridian Health Systems.
        SAB member. Executive Sponsor: VP Engineering Maria Torres."

ACE decomposes into parallel tasks:
  → SHERLOCK OHMS: Research Sarah Chen (person-level) ☁️ Frontier
  → BLOOM-BORG: Research Meridian Health Systems (company-level) ☁️ Frontier
  → DÉJÀ VIEW: Check SAB membership, pull last 2 SAB meeting themes 💻 Local
```

### Phase 2: Intelligence Gathering (Sherlock Ohms + Bloom-borg + Déjà View — parallel)
```
SHERLOCK OHMS returns (via frontier model):
  - Executive dossier (career arc, recent news, conference appearances)
  - Communication style indicators
  - Known technology priorities

BLOOM-BORG returns (via frontier model):
  - Company snapshot (revenue, headcount, industry position)
  - Recent earnings/news highlights
  - Technology stack signals
  - Competitive dynamics

DÉJÀ VIEW returns (via local Granite model):
  - SAB membership confirmed (since Q2 2024)
  - Last SAB themes: "AI governance," "hybrid cloud migration timeline"
  - Previous briefing: March 2025, topics: OpenShift migration, security posture
  - Relationship stage: "Trusted" (ITSMA scale)
```

### Phase 3: Package Assembly (Draft Punk + Alfred Bitworth + Sponsor Coach — parallel, local model)
```
DRAFT PUNK receives all intelligence and generates:
  1. Executive Dossier (1-page PDF)
  2. Briefing Backgrounder (2-page summary)
  3. Sponsor Talking Points (for Maria Torres's coffee drop-in)
  4. Recommended Agenda (based on SAB themes + company priorities)
  5. Conversation Starters (personalized ice-breakers)

ALFRED BITWORTH checks VVIP status and:
  1. Generates VVIP Protocol Checklist (premier boardroom, CEO drop-in, etc.)
  2. Drafts Sponsor Alert email to Maria Torres
  3. Flags any scheduling conflicts with other engagement programs
  4. Logs the briefing in the engagement tracker

SPONSOR COACH runs in parallel and returns:
  1. Sponsor readiness score (0-100)
  2. Coaching brief: what to review, what to avoid
  3. Specific phrases for the sponsor drop-in
  4. Coaching gaps flagged for the program team
```

### Phase 4: Success Probability Verdict (The Oddsfather — local model)
```
THE ODDSFATHER reviews the full assembled package and returns:
  1. Success probability percentage + plain-language verdict
  2. Top 3 risks that could derail the briefing
  3. Top 3 levers that could shift the outcome
  4. Confidence in the prediction given the engagement signals
```

### Phase 5: Synthesis & Delivery (Oprah-tor)
```
OPRAH-TOR assembles the complete briefing package:
  - Validates all outputs for consistency
  - Creates the final deliverable bundle
  - Posts summary to Slack/Teams channel
  - Stores package in workspace for retrieval
  - Applied 25s hard timeouts to Phase 2 research agents with graceful degradation
    if the frontier network is flaky (downgrades to partial intelligence flagged as such)
```

## Infrastructure Stack

```
┌─────────────────────────────────────────────────────┐
│                    MacBook Pro                       │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │           Podman Desktop                     │    │
│  │                                              │    │
│  │  ┌──────────────────┐  ┌──────────────────┐ │    │
│  │  │  Podman AI Lab   │  │  OpenClaw         │ │    │
│  │  │  ─────────────   │  │  Container        │ │    │
│  │  │  Granite 8B      │  │  ─────────────    │ │    │
│  │  │  (llama.cpp)     │  │  Oprah-tor   ☁️   │ │    │
│  │  │                  │  │  Déjà View   💻   │ │    │
│  │  │  Port: 8001      │  │  Draft Punk  💻   │ │    │
│  │  │  💻 LOCAL MODEL  │  │  Alfred      💻   │ │    │
│  │  │                  │  │  Sponsor C.  💻   │ │    │
│  │  │                  │  │  Oddsfather  💻   │ │    │
│  │  └──────────────────┘  └──────────────────┘ │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │  Native Binaries                             │    │
│  │  ┌──────────────────┐  ┌──────────────────┐ │    │
│  │  │  ZeroClaw         │  │  ZeroClaw        │ │    │
│  │  │  "Sherlock Ohms"  │  │  "Bloom-borg"    │ │    │
│  │  │  3.4 MB   ☁️     │  │  3.4 MB   ☁️    │ │    │
│  │  └──────────────────┘  └──────────────────┘ │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ☁️ = Frontier model (Anthropic / OpenAI / Gemini)  │
│  💻 = Local Granite via Podman AI Lab               │
│                                                     │
│  Research data → cloud (public web info)             │
│  Customer data → NEVER leaves the laptop             │
└─────────────────────────────────────────────────────┘
```

## File Structure

```
briefingclaw/
├── index.html                         # Navigation landing page with persona gallery
├── briefingclaw-dashboard.html        # Live demo dashboard (8 scenarios, embedded deliverables, improved readability)
├── briefingclaw-dashboard-redhat.html # Red Hat branded variant (identical functionality)
├── briefingclaw-architecture.html     # Static architecture diagram
├── briefingclaw.sh                    # Interactive CLI for demo management
├── agents/
│   ├── orchestrator/          # Oprah-tor — the coordinator
│   │   └── SKILL.md
│   ├── executive-research/    # Sherlock Ohms — person-level research
│   │   └── SKILL.md
│   ├── account-intelligence/  # Bloom-borg — company-level intel
│   │   └── SKILL.md
│   ├── sab-historian/         # Déjà View — program cross-reference + theme trend analysis
│   │   └── SKILL.md
│   ├── briefing-architect/    # Draft Punk — document assembly
│   │   └── SKILL.md
│   ├── vvip-protocol/         # Alfred Bitworth — protocol & notifications
│   │   └── SKILL.md
│   ├── sponsor-coach/         # Sponsor Coach — readiness assessment micro-agent
│   │   └── SKILL.md
│   └── oddsfather/            # The Oddsfather — Phase 3 success probability
│       └── SKILL.md
├── config/
│   ├── podman-compose.yml     # Container orchestration
│   ├── openclaw-config.yml    # OpenClaw gateway config
│   └── zeroclaw-config.toml   # ZeroClaw native config
├── demo-data/                     # 8 accounts, 8 contacts, cross-program data
│   ├── sab-meeting-notes.md   # Strategic Advisory Board meetings (Q1 2026, Q4 2025, 8 contacts)
│   ├── crm-export.json        # CRM data (8 accounts, 20+ contacts)
│   ├── vvip-roster.json       # VVIP tiers & preferences (8 profiles)
│   └── engagement-history.md  # Engagement timelines (8 narratives)
├── demo-deliverables/             # Sample markdown reference files (7 files)
│   ├── sarah-chen/            # Key deliverables for all 8 contacts
│   ├── david-park/            # are embedded in the HTML dashboards;
│   └── rachel-morrison/       # these markdowns are for reference only
└── docs/
    ├── ARCHITECTURE.md        # This file
    ├── DEMO-SCRIPT.md         # Step-by-step demo script
    ├── BUILD-GUIDE.md         # How to build & configure
    └── ENTERPRISE-DEPLOYMENT.md # Scaling to Red Hat OpenShift AI
```
