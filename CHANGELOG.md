# Changelog

All notable changes to the BriefingClaw project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-04-29

### Added
- **TankOS variant** — repackages BriefingClaw as a Fedora bootc appliance running rootless OpenClaw, built on the upstream [LobsterTrap/tank-os](https://github.com/LobsterTrap/tank-os) image. Same eight agents, same Sarah Chen scenario, different runtime story.
  - **`briefingclaw-tankos-architecture.html`** — re-themed architecture diagram with four colour-coded providers (Anthropic blue, Gemini violet, Qwen 3 green, Gemma 4 orange) and a three-column infrastructure footer (TankOS Host / OpenClaw Gateway / Model Catalog).
  - **`briefingclaw-tankos-dashboard.html`** — live demo dashboard with per-agent model badges, Ramalama-aware infrastructure rows, and a 38-second simulated Sarah Chen timeline. Activity-feed messages call out SecretRef resolution, rootless Quadlet behaviour, and `host.containers.internal:8001` traffic. URL parameters `local_url`, `openclaw_url`, `servicegator_url` swap endpoints; mode badge auto-flips `SIMULATED → PARTIAL → LIVE`.
  - **`briefingclaw-tankos.sh`** — twelve-subcommand operational launcher: `image`, `disk`, `tunnel`, `secrets`, `provision`, `models`, `dashboard`, `preview`, `status`, `logs`, `upgrade`, `help`. Auto-detects the gvproxy-forwarded SSH port for Podman Desktop / macadam VMs.
  - **`tankos/quadlets/`** — three rootless Podman Quadlets: `openclaw.container` (gateway), `service-gator.container` (scoped MCP for GitHub / JIRA), and `local-models.container` (optional in-VM Ramalama serving Qwen 3 + Gemma 4). Plus a reference `10-secrets.conf` drop-in showing what `tank-openclaw-secrets` writes.
  - **`tankos/config/openclaw.json`** — full provider catalog with per-agent overrides. SecretRefs resolve from environment variables populated by Podman secrets — no key material in any file under git.
  - **`tankos/config/service-gator-scopes.json`** — read-only GitHub scope file for the demo (`LobsterTrap/tank-os`, `holzerjm/GACEP-Spring-2026-demo`).
  - **`tankos/agents/AGENTS.md`** — per-agent model routing rationale, including the rationale for splitting local work between Qwen 3 (reasoning + retrieval) and Gemma 4 (structured generation).
  - **`tankos/scripts/bootstrap-secrets.sh`** — runs inside the VM as `openclaw` to create Podman secrets and call `tank-openclaw-secrets`. Reads keys from environment or stdin; never writes them to disk.
  - **`tankos/scripts/serve-local-models.sh`** — host-side script that serves Qwen 3 30B-A3B + Gemma 4 26B-A4B via Ramalama on `:8001` (OpenAI-compatible).
  - **`docs/TANKOS-BUILD.md`** — build / day-2 ops guide. Covers the bootable-appliance, rootless-services, secrets-out-of-image, and per-agent-model-routing patterns.
- Per-agent model routing across **two frontier providers** and **two on-device models**: Anthropic Claude (Oprah-tor, Sherlock Ohms) + Google Gemini (Bloom-borg) + local Qwen 3 (Déjà View, Alfred Bitworth, The Oddsfather) + local Gemma 4 (Draft Punk, Sponsor Coach).
- Navigation updates: `index.html` now links the TankOS dashboard, TankOS architecture diagram, and TankOS build guide; `briefingclaw-docs.html` adds a sidebar entry for the TankOS build guide.

### Changed
- README — added a TankOS Variant section to the table of contents and main body, expanded the repository structure tree, updated key-files-explained section, and added TANKOS-BUILD.md + AGENTS.md to the documentation table.

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

### Later in 1.0.0
- **`briefingclaw-multicontact.html`** — multi-contact group briefing mode. Pick 2-5 contacts from 9 total across 3 companies (Meridian, Apex, TerraScale). Outputs shared company context, buying center role matrix (economic / champion / technical / blocker / influencer), cross-contact dynamics (alignments / tensions / conflicts), recommended briefing order (blocker first, champion last), unified agenda, coordination risks, and The Oddsfather's group verdict with coordination adjustments.
- **`briefingclaw-personas.html`** — standalone filterable persona gallery. Card view of all 8 personas with tier and type filters, rich stat cards, color-coded drama callouts, top-3 priorities, and action buttons (Run Demo / Open Dossier). Designed as a warm-up or reference page before the main demo.
- **`briefingclaw-postbriefing.html`** — post-briefing feedback loop with Oddsfather calibration and `localStorage` persistence. Form for logging briefing outcomes (contact, NPS 0-10, commitments, actual outcome, relationship stage signal, debrief notes). Live analysis panel shows Oddsfather predicted-vs-actual with drift classification, Deja View stage update preview, and recent submission history. Submissions persist to browser `localStorage` under the `briefingclaw-feedback` key (capped at 50 entries).
- **Architecture HTML fix** — `briefingclaw-architecture.html` now correctly shows Sponsor Coach in **Phase 3** (three-column assembly alongside Draft Punk and Alfred Bitworth) and **The Oddsfather** in a new **Phase 4** for success probability synthesis, matching the documented execution flow.
