# Changelog

All notable changes to the BriefingClaw project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-04-06

### Added
- Six-agent multi-agent system for executive briefing preparation
  - Oprah-tor (orchestrator) — request decomposition and synthesis
  - Sherlock Ohms (executive research) — person-level web intelligence
  - Bloom-borg (account intelligence) — company-level web intelligence
  - Deja View (CAB historian) — cross-program history and engagement tracking
  - Draft Punk (briefing architect) — document assembly (dossier, backgrounder, talking points, agenda)
  - Alfred Bitworth (VVIP protocol) — protocol checklists, sponsor alerts, engagement logging
- Dual-model routing: frontier (cloud) for research agents, local Granite 8B for data agents
- Configuration for OpenClaw gateway and ZeroClaw CLI agents
- Podman Compose manifest for container orchestration
- Simulated demo data with three complete contact scenarios:
  - Sarah Chen / Meridian Health (Healthcare, Gold tier, overdue commitments)
  - David Park / Apex Financial (Financial Services, Gold tier, retention crisis + Azure threat)
  - Rachel Morrison / TerraScale Energy (Energy, Platinum tier, P1 outage + champion stress)
  - CAB meeting notes with all three contacts across Q1 2026 and Q4 2025
  - CRM export with 3 accounts, 9 contacts, opportunities, and support escalations
  - VVIP roster with comprehensive preferences and protocol requirements
  - Engagement history with complete cross-program timelines per account
- Pre-generated sample deliverables (7 files): executive dossiers, recommended agendas, VVIP checklist
- Interactive CLI wrapper (`briefingclaw.sh`) for demo management
- Live demo dashboard (`briefingclaw-dashboard.html`) with:
  - Contact dropdown selector to switch between three scenarios
  - Unique simulation timeline per contact with distinct narrative arcs
  - Animated agent pipeline with canvas particle effects
  - Real-time activity feed, deliverable tracking (0/8 to 8/8), critical flag alerts
  - Clickable completed deliverables opening a formatted modal viewer
  - Infrastructure polling with automatic live/simulated mode detection
- Interactive HTML architecture visualization (`briefingclaw-architecture.html`)
- Complete documentation: architecture guide, build guide, demo script, user guide
- Initial release for GACEP Spring 2026 Conference
