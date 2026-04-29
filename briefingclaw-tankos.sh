#!/usr/bin/env bash
# briefingclaw-tankos.sh — Operate the BriefingClaw demo on a TankOS VM.
#
# Mirrors the original briefingclaw.sh subcommand surface but targets
# the TankOS appliance flow:
#   - bootc image build / pull
#   - QCOW2 disk via Podman Desktop BootC extension
#   - SSH tunnel for the OpenClaw gateway (:18789) and bridge (:18790)
#   - Podman secret creation + tank-openclaw-secrets sync (over SSH)
#   - Local model server (Qwen 3 + Gemma 4) on the host
#   - Open the dashboard in SIMULATED, PARTIAL, or LIVE mode
#
# This script does not bake any keys into images. All key material flows
# through Podman secrets owned by the `openclaw` user inside the VM.

set -euo pipefail

# ─── Defaults ───────────────────────────────────────────────────────
TANKOS_IMAGE="${TANKOS_IMAGE:-quay.io/sallyom/tank-os:latest}"
SSH_USER="${SSH_USER:-openclaw}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519}"
GATEWAY_PORT="${GATEWAY_PORT:-18789}"
BRIDGE_PORT="${BRIDGE_PORT:-18790}"
MCP_PORT="${MCP_PORT:-8080}"
LOCAL_MODEL_PORT="${LOCAL_MODEL_PORT:-8001}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

C_RESET='\033[0m'; C_DIM='\033[2m'; C_TEAL='\033[38;5;43m'
C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'; C_BOLD='\033[1m'

banner() {
  printf "${C_TEAL}${C_BOLD}"
  cat <<'EOF'
  ┌─────────────────────────────────────────────────────┐
  │  BriefingClaw on TankOS                             │
  │  Fedora bootc · OpenClaw rootless · Qwen 3 + Gemma  │
  └─────────────────────────────────────────────────────┘
EOF
  printf "${C_RESET}"
}

# ─── SSH discovery — find the local Podman Desktop / macadam port ───
find_ssh_port() {
  local port
  port="$(
    ps aux 2>/dev/null \
      | grep -E 'gvproxy|macadam' \
      | grep -E 'bootc.*tank|tank.*bootc' \
      | sed -nE 's/.*-ssh-port ([0-9]+).*/\1/p' \
      | tail -1
  )"
  if [[ -z "$port" ]]; then
    return 1
  fi
  printf '%s' "$port"
}

resolve_ssh_target() {
  if [[ -n "${SSH_PORT:-}" ]]; then
    SSH_HOST="${SSH_HOST:-localhost}"
    return 0
  fi
  if [[ -n "${SSH_HOST:-}" ]]; then
    SSH_PORT="${SSH_PORT:-22}"
    return 0
  fi
  if SSH_PORT="$(find_ssh_port)"; then
    SSH_HOST="${SSH_HOST:-localhost}"
    echo -e "  ${C_DIM}Detected forwarded SSH port from gvproxy: ${SSH_PORT}${C_RESET}"
    return 0
  fi
  echo -e "  ${C_YELLOW}Could not auto-detect SSH port. Set SSH_HOST and/or SSH_PORT.${C_RESET}" >&2
  return 1
}

ssh_vm() {
  ssh -o ConnectTimeout=5 \
      -o ExitOnForwardFailure=yes \
      -i "$SSH_KEY" \
      -p "$SSH_PORT" \
      "$SSH_USER@$SSH_HOST" \
      "$@"
}

# ─── Subcommands ────────────────────────────────────────────────────

cmd_help() {
  banner
  printf "\nSubcommands:\n"
  printf "  ${C_BOLD}%-9s${C_RESET}  %s\n" \
    status    "Health-check TankOS VM (bootc, OpenClaw, Quadlets, models)" \
    image     "Pull or build the TankOS bootc container image" \
    disk      "Walk through QCOW2 disk image creation" \
    provision "Copy demo data + skill files into the VM (~/.openclaw)" \
    secrets   "Create Podman secrets in the VM and run tank-openclaw-secrets" \
    tunnel    "Open SSH tunnel to gateway/bridge/MCP ports" \
    models    "Serve Qwen 3 + Gemma 4 locally on the host (:${LOCAL_MODEL_PORT})" \
    dashboard "Open the live demo dashboard in your browser" \
    preview   "Open the dashboard in pure SIMULATED mode (no infra)" \
    upgrade   "bootc switch to the latest TankOS image and reboot the VM" \
    logs      "Tail the OpenClaw service logs over SSH" \
    help      "Show this help"

  cat <<EOF

Environment overrides:
  TANKOS_IMAGE     OCI ref for the bootc image (default: ${TANKOS_IMAGE})
  SSH_HOST         Hostname or IP of the running VM (auto-detected for Podman Desktop)
  SSH_PORT         Forwarded SSH port (auto-detected for Podman Desktop)
  SSH_USER         Login user inside the VM (default: ${SSH_USER})
  SSH_KEY          Private key file (default: ${SSH_KEY})
  GATEWAY_PORT     OpenClaw gateway port (default: ${GATEWAY_PORT})
  BRIDGE_PORT      OpenClaw bridge port (default: ${BRIDGE_PORT})
  LOCAL_MODEL_PORT Local Qwen/Gemma server port (default: ${LOCAL_MODEL_PORT})

Examples:
  ./briefingclaw-tankos.sh image
  ./briefingclaw-tankos.sh tunnel              # in one terminal
  ./briefingclaw-tankos.sh secrets             # in another (one-time)
  ./briefingclaw-tankos.sh models              # in another (background)
  ./briefingclaw-tankos.sh dashboard           # open browser
EOF
}

cmd_status() {
  banner
  echo -e "${C_BOLD}TankOS image${C_RESET}"
  if podman image inspect "$TANKOS_IMAGE" >/dev/null 2>&1; then
    echo -e "  ${C_GREEN}✔${C_RESET} present locally: $TANKOS_IMAGE"
  else
    echo -e "  ${C_YELLOW}—${C_RESET} not pulled yet (run: ./briefingclaw-tankos.sh image)"
  fi

  echo -e "\n${C_BOLD}VM SSH${C_RESET}"
  if resolve_ssh_target 2>/dev/null; then
    if ssh_vm 'true' >/dev/null 2>&1; then
      echo -e "  ${C_GREEN}✔${C_RESET} ssh ${SSH_USER}@${SSH_HOST}:${SSH_PORT} reachable"
      echo -e "\n${C_BOLD}Inside the VM${C_RESET}"
      ssh_vm 'echo "  bootc:    $(sudo bootc status --format json 2>/dev/null | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get(\"status\",{}).get(\"booted\",{}).get(\"image\",{}).get(\"image\",\"unknown\"))" 2>/dev/null)"
              echo "  openclaw: $(systemctl --user is-active openclaw.service 2>/dev/null)"
              echo "  service-gator: $(systemctl --user is-active service-gator.service 2>/dev/null)"
              echo "  podman secrets: $(podman secret ls --format "{{.Name}}" | tr "\n" " ")"' \
        2>/dev/null || echo -e "  ${C_YELLOW}—${C_RESET} could not query VM state"
    else
      echo -e "  ${C_RED}✘${C_RESET} ssh failed"
    fi
  fi

  echo -e "\n${C_BOLD}Local model server${C_RESET}"
  if curl -fsS -m 1 "http://127.0.0.1:${LOCAL_MODEL_PORT}/v1/models" >/dev/null 2>&1; then
    echo -e "  ${C_GREEN}✔${C_RESET} serving on :${LOCAL_MODEL_PORT}"
  else
    echo -e "  ${C_YELLOW}—${C_RESET} not running (run: ./briefingclaw-tankos.sh models)"
  fi

  echo -e "\n${C_BOLD}OpenClaw gateway (via tunnel)${C_RESET}"
  if curl -fsS -m 1 "http://127.0.0.1:${GATEWAY_PORT}/health" >/dev/null 2>&1; then
    echo -e "  ${C_GREEN}✔${C_RESET} :${GATEWAY_PORT} reachable on host loopback"
  else
    echo -e "  ${C_YELLOW}—${C_RESET} not reachable (run: ./briefingclaw-tankos.sh tunnel)"
  fi
}

cmd_image() {
  banner
  echo "Pulling $TANKOS_IMAGE ..."
  podman pull "$TANKOS_IMAGE"
  echo -e "${C_GREEN}done.${C_RESET}"
  echo
  echo "To build the disk image, follow:  ./briefingclaw-tankos.sh disk"
}

cmd_disk() {
  banner
  cat <<EOF
Build a QCOW2 disk image with the Podman Desktop BootC extension:

  1. Open Podman Desktop → BootC extension → Build disk image.
  2. Image source:        ${TANKOS_IMAGE}  (or localhost/tank-os:latest)
  3. Disk image type:     qcow2
  4. Target architecture: arm64 (Apple Silicon) or amd64
  5. Root filesystem:     xfs
  6. User:                ${SSH_USER}
  7. SSH public key:      $(cat "${SSH_KEY}.pub" 2>/dev/null || echo '<your public key>')
  8. Groups:              wheel
  9. Output folder:       ~/out-tank-os/

Then start the VM from Podman Desktop. After it boots:
  ./briefingclaw-tankos.sh tunnel
  ./briefingclaw-tankos.sh secrets
  ./briefingclaw-tankos.sh provision
EOF
}

cmd_tunnel() {
  banner
  resolve_ssh_target
  echo "Opening tunnel on ${SSH_HOST}:${SSH_PORT}"
  echo "  -L ${GATEWAY_PORT}:127.0.0.1:${GATEWAY_PORT}    (OpenClaw control UI + chat completions)"
  echo "  -L ${BRIDGE_PORT}:127.0.0.1:${BRIDGE_PORT}    (OpenClaw agent bridge)"
  echo "  -L ${MCP_PORT}:127.0.0.1:${MCP_PORT}        (service-gator MCP)"
  echo "Press Ctrl-C to close."
  exec ssh -N \
       -o ConnectTimeout=5 \
       -o ExitOnForwardFailure=yes \
       -i "$SSH_KEY" \
       -p "$SSH_PORT" \
       -L "${GATEWAY_PORT}:127.0.0.1:${GATEWAY_PORT}" \
       -L "${BRIDGE_PORT}:127.0.0.1:${BRIDGE_PORT}" \
       -L "${MCP_PORT}:127.0.0.1:${MCP_PORT}" \
       "${SSH_USER}@${SSH_HOST}"
}

cmd_provision() {
  banner
  resolve_ssh_target
  echo "Copying demo data + agent skills into the VM..."

  # demo-data → /var/home/openclaw/briefingclaw/demo-data
  ssh_vm 'mkdir -p ~/briefingclaw/demo-data ~/briefingclaw/agents'
  scp -i "$SSH_KEY" -P "$SSH_PORT" -r \
      "$SCRIPT_DIR/demo-data/." \
      "${SSH_USER}@${SSH_HOST}:briefingclaw/demo-data/"
  scp -i "$SSH_KEY" -P "$SSH_PORT" -r \
      "$SCRIPT_DIR/agents/." \
      "${SSH_USER}@${SSH_HOST}:briefingclaw/agents/"

  # The TankOS AGENTS.md routing reference
  scp -i "$SSH_KEY" -P "$SSH_PORT" \
      "$SCRIPT_DIR/tankos/agents/AGENTS.md" \
      "${SSH_USER}@${SSH_HOST}:.openclaw/skills/AGENTS.md"

  # The provider catalog
  scp -i "$SSH_KEY" -P "$SSH_PORT" \
      "$SCRIPT_DIR/tankos/config/openclaw.json" \
      "${SSH_USER}@${SSH_HOST}:.openclaw/openclaw.json.tankos-template"

  echo -e "${C_GREEN}done.${C_RESET}"
  echo "Run './briefingclaw-tankos.sh secrets' to wire SecretRefs into ~/.openclaw/openclaw.json."
}

cmd_secrets() {
  banner
  resolve_ssh_target
  echo "This will prompt for API keys, then create Podman secrets and run"
  echo "tank-openclaw-secrets inside the VM. Keys never touch disk on the Mac."
  echo
  read -rsp "ANTHROPIC_API_KEY: " ANTHROPIC_API_KEY; echo
  read -rsp "GEMINI_API_KEY:    " GEMINI_API_KEY;    echo
  read -rsp "OPENROUTER_API_KEY (optional, blank to skip): " OPENROUTER_API_KEY; echo
  read -rsp "GH_TOKEN (optional, blank to skip):           " GH_TOKEN;           echo

  scp -i "$SSH_KEY" -P "$SSH_PORT" \
      "$SCRIPT_DIR/tankos/scripts/bootstrap-secrets.sh" \
      "${SSH_USER}@${SSH_HOST}:bootstrap-secrets.sh"

  ssh_vm "chmod +x bootstrap-secrets.sh && \
          ANTHROPIC_API_KEY='${ANTHROPIC_API_KEY}' \
          GEMINI_API_KEY='${GEMINI_API_KEY}' \
          OPENROUTER_API_KEY='${OPENROUTER_API_KEY}' \
          GH_TOKEN='${GH_TOKEN}' \
          ./bootstrap-secrets.sh"
  ssh_vm "rm -f bootstrap-secrets.sh"

  echo -e "${C_GREEN}Secrets synced and OpenClaw restarted.${C_RESET}"
}

cmd_models() {
  banner
  if ! command -v ramalama >/dev/null 2>&1; then
    echo -e "${C_YELLOW}ramalama not found.${C_RESET} Install with:"
    echo "  brew install ramalama   # macOS"
    echo "  sudo dnf install ramalama   # Fedora"
    exit 1
  fi
  echo "Serving Qwen 3 + Gemma 4 on http://127.0.0.1:${LOCAL_MODEL_PORT}/v1"
  exec "$SCRIPT_DIR/tankos/scripts/serve-local-models.sh"
}

cmd_dashboard() {
  banner
  local url="file://$SCRIPT_DIR/briefingclaw-tankos-dashboard.html"
  url+="?local_url=http://127.0.0.1:${LOCAL_MODEL_PORT}/v1/models"
  url+="&openclaw_url=http://127.0.0.1:${GATEWAY_PORT}/health"
  url+="&servicegator_url=http://127.0.0.1:${MCP_PORT}/health"
  echo "Opening dashboard:"
  echo "  $url"
  if command -v open >/dev/null 2>&1; then open "$url"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$url"
  else echo "Open the URL above manually in a browser."; fi
}

cmd_preview() {
  banner
  local url="file://$SCRIPT_DIR/briefingclaw-tankos-dashboard.html?autostart=1"
  echo "Opening dashboard in SIMULATED mode (auto-start):"
  echo "  $url"
  if command -v open >/dev/null 2>&1; then open "$url"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$url"
  else echo "Open the URL above manually in a browser."; fi
}

cmd_upgrade() {
  banner
  resolve_ssh_target
  echo "Switching the VM to ${TANKOS_IMAGE} and rebooting..."
  ssh_vm "sudo bootc switch --apply '${TANKOS_IMAGE}'"
  echo -e "${C_GREEN}Reboot initiated. Wait ~60s and re-run './briefingclaw-tankos.sh status'.${C_RESET}"
}

cmd_logs() {
  banner
  resolve_ssh_target
  exec ssh -t -i "$SSH_KEY" -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" \
       'journalctl --user -u openclaw.service -f'
}

# ─── Dispatch ───────────────────────────────────────────────────────
case "${1:-help}" in
  status)    cmd_status ;;
  image)     cmd_image ;;
  disk)      cmd_disk ;;
  tunnel)    cmd_tunnel ;;
  provision) cmd_provision ;;
  secrets)   cmd_secrets ;;
  models)    cmd_models ;;
  dashboard) cmd_dashboard ;;
  preview)   cmd_preview ;;
  upgrade)   cmd_upgrade ;;
  logs)      cmd_logs ;;
  help|-h|--help) cmd_help ;;
  *) echo "Unknown subcommand: $1"; cmd_help; exit 2 ;;
esac
