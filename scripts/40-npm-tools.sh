#!/usr/bin/env bash
# Node-based CLI tools installed globally (Node provided by tier 2).
#   newman          - Postman collection runner (CLI replacement for the GUI)
#   @github/copilot - GitHub Copilot CLI
#   @openai/codex   - OpenAI Codex CLI
set -euo pipefail
npm install -g --no-fund --no-audit \
  newman@6 \
  @github/copilot \
  @openai/codex
echo "[40-npm-tools] done"
