# BriefingClaw on TankOS — Agent Routing

This file lives at `~/.openclaw/skills/briefingclaw/AGENTS.md` inside the OpenClaw
container (mounted read-only via the `openclaw.container` Quadlet) and at
`tankos/agents/AGENTS.md` in this repo. OpenClaw reads it during agent dispatch
to pick the right model for each codename. The routing matches the
per-agent overrides in `tankos/config/openclaw.json`.

## The Eight-Agent Cast

| # | Codename | Role | Provider | Model | Why |
|---|---|---|---|---|---|
| 1 | **Oprah-tor** | Orchestrator | Anthropic | `claude-opus-4-7` | Decomposition, validation, and synthesis benefit from frontier-class reasoning. Opus handles long mixed contexts (cross-agent JSON + free text) without losing track. |
| 2 | **Sherlock Ohms** | Executive Research | Anthropic | `claude-sonnet-4-6` | Person-level web research with citation discipline. Sonnet 4.6 hits the latency / quality balance for 8-tool-call iterative research. |
| 3 | **Bloom-borg** | Account Intelligence | Google Gemini | `gemini-3.1-pro-preview` | Company research benefits from Gemini's broader public-corpus coverage and its grounded-search-with-citations mode. Splitting Sherlock vs. Bloom-borg across providers also showcases multi-frontier portability. |
| 4 | **Déjà View** | SAB Historian | Local — Qwen 3 | `qwen3-30b-a3b-instruct` | Cross-program memory queries against private SAB / CRM / VVIP files. **Never leaves the device.** Qwen 3's 30B-A3B MoE is strong at structured retrieval over local documents. |
| 5 | **Draft Punk** | Briefing Architect | Local — Gemma 4 | `gemma-4-26b-a4b-it` | Document assembly from already-gathered intel. Gemma 4 26B-A4B is tuned for long-form structured generation; private intel never leaves the laptop. |
| 6 | **Alfred Bitworth** | VVIP Protocol | Local — Qwen 3 | `qwen3-30b-a3b-instruct` | Reads the VVIP roster and produces checklists / protocol drafts. Same privacy reasoning as Déjà View — VVIP roster is sensitive. |
| 7 | **Sponsor Coach** | Sponsor Readiness | Local — Gemma 4 | `gemma-4-26b-a4b-it` | A short scoring pass; small enough to fit Gemma 4's strengths and runs in parallel with Draft Punk + Alfred. |
| 8 | **The Oddsfather** | Success Predictor | Local — Qwen 3 | `qwen3-30b-a3b-instruct` | Phase-3 synthesis. Reasons over the entire bundle and produces a probability + the three levers. Qwen 3's reasoning chain handles the multi-criterion math reliably. |

## Why Two Local Models, Not One

The original demo used Granite 8B for everything local. Splitting local work
across **Qwen 3** (reasoning + retrieval) and **Gemma 4** (structured generation)
demonstrates two things at once:

1. **OpenClaw can route per-agent**, not per-deployment. The same gateway hits
   two local model IDs on the same `:8001` server.
2. **Different families fit different shapes of work.** Audiences see this
   directly — the dashboard renders "Qwen 3" or "Gemma 4" badges on each agent
   card so the routing is legible.

## Privacy Boundary

Cloud (Anthropic / Gemini) only sees:
- The visitor's **name + title + company** (a single line of public information)
- The orchestrator's **task description** (no private data)

Local (Qwen 3 / Gemma 4) sees:
- The full **SAB meeting notes**, **CRM export**, **VVIP roster**, and
  **engagement history**
- The drafted **deliverables** (which contain the private context)

The orchestrator enforces this split. Sherlock Ohms and Bloom-borg are sent only
the public-research task; Déjà View, Draft Punk, Alfred Bitworth, Sponsor Coach,
and The Oddsfather receive the private intel and synthesize against it.

## Switching Models

To swap a frontier provider (e.g., move Bloom-borg from Gemini to OpenAI),
edit `tankos/config/openclaw.json` and either:

- **Add** a new provider block (`models.providers.openai`), then update the
  per-agent override `agents.overrides.bloom-borg.model.primary`.
- **Or** keep the provider but change the model id (e.g., bump
  `claude-sonnet-4-6` → `claude-opus-4-7`).

After editing, restart the gateway:

```bash
systemctl --user restart openclaw.service
```

To swap a local model (e.g., trial DeepSeek-V3 in place of Qwen 3), update the
model list under `models.providers.local` to whatever Ramalama / Podman AI Lab
is serving on `:8001`, then update the per-agent override.
