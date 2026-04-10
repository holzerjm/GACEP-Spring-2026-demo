# Changelog

All notable changes to the BriefingClaw project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-04-06

### Added
- Eight-agent multi-agent system for executive briefing preparation
  - Oprah-tor (orchestrator) — request decomposition and synthesis, with 25s hard timeouts and graceful degradation on research agents
  - Sherlock Ohms (executive research) — person-level web intelligence
  - Bloom-borg (account intelligence) — company-level web intelligence
  - Deja View (SAB historian) — cross-program history, engagement tracking, SAB theme trend analysis
  - Draft Punk (briefing architect) — document assembly (dossier, backgrounder, talking points, agenda)
  - Alfred Bitworth (VVIP protocol) — protocol checklists, sponsor alerts, engagement logging
  - Sponsor Coach — readiness assessment micro-agent that scores sponsor preparation and produces a coaching brief
  - The Oddsfather — Phase 3 success probability agent that generates the briefing outcome verdict with top risks and levers
- Dual-model routing: frontier (cloud) for research agents, local Granite 8B for data agents
- Configuration for OpenClaw gateway and ZeroClaw CLI agents
- Podman Compose manifest for container orchestration
- Simulated demo data with eight contact scenarios (3 enterprise + 5 fun personas):
  - Sarah Chen / Meridian Health — overdue commitments, champion trajectory
  - David Park / Apex Financial — retention crisis, Azure threat
  - Rachel Morrison / TerraScale Energy — P1 outage, champion under stress
  - Pepper Minton / SnackStack Technologies — viral TikTok scaling crisis
  - Ziggy Stardust-Chen / Quantum Pretzel Corp — SAB alumni win-back
  - Luna Wavelength / GalactiCorp Space Industries — $8M deal blocked by CISO
  - Max Bandwidth / Thunderbolt Logistics — AI champion vs internal politics
  - Sage Cloudberry / WonderPaws Pet Wellness — first briefing, greenfield
  - SAB meeting notes, CRM (8 accounts, 20+ contacts), VVIP roster, engagement histories
- Key deliverables for all 8 contacts embedded as clickable HTML modal content in dashboards; 7 sample markdown files in demo-deliverables/ for reference
- Interactive CLI wrapper (`briefingclaw.sh`) for demo management
- New `./briefingclaw.sh preview` command — rehearsal mode that opens the dashboards without running any infrastructure checks, ideal for practising narration and timing
- Navigation landing page (`index.html`) with persona gallery and links to all demo pages, dashboards, docs, and the GitHub repository
- Enterprise deployment guide (`docs/ENTERPRISE-DEPLOYMENT.md`) covering the path from laptop prototype to Red Hat OpenShift AI production
- Live demo dashboard (`briefingclaw-dashboard.html`) with improved readability (larger fonts, wider agent spacing):
  - Contact dropdown selector to switch between eight scenarios
  - Unique simulation timeline per contact with distinct narrative arcs
  - Animated agent pipeline with canvas particle effects
  - Real-time activity feed, deliverable tracking, critical flag alerts
  - Risk badges on completed deliverable cards (red = critical, amber = warning, green = positive)
  - PDF export button that produces a printable briefing package for the selected persona
  - Key deliverables for all 8 contacts clickable with embedded HTML modal content
  - Improved three-state mode detection: LIVE (full stack), LOCAL ONLY (Granite reachable but OpenClaw down), SIMULATED (no services)
  - Telemetry logging of all session events to localStorage; press **T** to download the JSON log
  - GitHub repository link in the footer
  - Persistent logging of run history across sessions
- Red Hat branded dashboard (`briefingclaw-dashboard-redhat.html`): identical functionality (risk badges, PDF export, LIVE/LOCAL ONLY/SIMULATED, telemetry, GitHub footer link) with Red Hat Display/Text/Mono fonts, PatternFly dark theme, Red Hat Red (#EE0000) accent
- Interactive HTML architecture visualization (`briefingclaw-architecture.html`)
- Complete documentation: architecture guide, build guide, demo script, user guide, enterprise deployment guide
- Initial release for GACEP Spring 2026 Conference

### Changed
- Renamed "Customer Advisory Board" to "Strategic Advisory Board" (CAB → SAB) across all content, skill files, demo data, dashboards, and documentation
- Agent directory rename: `agents/cab-historian/` → `agents/sab-historian/`
- Demo data rename: `demo-data/cab-meeting-notes.md` → `demo-data/sab-meeting-notes.md`
- Deja View now performs SAB theme trend analysis across the last four board meetings
- Oprah-tor now enforces a 25-second hard timeout on research agents (Sherlock Ohms and Bloom-borg) with graceful degradation when a frontier call stalls or the network is flaky
