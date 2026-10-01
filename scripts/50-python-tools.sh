#!/usr/bin/env bash
# Python-based tools via uv (installs isolated, exposes on PATH at /usr/local/bin).
#   semgrep    - SAST scanner
#   mitmproxy  - inspect your OWN dev traffic (mitmproxy/mitmdump/mitmweb)
set -euo pipefail
export UV_TOOL_BIN_DIR=/usr/local/bin
export UV_TOOL_DIR=/opt/uv-tools
mkdir -p "$UV_TOOL_DIR"
uv tool install --no-cache semgrep
uv tool install --no-cache mitmproxy
echo "[50-python-tools] done"
