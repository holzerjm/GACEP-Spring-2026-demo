#!/usr/bin/env bash
# bootstrap-secrets.sh
#
# Run as the `openclaw` user on a TankOS VM (sudo -iu openclaw).
# Reads ANTHROPIC_API_KEY, GEMINI_API_KEY, OPENROUTER_API_KEY,
# GH_TOKEN, JIRA_API_TOKEN from the environment (or prompts), creates
# rootless Podman secrets, then runs `tank-openclaw-secrets` so the
# Quadlet drop-ins and openclaw.json SecretRefs get regenerated.
#
# This is intentionally a thin wrapper around the upstream tank-os helper
# — we never write key material into openclaw.json or any file under git.

set -euo pipefail

if [[ "$(id -un)" != "openclaw" ]]; then
  exec sudo -iu openclaw -- "$0" "$@"
fi

ensure_secret() {
  local name="$1"; local env_var="$2"; local prompt="$3"
  if podman secret inspect "$name" >/dev/null 2>&1; then
    echo "  [skip] $name already exists"
    return
  fi
  local value="${!env_var:-}"
  if [[ -z "$value" ]]; then
    if [[ -t 0 ]]; then
      read -rsp "  $prompt: " value; echo
    fi
  fi
  if [[ -z "$value" ]]; then
    echo "  [skip] $name (no value provided)"
    return
  fi
  printf '%s' "$value" | podman secret create "$name" -
  echo "  [ok]   $name"
}

echo "==> Creating Podman secrets in the openclaw user's rootless store"
ensure_secret anthropic_api_key   ANTHROPIC_API_KEY   "Anthropic API key (sk-ant-...)"
ensure_secret gemini_api_key      GEMINI_API_KEY      "Google Gemini API key"
ensure_secret openrouter_api_key  OPENROUTER_API_KEY  "OpenRouter API key (optional, for Gemma 4 cloud fallback)"
ensure_secret gh_token            GH_TOKEN            "GitHub token for service-gator (optional)"
ensure_secret jira_api_token      JIRA_API_TOKEN      "JIRA token for service-gator (optional)"

echo "==> Syncing Quadlet drop-ins and openclaw.json SecretRefs"
tank-openclaw-secrets

echo "==> Restarting OpenClaw + service-gator"
systemctl --user daemon-reload
systemctl --user restart openclaw.service
if systemctl --user list-unit-files service-gator.service >/dev/null 2>&1; then
  systemctl --user restart service-gator.service
fi

echo
echo "Done. Verify:"
echo "  systemctl --user status openclaw.service"
echo "  openclaw doctor"
echo "  openclaw dashboard --no-open"
