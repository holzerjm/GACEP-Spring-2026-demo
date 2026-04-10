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
- Simulated demo data with eight contact scenarios (3 enterprise + 5 fun personas):
  - Sarah Chen / Meridian Health — overdue commitments, champion trajectory
  - David Park / Apex Financial — retention crisis, Azure threat
  - Rachel Morrison / TerraScale Energy — P1 outage, champion under stress
  - Pepper Minton / SnackStack Technologies — viral TikTok scaling crisis
  - Ziggy Stardust-Chen / Quantum Pretzel Corp — CAB alumni win-back
  - Luna Wavelength / GalactiCorp Space Industries — $8M deal blocked by CISO
  - Max Bandwidth / Thunderbolt Logistics — AI champion vs internal politics
  - Sage Cloudberry / WonderPaws Pet Wellness — first briefing, greenfield
  - CAB meeting notes, CRM (8 accounts, 20+ contacts), VVIP roster, engagement histories
- Key deliverables for all 8 contacts embedded as clickable HTML modal content in dashboards; 7 sample markdown files in demo-deliverables/ for reference
- Interactive CLI wrapper (`briefingclaw.sh`) for demo management
- Live demo dashboard (`briefingclaw-dashboard.html`) with improved readability (larger fonts, wider agent spacing):
  - Contact dropdown selector to switch between eight scenarios
  - Unique simulation timeline per contact with distinct narrative arcs
  - Animated agent pipeline with canvas particle effects
  - Real-time activity feed, deliverable tracking (0/8 to 8/8), critical flag alerts
  - Key deliverables for all 8 contacts clickable with embedded HTML modal content
  - Infrastructure polling with automatic live/simulated mode detection
- Red Hat branded dashboard (`briefingclaw-dashboard-redhat.html`): identical functionality with Red Hat Display/Text/Mono fonts, PatternFly dark theme, Red Hat Red (#EE0000) accent
- Interactive HTML architecture visualization (`briefingclaw-architecture.html`)
- Complete documentation: architecture guide, build guide, demo script, user guide
- Initial release for GACEP Spring 2026 Conference
