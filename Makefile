# BriefingClaw — Makefile
# Convenience targets wrapping briefingclaw.sh and common operations.

.PHONY: setup start stop status demo preflight record sherlock bloomborg clean help

# Default target
help: ## Show available targets
	@echo ""
	@echo "  BriefingClaw — Make Targets"
	@echo "  =========================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo ""

setup: ## First-time setup (create config, copy files, prompt for API keys)
	@./briefingclaw.sh setup

start: ## Start all services (Podman, model server, OpenClaw container)
	@./briefingclaw.sh start

stop: ## Stop the OpenClaw container
	@./briefingclaw.sh stop

status: ## Show system health and agent readiness
	@./briefingclaw.sh status

demo: ## Launch the full demo environment (browser + terminal tabs)
	@./briefingclaw.sh demo

preflight: ## Conference-day checklist (run 30 min before session)
	@./briefingclaw.sh preflight

record: ## Guide for recording a backup demo video
	@./briefingclaw.sh record

sherlock: ## Run Sherlock Ohms standalone (usage: make sherlock Q="Name, Title, Company")
	@./briefingclaw.sh sherlock "$(Q)"

bloomborg: ## Run Bloom-borg standalone (usage: make bloomborg Q="Company Name")
	@./briefingclaw.sh bloomborg "$(Q)"

clean: ## Remove output files and OpenClaw memory volume
	@echo "Removing output directory..."
	@rm -rf output/
	@echo "Removing OpenClaw memory volume..."
	@podman volume rm openclaw-memory 2>/dev/null || true
	@echo "Clean complete."

validate-config: ## Validate YAML, TOML, and JSON config files parse correctly
	@echo "Validating config files..."
	@python3 -c "import json; json.load(open('demo-data/crm-export.json'))" && echo "  crm-export.json: OK" || echo "  crm-export.json: FAIL"
	@python3 -c "import json; json.load(open('demo-data/vvip-roster.json'))" && echo "  vvip-roster.json: OK" || echo "  vvip-roster.json: FAIL"
	@python3 -c "import yaml; yaml.safe_load(open('config/openclaw-config.yml'))" 2>/dev/null && echo "  openclaw-config.yml: OK" || echo "  openclaw-config.yml: SKIP (PyYAML not installed)"
	@echo "Validation complete."
