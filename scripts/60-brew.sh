#!/usr/bin/env bash
# Tier 4: Homebrew (Linuxbrew). Policy: brew installs ONLY tools that apt does
# not carry and that we did not already cover with a pinned binary. Runs as the
# non-root 'dev' user (brew refuses root). Keep this list SHORT: on arm64 Linux
# many formulae lack bottles and build from source (slow under CI emulation).
set -euo pipefail

export NONINTERACTIVE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# Install Homebrew itself.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

BREW=/home/linuxbrew/.linuxbrew/bin/brew
eval "$("$BREW" shellenv)"

# Brew-only dev CLIs (not in apt, no clean vendor binary tier here).
#   glow - terminal markdown renderer
#   gum  - shell-script UI toolkit
"$BREW" install glow gum gh || echo "[60-brew] WARN: some brew formulae failed (continuing)"

"$BREW" cleanup || true
echo "[60-brew] done"
