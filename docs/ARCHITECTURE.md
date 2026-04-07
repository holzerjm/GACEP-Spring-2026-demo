# BriefingClaw: Multi-Agent Executive Engagement Intelligence System

## Architecture Overview

BriefingClaw is a multi-agent system built on OpenClaw and ZeroClaw that automates executive briefing preparation by orchestrating six specialized agents. Each agent handles a distinct domain of the briefing preparation workflow, coordinated by a central Orchestrator.

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
                    │  ☁️  FRONTIER MODEL            │
                    └──┬───┬───┬───┬───┬──────────┘
                       │   │   │   │   │
          ┌────────────┘   │   │   │   └────────────┐
          │                │   │   │                 │
    ┌─────▼─────┐   ┌─────▼───▼─────┐   ┌──────────▼──────────┐
    │ 🔍 SHERLOCK│   │ 🏢 BLOOM-BORG │   │ 📋 DÉJÀ VIEW        │
    │ OHMS       │   │               │   │                     │
    │ Exec       │   │ Account       │   │ CAB Historian        │
    │ Research   │   │ Intelligence  │   │ 💻 LOCAL MODEL       │
    │ ☁️ FRONTIER │   │ ☁️ FRONTIER    │   └──────────┬──────────┘
    └─────┬─────┘   └──────┬────────┘              │
          │                │                        │
          └────────┬───────┘────────────────────────┘
                   │
          ┌────────▼────────┐
          │ 📄 DRAFT PUNK   │
          │ Briefing         │
          │ Architect        │
          │ 💻 LOCAL MODEL   │
          └────────┬────────┘
                   │
          ┌────────▼────────┐
          │ ⭐ ALFRED       │
          │ BITWORTH        │
          │ VVIP Protocol    │
          │ 💻 LOCAL MODEL   │
          └─────────────────┘
```

## Agent Roster

| Agent | Codename | Role | Model | Framework | Runs On |
|-------|----------|------|-------|-----------|---------|
| Orchestrator | **Oprah-tor** | Decomposes briefing requests, dispatches tasks to specialists, synthesizes final package | ☁️ Frontier (Claude/GPT/Gemini) | OpenClaw (Gateway) | Podman container |
| Executive Research | **Sherlock Ohms** | Deep research on visiting executive: career, news, social, conference appearances | ☁️ Frontier (Claude/GPT/Gemini) | ZeroClaw (CLI) | Native binary |
| Account Intelligence | **Bloom-borg** | Company-level intelligence: financials, news, tech stack, competitive landscape | ☁️ Frontier (Claude/GPT/Gemini) | ZeroClaw (CLI) | Native binary |
| CAB Historian | **Déjà View** | Cross-references CAB membership, retrieves past themes, flags relationship history | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |
| Briefing Architect | **Draft Punk** | Assembles all intelligence into formatted deliverables: dossier, talking points, agenda | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |
| VVIP Protocol | **Alfred Bitworth** | Checks VVIP status, generates protocol checklist, drafts sponsor notifications | 💻 Local (Granite 8B) | OpenClaw (Skill) | Podman container |

## Execution Flow

### Phase 1: Intake & Decomposition (Oprah-tor)
```
INPUT: "Briefing tomorrow with Sarah Chen, CIO of Meridian Health Systems.
        CAB member. Executive Sponsor: VP Engineering Maria Torres."

ACE decomposes into parallel tasks:
  → SHERLOCK OHMS: Research Sarah Chen (person-level) ☁️ Frontier
  → BLOOM-BORG: Research Meridian Health Systems (company-level) ☁️ Frontier
  → DÉJÀ VIEW: Check CAB membership, pull last 2 CAB meeting themes 💻 Local
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
  - CAB membership confirmed (since Q2 2024)
  - Last CAB themes: "AI governance," "hybrid cloud migration timeline"
  - Previous briefing: March 2025, topics: OpenShift migration, security posture
  - Relationship stage: "Trusted" (ITSMA scale)
```

### Phase 3: Package Assembly (Draft Punk — local model)
```
DRAFT PUNK receives all intelligence and generates:
  1. Executive Dossier (1-page PDF)
  2. Briefing Backgrounder (2-page summary)
  3. Sponsor Talking Points (for Maria Torres's coffee drop-in)
  4. Recommended Agenda (based on CAB themes + company priorities)
  5. Conversation Starters (personalized ice-breakers)
```

### Phase 4: Protocol & Notifications (Alfred Bitworth — local model)
```
ALFRED BITWORTH checks VVIP status and:
  1. Generates VVIP Protocol Checklist (premier boardroom, CEO drop-in, etc.)
  2. Drafts Sponsor Alert email to Maria Torres
  3. Flags any scheduling conflicts with other engagement programs
  4. Logs the briefing in the engagement tracker
```

### Phase 5: Synthesis & Delivery (Oprah-tor)
```
ACE assembles the complete briefing package:
  - Validates all outputs for consistency
  - Creates the final deliverable bundle
  - Posts summary to Slack/Teams channel
  - Stores package in workspace for retrieval
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
│  │  │  Podman AI Lab   │  │  OpenClaw        │ │    │
│  │  │  ─────────────   │  │  Container       │ │    │
│  │  │  Granite 8B      │  │  ─────────────   │ │    │
│  │  │  (llama.cpp)     │  │  Oprah-tor  ☁️   │ │    │
│  │  │                  │  │  Déjà View  💻   │ │    │
│  │  │  Port: 8001      │  │  Draft Punk 💻   │ │    │
│  │  │  💻 LOCAL MODEL  │  │  Alfred     💻   │ │    │
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
├── briefingclaw-dashboard.html        # Live demo dashboard (3 scenarios, 24 deliverables, improved readability)
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
│   ├── cab-historian/         # Déjà View — program cross-reference
│   │   └── SKILL.md
│   ├── briefing-architect/    # Draft Punk — document assembly
│   │   └── SKILL.md
│   └── vvip-protocol/        # Alfred Bitworth — protocol & notifications
│       └── SKILL.md
├── config/
│   ├── podman-compose.yml     # Container orchestration
│   ├── openclaw-config.yml    # OpenClaw gateway config
│   └── zeroclaw-config.toml   # ZeroClaw native config
├── demo-data/                     # 3 accounts, 3 contacts, cross-program data
│   ├── cab-meeting-notes.md   # CAB meetings (Q1 2026, Q4 2025, 3 contacts)
│   ├── crm-export.json        # CRM data (3 accounts, 9 contacts)
│   ├── vvip-roster.json       # VVIP tiers & preferences (3 profiles)
│   └── engagement-history.md  # Engagement timelines (3 narratives)
├── demo-deliverables/             # Sample markdown reference files (7 files)
│   ├── sarah-chen/            # All 24 deliverables (8 types x 3 contacts)
│   ├── david-park/            # are embedded in the HTML dashboards;
│   └── rachel-morrison/       # these markdowns are for reference only
└── docs/
    ├── ARCHITECTURE.md        # This file
    ├── DEMO-SCRIPT.md         # Step-by-step demo script
    └── BUILD-GUIDE.md         # How to build & configure
```
