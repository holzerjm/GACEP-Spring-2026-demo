#!/usr/bin/env bash
# serve-local-models.sh — pull and serve Qwen 3 + Gemma 4 on :8001
#
# Run on the host (not inside a TankOS VM) when you want to keep model
# inference on your laptop GPU/Metal. The Quadlet at
# tankos/quadlets/local-models.container does the same thing as a systemd
# service inside a TankOS VM.
#
# Defaults assume you have ramalama installed:
#   brew install ramalama         # macOS
#   sudo dnf install ramalama     # Fedora
# Or use the OCI image: quay.io/ramalama/ramalama:latest

set -euo pipefail

PORT="${LOCAL_MODELS_PORT:-8001}"
QWEN="${QWEN_MODEL:-hf://Qwen/Qwen3-30B-A3B-Instruct-2507-GGUF:Q4_K_M}"
GEMMA="${GEMMA_MODEL:-hf://google/gemma-4-26b-a4b-it-GGUF:Q4_K_M}"

if ! command -v ramalama >/dev/null 2>&1; then
  echo "ramalama not found. Install via 'brew install ramalama' (macOS) or"
  echo "fall back to Podman AI Lab in Podman Desktop and skip this script."
  exit 1
fi

echo "==> Pulling local model weights (cached after first run)"
ramalama pull "$QWEN"
ramalama pull "$GEMMA"

echo "==> Serving Qwen 3 + Gemma 4 on http://127.0.0.1:${PORT}/v1"
echo "    Model IDs exposed: qwen3-30b-a3b-instruct, gemma-4-26b-a4b-it"
echo "    Stop with Ctrl-C. To run as a TankOS Quadlet instead, copy"
echo "    tankos/quadlets/local-models.container into the VM."
exec ramalama serve --host 127.0.0.1 --port "$PORT" "$QWEN" "$GEMMA"
