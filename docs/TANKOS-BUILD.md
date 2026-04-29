# BriefingClaw on TankOS — Build Guide

This is the build guide for the **TankOS variant** of the BriefingClaw demo:
the same eight-agent system from `briefingclaw-architecture.html`, repackaged
as a Fedora bootc appliance. The model lineup is **Anthropic** (Claude) and
**Google Gemini** for frontier work, **Qwen 3** and **Gemma 4** for everything
that touches private data.

If you want the original Granite-based stack, see `docs/BUILD-GUIDE.md`. Both
stacks are wired to the same agent skills and demo data — only the runtime and
the model catalog change.

## Anatomy

```
                     +------------------+
                     |   Your laptop    |
                     |   (macOS host)   |
                     +---------+--------+
                               |
                +-------------+--------------+
                |                            |
        +-------v-------+         +----------v----------+
        |  Ramalama      |         |   TankOS VM         |
        |  Qwen 3 + Gemma|         |   (Fedora bootc)    |
        |  on :8001      |         |                     |
        +-------+-------+          |  ┌──────────────┐   |
                |                  |  │ openclaw     │   |
                |   host.containers│  │ container    │   |
                |   .internal:8001 │  │ (Quadlet)    │   |
                +------------------+→ │              │   |
                                   |  └──────────────┘   |
                                   |  ┌──────────────┐   |
                                   |  │ service-gator│   |
                                   |  │ (Quadlet)    │   |
                                   |  └──────────────┘   |
                                   |  Podman secrets:    |
                                   |  anthropic_api_key  |
                                   |  gemini_api_key     |
                                   |  openrouter_api_key |
                                   +---------+-----------+
                                             |
                                       SSH tunnel
                                             |
                                  Browser → :18789
```

The VM speaks to the local model server via `host.containers.internal:8001`,
which is the rootless Podman gateway address. Frontier traffic (Anthropic,
Gemini) goes from inside the VM straight to the public APIs over its own
network. The browser hits the OpenClaw control UI on `127.0.0.1:18789` only
because of the SSH tunnel — the gateway never binds to a public interface.

## Prerequisites

- macOS or Linux host with **Podman Desktop** + **BootC extension**
- 32 GB RAM is comfortable for running Qwen 3 30B-A3B and Gemma 4 26B-A4B
  side-by-side at Q4_K_M; 16 GB works if you serve only one at a time
- An SSH key pair (`~/.ssh/id_ed25519`) — used for both the VM login and the
  Podman Desktop bootc-image-builder user form
- API keys: **Anthropic**, **Gemini** (Google AI Studio), optionally
  **OpenRouter** for cloud Gemma fallback and **GitHub** for service-gator
- Optional: `ramalama` for the local model server
  (`brew install ramalama` on macOS)

## One-Time Setup

```bash
# 1. Pull the TankOS image
./briefingclaw-tankos.sh image

# 2. Build a QCOW2 disk and start the VM (Podman Desktop UI)
./briefingclaw-tankos.sh disk
#    Follow the printed checklist. Use ssh user `openclaw` and your pubkey.

# 3. Once the VM is booted, open the SSH tunnel in one terminal
./briefingclaw-tankos.sh tunnel

# 4. In a second terminal, bootstrap secrets (one-time, prompts for keys)
./briefingclaw-tankos.sh secrets

# 5. Push BriefingClaw skill files + demo data into ~/.openclaw on the VM
./briefingclaw-tankos.sh provision

# 6. Start the local model server on the host (third terminal, background)
./briefingclaw-tankos.sh models
```

After step 6 you should see status `LIVE` in the dashboard:

```bash
./briefingclaw-tankos.sh dashboard
```

## Day-Two Operations

```bash
./briefingclaw-tankos.sh status      # Health check across all layers
./briefingclaw-tankos.sh logs        # Tail OpenClaw journal over SSH
./briefingclaw-tankos.sh upgrade     # bootc switch --apply latest tag
```

To rotate API keys, re-run `secrets` — `tank-openclaw-secrets` regenerates
the Quadlet drop-in and the SecretRef stanzas in `openclaw.json` from
whatever Podman secrets are present, then restarts the gateway. No file
under git ever sees the key material.

## Demo Mode (no infrastructure)

You can present the dashboard without any of the above by running:

```bash
./briefingclaw-tankos.sh preview
```

The `?autostart=1` URL parameter triggers the simulated timeline as soon
as the dashboard loads. The mode badge stays `SIMULATED`, the deliverable
modals still open, and the Sarah Chen scenario plays in ~38 seconds.

## What Lives Where

| Path | Purpose |
|------|---------|
| `briefingclaw-tankos-architecture.html` | Static architecture diagram (open in browser) |
| `briefingclaw-tankos-dashboard.html` | Live demo dashboard with simulated timeline |
| `briefingclaw-tankos.sh` | All operational subcommands |
| `tankos/quadlets/openclaw.container` | Rootless OpenClaw Quadlet (Anthropic + Gemini + Qwen + Gemma) |
| `tankos/quadlets/service-gator.container` | Rootless service-gator Quadlet (scoped GitHub / JIRA MCP) |
| `tankos/quadlets/local-models.container` | Optional in-VM local model server (Ramalama image) |
| `tankos/quadlets/10-secrets.conf` | Reference copy of the SecretRef drop-in |
| `tankos/config/openclaw.json` | Full provider catalog with per-agent model overrides |
| `tankos/config/service-gator-scopes.json` | Read-only GitHub scope file for the demo |
| `tankos/agents/AGENTS.md` | Per-agent model routing rationale |
| `tankos/scripts/bootstrap-secrets.sh` | Runs inside the VM to create secrets and sync |
| `tankos/scripts/serve-local-models.sh` | Hosts Qwen 3 + Gemma 4 via Ramalama on `:8001` |
| `docs/TANKOS-BUILD.md` | This guide |

## Why This Variant

The original BriefingClaw demo answers *"can a multi-agent system do
executive briefing prep in 90 seconds?"* — yes, on a laptop, with one local
model and one cloud model.

The TankOS variant answers a different audience question: *"how does this
ship?"* It demonstrates four production patterns at once:

1. **Bootable appliance** — one OCI image is the entire OS + service. The
   demo VM and a fleet of identical lab machines come up the same way.
2. **Rootless services** — OpenClaw and service-gator both run as the
   `openclaw` user. No daemonized container runtime, no host package drift.
3. **Secrets out of the image** — every key is a Podman secret in the
   `openclaw` user's rootless store. `tank-openclaw-secrets` writes only
   references, never values.
4. **Per-agent model routing** — the same gateway serves Claude, Gemini,
   Qwen, and Gemma to different agents. Frontier reasoning where it earns
   its cost; on-device inference for everything that touches private data.

That last point is the one the audience usually didn't expect — show the
dashboard with the four colour-coded model badges and the routing decision
becomes legible without a slide.
