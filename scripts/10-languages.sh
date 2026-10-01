#!/usr/bin/env bash
# Tier 2: language runtimes not carried (currently) by apt at the versions we want.
#   Node  -> NodeSource (newman, Copilot CLI, Codex CLI all need it)
#   Go    -> official tarball (apt's golang lags)
#   uv    -> Astral installer (fast Python tool/venv manager)
set -euo pipefail
. "$(dirname "$0")/lib.sh"

NODE_MAJOR="${NODE_MAJOR:-22}"
GO_VERSION="${GO_VERSION:-1.27.1}"

# --- Node (NodeSource) ---
log "Installing Node ${NODE_MAJOR}.x via NodeSource"
curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs
rm -rf /var/lib/apt/lists/*
npm install -g npm@latest >/dev/null 2>&1 || true

# --- Go (official tarball) ---
log "Installing Go ${GO_VERSION} (${ARCH})"
dl "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" /tmp/go.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tar.gz
rm -f /tmp/go.tar.gz

# --- uv (Astral) -> /usr/local/bin ---
log "Installing uv (Python tool/venv manager)"
export UV_INSTALL_DIR=/usr/local/bin
curl -fsSL https://astral.sh/uv/install.sh | sh

/usr/local/go/bin/go version
node --version
/usr/local/bin/uv --version
echo "[10-languages] done"
