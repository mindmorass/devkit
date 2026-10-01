#!/usr/bin/env bash
# Shared helpers for devkit install scripts.
set -euo pipefail

# Normalized architecture: amd64 | arm64
ARCH="$(dpkg --print-architecture)"

# Common per-tool arch aliases.
case "$ARCH" in
  amd64) ARCH_X86="x86_64"; ARCH_GNU="x86_64"; ARCH_RUST="x86_64" ;;
  arm64) ARCH_X86="arm64";  ARCH_GNU="aarch64"; ARCH_RUST="aarch64" ;;
  *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
esac

log()  { echo ">> $*" >&2; }
dl()   { curl -fsSL --retry 3 --retry-delay 2 -o "$2" "$1"; }

# install_bin <src-path> <name>  -> /usr/local/bin/<name>, +x
install_bin() { install -m 0755 "$1" "/usr/local/bin/$2"; }
