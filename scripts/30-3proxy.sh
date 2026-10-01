#!/usr/bin/env bash
# Build 3proxy (our HTTP+SOCKS relay) from a checksum-pinned source tarball.
# Built here rather than apt-installed: 3proxy is only in Ubuntu universe at an
# old version, and compiling pins the exact release and works on both arches.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

V_3PROXY="${V_3PROXY:-1.0.0}"
SHA_3PROXY="${SHA_3PROXY:-35b07de1046f3aaeac4a7085101b7e5c453efa3527cbdc42a84690366c7ecfa8}"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
dl "https://github.com/3proxy/3proxy/archive/refs/tags/${V_3PROXY}.tar.gz" "$TMP/3proxy.tgz"
echo "${SHA_3PROXY}  $TMP/3proxy.tgz" | sha256sum -c -
mkdir -p "$TMP/src"
tar -C "$TMP/src" --strip-components=1 -xzf "$TMP/3proxy.tgz"
( cd "$TMP/src" && mkdir -p bin && make -f Makefile.Linux && strip bin/3proxy )
install_bin "$TMP/src/bin/3proxy" 3proxy
echo "[30-3proxy] done"
