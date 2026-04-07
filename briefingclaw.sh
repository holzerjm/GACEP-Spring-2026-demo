#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  BriefingClaw — Demo Management Script
#  "You get a task! YOU get a task! EVERYBODY gets a task!"
# ═══════════════════════════════════════════════════════════════════
#
#  Usage:  ./briefingclaw.sh [command]
#
#  If no command is given, shows an interactive menu.
#  Designed so a non-technical presenter can run the demo
#  without remembering any Podman or ZeroClaw commands.
#
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Platform Check ──────────────────────────────────────────────
# This script is tested on macOS (Darwin) with bash 4+ or zsh.
# It uses macOS-specific features:
#   - `open` command (for launching browser and QuickTime)
#   - `osascript` (for opening terminal tabs in the demo command)
#   - ANSI color codes (most modern terminals support these)
# On Linux, `open` falls back to `xdg-open`. Other commands may
# require adaptation.
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Warning: This script is designed for macOS. Some features"
  echo "(terminal tab management, QuickTime recording) may not work"
  echo "on $(uname). Core commands (setup, start, stop, status) should"
  echo "still function if Podman and ZeroClaw are installed."
  echo ""
fi

# ── Colors & Formatting ──────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ── Paths ────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/config/.env"
WORKSPACE_DIR="${HOME}/.openclaw/workspace"
SKILLS_DIR="${HOME}/.openclaw/skills"
ZC_WORKSPACE="${HOME}/.zeroclaw/workspace"
ZC_OUTPUT="${HOME}/.zeroclaw/output"
OUTPUT_DIR="${SCRIPT_DIR}/output"
BACKUP_VIDEO="${SCRIPT_DIR}/demo-backup.mp4"
LOCAL_MODEL_URL="http://127.0.0.1:8001/v1"
OPENCLAW_URL="http://127.0.0.1:18789"
CONTAINER_NAME="briefingclaw-openclaw"

# ── Helpers ──────────────────────────────────────────────────────

banner() {
  echo ""
  echo -e "${CYAN}${BOLD}"
  echo "  ╔══════════════════════════════════════════════════════╗"
  echo "  ║                                                      ║"
  echo "  ║   🎯  B R I E F I N G O P S                         ║"
  echo "  ║       Multi-Agent Executive Intelligence             ║"
  echo "  ║                                                      ║"
  echo "  ║   Oprah-tor · Sherlock Ohms · Bloom-borg             ║"
  echo "  ║   Déjà View · Draft Punk · Alfred Bitworth           ║"
  echo "  ║                                                      ║"
  echo "  ╚══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

info()    { echo -e "  ${BLUE}ℹ${NC}  $1"; }
success() { echo -e "  ${GREEN}✅${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠️${NC}  $1"; }
error()   { echo -e "  ${RED}❌${NC} $1"; }
step()    { echo -e "\n  ${PURPLE}${BOLD}▶${NC} ${BOLD}$1${NC}"; }

check_mark() {
  if $1; then
    echo -e "${GREEN}✅${NC}"
  else
    echo -e "${RED}❌${NC}"
  fi
}

press_enter() {
  echo ""
  echo -e "  ${DIM}Press Enter to continue...${NC}"
  read -r
}

# ── Checks ───────────────────────────────────────────────────────

is_podman_running() {
  podman machine info &>/dev/null 2>&1
}

is_model_serving() {
  curl -s --max-time 3 "${LOCAL_MODEL_URL}/models" &>/dev/null
}

is_openclaw_running() {
  podman ps --filter "name=${CONTAINER_NAME}" --format "{{.Names}}" 2>/dev/null | grep -q "${CONTAINER_NAME}"
}

is_zeroclaw_installed() {
  command -v zeroclaw &>/dev/null
}

has_env_file() {
  [[ -f "${ENV_FILE}" ]]
}

has_frontier_key() {
  if has_env_file; then
    source "${ENV_FILE}"
    [[ -n "${ANTHROPIC_API_KEY:-}" ]] || [[ -n "${OPENAI_API_KEY:-}" ]] || [[ -n "${GOOGLE_API_KEY:-}" ]]
  else
    return 1
  fi
}

has_search_key() {
  if has_env_file; then
    source "${ENV_FILE}"
    [[ -n "${TAVILY_API_KEY:-}" ]]
  else
    return 1
  fi
}

# ══════════════════════════════════════════════════════════════════
#  COMMANDS
# ══════════════════════════════════════════════════════════════════

# ── 1. SETUP ─────────────────────────────────────────────────────
cmd_setup() {
  banner
  step "First-Time Setup"
  echo ""

  # Check prerequisites
  info "Checking prerequisites..."
  echo ""
  echo -e "  Podman Desktop:    $(check_mark "$(command -v podman &>/dev/null && echo true || echo false)")"
  echo -e "  ZeroClaw:          $(check_mark "$(is_zeroclaw_installed && echo true || echo false)")"
  echo -e "  jq:                $(check_mark "$(command -v jq &>/dev/null && echo true || echo false)")"
  echo -e "  curl:              $(check_mark "$(command -v curl &>/dev/null && echo true || echo false)")"
  echo ""

  # Create .env from template if needed
  if ! has_env_file; then
    step "Creating environment file"
    cp "${SCRIPT_DIR}/config/env.example" "${ENV_FILE}"
    info "Created ${ENV_FILE}"
    echo ""
    warn "You need to add your API keys. Opening the file now..."
    echo ""
    echo -e "  ${BOLD}Required keys:${NC}"
    echo -e "    1. ${CYAN}Frontier model${NC} — ONE of: Anthropic, OpenAI, or Google API key"
    echo -e "    2. ${CYAN}Tavily${NC} — Web search key (free at https://tavily.com)"
    echo ""
    echo -e "  ${DIM}The file will open in your default editor.${NC}"
    echo -e "  ${DIM}Fill in the keys, save, and close.${NC}"
    press_enter
    ${EDITOR:-nano} "${ENV_FILE}"
  else
    success "Environment file exists"
  fi

  # Create workspace directories
  step "Setting up workspace directories"
  mkdir -p "${WORKSPACE_DIR}" "${SKILLS_DIR}" "${ZC_WORKSPACE}" \
           "${ZC_OUTPUT}/sherlock-ohms" "${ZC_OUTPUT}/bloom-borg" \
           "${OUTPUT_DIR}" "${HOME}/.zeroclaw"
  success "Directories created"

  # Copy demo data
  step "Copying demo data and skills"
  cp -f "${SCRIPT_DIR}"/demo-data/* "${WORKSPACE_DIR}/"
  cp -f "${SCRIPT_DIR}"/demo-data/* "${ZC_WORKSPACE}/"
  cp -f "${SCRIPT_DIR}"/agents/orchestrator/SKILL.md "${SKILLS_DIR}/orchestrator.md"
  cp -f "${SCRIPT_DIR}"/agents/cab-historian/SKILL.md "${SKILLS_DIR}/cab-historian.md"
  cp -f "${SCRIPT_DIR}"/agents/briefing-architect/SKILL.md "${SKILLS_DIR}/briefing-architect.md"
  cp -f "${SCRIPT_DIR}"/agents/vvip-protocol/SKILL.md "${SKILLS_DIR}/vvip-protocol.md"
  success "Demo data and skill files copied"

  # Copy ZeroClaw config
  step "Installing ZeroClaw configuration"
  cp -f "${SCRIPT_DIR}/config/zeroclaw-config.toml" "${HOME}/.zeroclaw/config.toml"
  success "ZeroClaw config installed"

  # Source env for subsequent commands
  source "${ENV_FILE}" 2>/dev/null || true

  echo ""
  success "Setup complete!"
  echo ""
  echo -e "  ${BOLD}Next steps:${NC}"
  echo -e "    1. Open Podman Desktop → AI Lab → Download Granite 8B"
  echo -e "    2. Start the model server in AI Lab"
  echo -e "    3. Run: ${CYAN}./briefingclaw.sh start${NC}"
  echo ""
}

# ── 2. STATUS ────────────────────────────────────────────────────
cmd_status() {
  banner
  step "System Status"
  echo ""

  # Infrastructure
  echo -e "  ${BOLD}Infrastructure${NC}"
  echo -e "  ├─ Podman Machine:     $(check_mark "$(is_podman_running && echo true || echo false)")"
  echo -e "  ├─ Local Model (8001): $(check_mark "$(is_model_serving && echo true || echo false)")"
  echo -e "  └─ OpenClaw Gateway:   $(check_mark "$(is_openclaw_running && echo true || echo false)")"
  echo ""

  # Configuration
  echo -e "  ${BOLD}Configuration${NC}"
  echo -e "  ├─ Environment file:   $(check_mark "$(has_env_file && echo true || echo false)")"
  echo -e "  ├─ Frontier API key:   $(check_mark "$(has_frontier_key && echo true || echo false)")"
  echo -e "  └─ Search API key:     $(check_mark "$(has_search_key && echo true || echo false)")"
  echo ""

  # Agent Readiness
  echo -e "  ${BOLD}Agent Roster${NC}"
  echo -e "  ├─ 🎯 Oprah-tor        (Orchestrator)      ${DIM}→ Frontier model${NC}"
  echo -e "  ├─ 🔍 Sherlock Ohms    (Exec Research)     ${DIM}→ Frontier model${NC}"
  echo -e "  ├─ 🏢 Bloom-borg       (Account Intel)     ${DIM}→ Frontier model${NC}"
  echo -e "  ├─ 📋 Déjà View        (CAB Historian)     ${DIM}→ Local Granite${NC}"
  echo -e "  ├─ 📄 Draft Punk       (Briefing Architect) ${DIM}→ Local Granite${NC}"
  echo -e "  └─ ⭐ Alfred Bitworth  (VVIP Protocol)     ${DIM}→ Local Granite${NC}"
  echo ""

  # Model routing summary
  echo -e "  ${BOLD}Model Routing${NC}"
  echo -e "  ├─ ${CYAN}Frontier${NC} (cloud):  Orchestration + Research   ${DIM}(power where you need it)${NC}"
  echo -e "  └─ ${GREEN}Local${NC} (on-device): Data + Assembly + Protocol ${DIM}(privacy where it matters)${NC}"
  echo ""

  # ZeroClaw footprint (if installed)
  if is_zeroclaw_installed; then
    echo -e "  ${BOLD}ZeroClaw${NC}"
    zeroclaw --version 2>/dev/null | head -1 | sed 's/^/  /' || echo -e "  ${DIM}Version info unavailable${NC}"
  fi
  echo ""
}

# ── 3. START ─────────────────────────────────────────────────────
cmd_start() {
  banner
  step "Starting BriefingClaw"

  # Load environment
  if has_env_file; then
    source "${ENV_FILE}"
    success "Environment loaded"
  else
    error "No .env file found. Run './briefingclaw.sh setup' first."
    exit 1
  fi

  # Check Podman
  if ! is_podman_running; then
    warn "Podman machine not running. Starting..."
    podman machine start 2>/dev/null || {
      error "Could not start Podman machine."
      error "Open Podman Desktop and start the machine manually."
      exit 1
    }
    success "Podman machine started"
  else
    success "Podman machine running"
  fi

  # Check local model
  if ! is_model_serving; then
    warn "Local model not serving on port 8001."
    echo ""
    echo -e "  ${BOLD}To start the model:${NC}"
    echo -e "    1. Open ${CYAN}Podman Desktop${NC}"
    echo -e "    2. Go to ${CYAN}AI Lab → Models${NC}"
    echo -e "    3. Start ${CYAN}Granite 8B${NC} inference server"
    echo ""
    echo -e "  ${DIM}Waiting for model to become available...${NC}"
    echo -e "  ${DIM}(Press Ctrl+C to skip — demo will use frontier model only)${NC}"
    echo ""

    for i in $(seq 1 60); do
      if is_model_serving; then
        success "Local model is now available!"
        break
      fi
      echo -ne "\r  Waiting... ${i}/60s"
      sleep 1
    done

    if ! is_model_serving; then
      warn "Local model not available. Local agents (Déjà View, Draft Punk, Alfred Bitworth)"
      warn "will fall back to frontier model if configured."
    fi
  else
    success "Local model serving on port 8001"
  fi

  # Start OpenClaw container
  if is_openclaw_running; then
    success "OpenClaw container already running"
  else
    info "Starting OpenClaw container..."
    
    # Build args for environment variables
    ENV_ARGS=""
    [[ -n "${ANTHROPIC_API_KEY:-}" ]]  && ENV_ARGS="${ENV_ARGS} -e ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}"
    [[ -n "${OPENAI_API_KEY:-}" ]]     && ENV_ARGS="${ENV_ARGS} -e OPENAI_API_KEY=${OPENAI_API_KEY}"
    [[ -n "${GOOGLE_API_KEY:-}" ]]     && ENV_ARGS="${ENV_ARGS} -e GOOGLE_API_KEY=${GOOGLE_API_KEY}"
    [[ -n "${TAVILY_API_KEY:-}" ]]     && ENV_ARGS="${ENV_ARGS} -e TAVILY_API_KEY=${TAVILY_API_KEY}"

    podman run -d \
      --name "${CONTAINER_NAME}" \
      -p 18789:18789 \
      -v "${WORKSPACE_DIR}:/app/workspace:ro" \
      -v "${SKILLS_DIR}:/app/skills:ro" \
      -v openclaw-memory:/data/memory \
      -e GATEWAY_ENABLED=true \
      -e GATEWAY_PORT=18789 \
      -e CUSTOM_BASE_URL="http://host.containers.internal:8001/v1" \
      -e CUSTOM_MODEL_ID="granite-8b" \
      -e CUSTOM_API_KEY="not-needed" \
      -e CUSTOM_COMPATIBILITY=openai \
      ${ENV_ARGS} \
      openclaw:briefingclaw 2>/dev/null || {
        # Container might exist but be stopped
        podman start "${CONTAINER_NAME}" 2>/dev/null || {
          error "Failed to start OpenClaw container."
          error "Try: podman rm ${CONTAINER_NAME} && run this again"
          exit 1
        }
      }
    success "OpenClaw container started"
  fi

  # Warm up the model
  step "Warming up models"
  info "Sending test query to local model..."
  curl -s --max-time 10 "${LOCAL_MODEL_URL}/chat/completions" \
    -H "Content-Type: application/json" \
    -d '{"model":"granite-8b","messages":[{"role":"user","content":"Hello"}],"max_tokens":10}' \
    > /dev/null 2>&1 && success "Local model warm" || warn "Local model did not respond (may still be loading)"

  echo ""
  success "BriefingClaw is ready!"
  echo ""
  echo -e "  ${BOLD}Open the dashboard:${NC}"
  echo -e "    ${CYAN}${OPENCLAW_URL}${NC}"
  echo ""
  echo -e "  ${BOLD}Or run the demo:${NC}"
  echo -e "    ${CYAN}./briefingclaw.sh demo${NC}"
  echo ""
}

# ── 4. STOP ──────────────────────────────────────────────────────
cmd_stop() {
  banner
  step "Stopping BriefingClaw"

  if is_openclaw_running; then
    podman stop "${CONTAINER_NAME}" 2>/dev/null
    success "OpenClaw container stopped"
  else
    info "OpenClaw container was not running"
  fi

  echo ""
  info "Note: Podman machine and AI Lab model left running."
  info "To stop everything: Podman Desktop → Stop Machine"
  echo ""
}

# ── 5. DEMO ──────────────────────────────────────────────────────
cmd_demo() {
  banner

  # Load environment
  has_env_file && source "${ENV_FILE}" 2>/dev/null

  step "Pre-Flight Check"
  echo ""

  ALL_GOOD=true
  
  if is_model_serving; then
    success "Local model serving"
  else
    warn "Local model not available — local agents will need fallback"
    ALL_GOOD=false
  fi

  if is_openclaw_running; then
    success "OpenClaw gateway running"
  else
    error "OpenClaw not running — run './briefingclaw.sh start' first"
    ALL_GOOD=false
  fi

  if has_frontier_key; then
    success "Frontier API key configured"
  else
    warn "No frontier API key — research agents will use local model"
  fi

  if has_search_key; then
    success "Search API key configured"
  else
    warn "No search key — research agents can't search the web"
  fi

  if [[ -f "${BACKUP_VIDEO}" ]]; then
    success "Backup video found"
  else
    warn "No backup video — record one with './briefingclaw.sh record'"
  fi

  echo ""

  if [[ "${ALL_GOOD}" == "false" ]]; then
    warn "Some checks failed. Continue anyway?"
    echo -ne "  ${DIM}(y/n): ${NC}"
    read -r yn
    [[ "${yn}" != "y" ]] && exit 0
  fi

  step "Launching Demo Environment"
  echo ""
  echo -e "  Opening three windows for the demo:"
  echo ""
  echo -e "    ${CYAN}1.${NC} Browser → Oprah-tor (OpenClaw Gateway)"
  echo -e "    ${CYAN}2.${NC} Terminal → Sherlock Ohms (Executive Research)"
  echo -e "    ${CYAN}3.${NC} Terminal → Bloom-borg (Account Intelligence)"
  echo ""
  press_enter

  # Open browser
  open "${OPENCLAW_URL}" 2>/dev/null || xdg-open "${OPENCLAW_URL}" 2>/dev/null || {
    info "Open manually: ${OPENCLAW_URL}"
  }

  # Open terminal tabs with agent commands ready
  # macOS Terminal approach:
  if [[ "$(uname)" == "Darwin" ]]; then
    osascript <<EOF 2>/dev/null || true
tell application "Terminal"
  activate
  -- Tab 1: Sherlock Ohms
  do script "echo '🔍 SHERLOCK OHMS — Executive Research (Frontier Model)'; echo ''; echo 'Ready to research. Paste this command when Jan Mark says GO:'; echo ''; echo 'ZEROCLAW_PROFILE=sherlock-ohms zeroclaw agent -m \"Research Sarah Chen, CIO of Meridian Health Systems. Compile: career arc, recent public activity, technology priorities, communication style. Return as structured executive profile.\"'"
  
  -- Tab 2: Bloom-borg
  tell application "System Events" to keystroke "t" using command down
  delay 0.5
  do script "echo '🏢 BLOOM-BORG — Account Intelligence (Frontier Model)'; echo ''; echo 'Ready to analyze. Paste this command when Jan Mark says GO:'; echo ''; echo 'ZEROCLAW_PROFILE=bloom-borg zeroclaw agent -m \"Analyze Meridian Health Systems. Compile: company snapshot, recent news, technology landscape, competitive dynamics, financial highlights. Return as structured company brief.\"'" in front window
end tell
EOF
  fi

  echo ""
  success "Demo environment launched!"
  echo ""
  echo -e "  ${BOLD}Demo Prompt (paste into Oprah-tor):${NC}"
  echo ""
  echo -e "  ${DIM}─────────────────────────────────────────────────────${NC}"
  cat <<'PROMPT'
  I have a briefing tomorrow with Sarah Chen, CIO of Meridian 
  Health Systems. She is a CAB member on our Strategic Technology 
  Advisory Board. Her executive sponsor is Maria Torres, VP 
  Engineering.

  Please prepare a full briefing package:
  1. Research Sarah Chen — recent activity, priorities, style
  2. Research Meridian Health Systems — company context and news
  3. Check our CAB records and past briefing history
  4. Assemble executive dossier, backgrounder, sponsor talking 
     points, and recommended agenda
  5. Run the VVIP protocol check and generate the checklist
PROMPT
  echo -e "  ${DIM}─────────────────────────────────────────────────────${NC}"
  echo ""
  echo -e "  ${BOLD}Money lines to remember:${NC}"
  echo -e "    ${YELLOW}\"The connective tissue between your programs — automated.\"${NC}"
  echo -e "    ${YELLOW}\"Déjà View just saved us from a trust-destroying moment.\"${NC}"
  echo -e "    ${YELLOW}\"It's not the speed. It's that it connected the dots.\"${NC}"
  echo ""
}

# ── 6. SHERLOCK (standalone) ─────────────────────────────────────
cmd_sherlock() {
  local query="${1:-}"
  if [[ -z "${query}" ]]; then
    echo ""
    echo -e "  ${BOLD}🔍 Sherlock Ohms — Executive Research${NC}"
    echo -e "  ${DIM}Uses frontier model for deep person-level intelligence${NC}"
    echo ""
    echo -ne "  Who should I research? (Name, Title, Company): "
    read -r query
  fi

  has_env_file && source "${ENV_FILE}" 2>/dev/null
  echo ""
  info "Sherlock Ohms is researching: ${query}"
  echo ""
  ZEROCLAW_PROFILE=sherlock-ohms zeroclaw agent -m "Research ${query}. Compile: career arc, recent public activity (news, conferences, publications), technology priorities, communication style indicators. Return as structured executive profile per SKILL.md format."
}

# ── 7. BLOOMBORG (standalone) ────────────────────────────────────
cmd_bloomborg() {
  local query="${1:-}"
  if [[ -z "${query}" ]]; then
    echo ""
    echo -e "  ${BOLD}🏢 Bloom-borg — Account Intelligence${NC}"
    echo -e "  ${DIM}Uses frontier model for company-level analysis${NC}"
    echo ""
    echo -ne "  Which company should I analyze? "
    read -r query
  fi

  has_env_file && source "${ENV_FILE}" 2>/dev/null
  echo ""
  info "Bloom-borg is analyzing: ${query}"
  echo ""
  ZEROCLAW_PROFILE=bloom-borg zeroclaw agent -m "Analyze ${query}. Compile: company snapshot (revenue, headcount, industry), recent news and earnings highlights, technology stack signals, competitive dynamics, strategic priorities. Return as structured company brief per SKILL.md format."
}

# ── 8. RECORD backup video ───────────────────────────────────────
cmd_record() {
  banner
  step "Record Backup Video"
  echo ""
  echo -e "  This will guide you through recording the demo as a backup."
  echo ""
  echo -e "  ${BOLD}Before recording:${NC}"
  echo -e "    1. Run ${CYAN}./briefingclaw.sh start${NC} and verify everything works"
  echo -e "    2. Set your terminal font to ${CYAN}18pt+${NC}"
  echo -e "    3. Set browser zoom to ${CYAN}125-150%${NC}"
  echo -e "    4. Close all other apps and notifications"
  echo ""

  if [[ "$(uname)" == "Darwin" ]]; then
    echo -e "  ${BOLD}Ready to record?${NC} QuickTime will open."
    echo -e "  ${DIM}Choose 'New Screen Recording' and hit the red button.${NC}"
    press_enter
    open -a "QuickTime Player" 2>/dev/null || warn "Could not open QuickTime"
    echo ""
    info "After recording, save the file as:"
    echo -e "    ${CYAN}${BACKUP_VIDEO}${NC}"
  else
    echo -e "  ${BOLD}Use your screen recorder of choice.${NC}"
    echo -e "  Save the recording as:"
    echo -e "    ${CYAN}${BACKUP_VIDEO}${NC}"
  fi
  echo ""
}

# ── 9. PREFLIGHT (conference day) ────────────────────────────────
cmd_preflight() {
  banner
  step "Conference Day Pre-Flight Checklist"
  echo ""
  echo -e "  ${BOLD}Run this 30 minutes before your session.${NC}"
  echo ""

  # Run all checks
  echo -e "  ${BOLD}Infrastructure${NC}"
  
  echo -ne "  ├─ Podman machine .......... "
  if is_podman_running; then echo -e "${GREEN}GO${NC}"; else echo -e "${RED}NO-GO${NC} → Open Podman Desktop, start machine"; fi
  
  echo -ne "  ├─ Local model (Granite) ... "
  if is_model_serving; then echo -e "${GREEN}GO${NC}"; else echo -e "${RED}NO-GO${NC} → AI Lab → Models → Start Granite 8B"; fi
  
  echo -ne "  ├─ OpenClaw gateway ........ "
  if is_openclaw_running; then echo -e "${GREEN}GO${NC}"; else echo -e "${RED}NO-GO${NC} → Run: ./briefingclaw.sh start"; fi
  
  echo -ne "  └─ ZeroClaw binary ......... "
  if is_zeroclaw_installed; then echo -e "${GREEN}GO${NC}"; else echo -e "${RED}NO-GO${NC} → Run: brew install zeroclaw"; fi
  
  echo ""
  echo -e "  ${BOLD}API Keys${NC}"
  
  echo -ne "  ├─ Frontier model key ...... "
  if has_frontier_key; then echo -e "${GREEN}GO${NC}"; else echo -e "${YELLOW}WARN${NC} → Research agents will use local model"; fi
  
  echo -ne "  └─ Search key (Tavily) ..... "
  if has_search_key; then echo -e "${GREEN}GO${NC}"; else echo -e "${YELLOW}WARN${NC} → Research agents can't search web"; fi
  
  echo ""
  echo -e "  ${BOLD}Demo Assets${NC}"
  
  echo -ne "  ├─ Demo data in workspace .. "
  if [[ -f "${WORKSPACE_DIR}/cab-meeting-notes.md" ]]; then echo -e "${GREEN}GO${NC}"; else echo -e "${RED}NO-GO${NC} → Run: ./briefingclaw.sh setup"; fi
  
  echo -ne "  ├─ Skill files installed ... "
  if [[ -f "${SKILLS_DIR}/orchestrator.md" ]]; then echo -e "${GREEN}GO${NC}"; else echo -e "${RED}NO-GO${NC} → Run: ./briefingclaw.sh setup"; fi
  
  echo -ne "  └─ Backup video ............ "
  if [[ -f "${BACKUP_VIDEO}" ]]; then echo -e "${GREEN}GO${NC}"; else echo -e "${YELLOW}WARN${NC} → Record with: ./briefingclaw.sh record"; fi

  echo ""
  echo -e "  ${BOLD}Presenter Setup${NC}"
  echo -e "  ├─ [ ] Terminal font size: 18pt+"
  echo -e "  ├─ [ ] Browser zoom: 125-150%"
  echo -e "  ├─ [ ] Do Not Disturb: ON"
  echo -e "  ├─ [ ] Mobile hotspot: tested"
  echo -e "  └─ [ ] Demo prompt: pre-copied to clipboard"
  echo ""

  # Warm up
  step "Warming up models"
  info "Sending test queries..."
  
  if is_model_serving; then
    curl -s --max-time 10 "${LOCAL_MODEL_URL}/chat/completions" \
      -H "Content-Type: application/json" \
      -d '{"model":"granite-8b","messages":[{"role":"user","content":"Summarize the key themes from the last CAB meeting."}],"max_tokens":50}' \
      > /dev/null 2>&1 && success "Local model warm and responsive" || warn "Local model slow — give it another minute"
  fi
  
  echo ""
  echo -e "  ${GREEN}${BOLD}Pre-flight complete. You've got this. 🎤${NC}"
  echo ""
}

# ── 10. HELP ─────────────────────────────────────────────────────
cmd_help() {
  banner
  echo -e "  ${BOLD}Commands:${NC}"
  echo ""
  echo -e "    ${CYAN}setup${NC}       First-time setup — creates config, copies files"
  echo -e "    ${CYAN}start${NC}       Start all services (Podman, OpenClaw, warm models)"
  echo -e "    ${CYAN}stop${NC}        Stop OpenClaw container"
  echo -e "    ${CYAN}status${NC}      Show system status and agent readiness"
  echo -e "    ${CYAN}demo${NC}        Launch the full demo environment (browser + terminals)"
  echo -e "    ${CYAN}preflight${NC}   Conference-day checklist (run 30 min before session)"
  echo -e "    ${CYAN}sherlock${NC}    Run Sherlock Ohms standalone (executive research)"
  echo -e "    ${CYAN}bloomborg${NC}   Run Bloom-borg standalone (account intelligence)"
  echo -e "    ${CYAN}record${NC}      Guide for recording backup demo video"
  echo -e "    ${CYAN}help${NC}        Show this help"
  echo ""
  echo -e "  ${BOLD}Examples:${NC}"
  echo ""
  echo -e "    ${DIM}# First time:${NC}"
  echo -e "    ./briefingclaw.sh setup"
  echo -e "    ./briefingclaw.sh start"
  echo ""
  echo -e "    ${DIM}# Conference day:${NC}"
  echo -e "    ./briefingclaw.sh preflight"
  echo -e "    ./briefingclaw.sh demo"
  echo ""
  echo -e "    ${DIM}# Quick research:${NC}"
  echo -e "    ./briefingclaw.sh sherlock \"Jane Smith, CTO of Acme Corp\""
  echo -e "    ./briefingclaw.sh bloomborg \"Acme Corp\""
  echo ""
}

# ── INTERACTIVE MENU ─────────────────────────────────────────────
cmd_menu() {
  while true; do
    banner
    echo -e "  ${BOLD}What would you like to do?${NC}"
    echo ""
    echo -e "    ${CYAN}1${NC}  🛠️   First-time setup"
    echo -e "    ${CYAN}2${NC}  🚀  Start BriefingClaw"
    echo -e "    ${CYAN}3${NC}  📊  Check status"
    echo -e "    ${CYAN}4${NC}  🎬  Launch demo"
    echo -e "    ${CYAN}5${NC}  ✈️   Pre-flight check (conference day)"
    echo -e "    ${CYAN}6${NC}  🔍  Research a person (Sherlock Ohms)"
    echo -e "    ${CYAN}7${NC}  🏢  Research a company (Bloom-borg)"
    echo -e "    ${CYAN}8${NC}  📹  Record backup video"
    echo -e "    ${CYAN}9${NC}  🛑  Stop BriefingClaw"
    echo -e "    ${CYAN}0${NC}  👋  Exit"
    echo ""
    echo -ne "  Choose (0-9): "
    read -r choice
    echo ""

    case "${choice}" in
      1) cmd_setup;     press_enter ;;
      2) cmd_start;     press_enter ;;
      3) cmd_status;    press_enter ;;
      4) cmd_demo;      press_enter ;;
      5) cmd_preflight; press_enter ;;
      6) cmd_sherlock;  press_enter ;;
      7) cmd_bloomborg; press_enter ;;
      8) cmd_record;    press_enter ;;
      9) cmd_stop;      press_enter ;;
      0) echo -e "  ${DIM}Goodbye! Break a leg at GACEP. 🎤${NC}"; echo ""; exit 0 ;;
      *) warn "Invalid choice. Try 0-9." ;;
    esac
  done
}

# ══════════════════════════════════════════════════════════════════
#  MAIN — Route to command or show menu
# ══════════════════════════════════════════════════════════════════

main() {
  local cmd="${1:-menu}"
  shift 2>/dev/null || true

  case "${cmd}" in
    setup)       cmd_setup "$@" ;;
    start)       cmd_start "$@" ;;
    stop)        cmd_stop "$@" ;;
    status)      cmd_status "$@" ;;
    demo)        cmd_demo "$@" ;;
    preflight)   cmd_preflight "$@" ;;
    sherlock)    cmd_sherlock "$@" ;;
    bloomborg)   cmd_bloomborg "$@" ;;
    record)      cmd_record "$@" ;;
    help|--help) cmd_help "$@" ;;
    menu|"")     cmd_menu ;;
    *)           error "Unknown command: ${cmd}"; cmd_help ;;
  esac
}

main "$@"
