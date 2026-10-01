#!/usr/bin/env bash
# Tier 3: tools apt does not carry (or carries stale), installed from each
# project's official pinned release binary. Versions pinned; arch-aware.
# Integrity boundary: version pin + HTTPS from the vendor's GitHub releases.
set -uo pipefail
. "$(dirname "$0")/lib.sh"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
OK=(); FAIL=()

# Pinned versions
V_GOST=3.3.0 V_HURL=8.0.1 V_YQ=4.54.1 V_GRPCURL=1.9.4 V_GITLEAKS=8.30.1
V_NUCLEI=3.11.1 V_XH=0.26.2 V_WEBSOCAT=1.14.1 V_TRIVY=0.74.0 V_MKCERT=1.4.4 V_LAZYGIT=0.65.1

try() { # try <name> <function>
  local name="$1"; shift
  if "$@"; then OK+=("$name"); else FAIL+=("$name"); fi
}

i_gost() {
  dl "https://github.com/go-gost/gost/releases/download/v${V_GOST}/gost_${V_GOST}_linux_${ARCH}.tar.gz" "$TMP/gost.tgz"
  tar -C "$TMP" -xzf "$TMP/gost.tgz" gost && install_bin "$TMP/gost" gost
}
i_hurl() {
  dl "https://github.com/Orange-OpenSource/hurl/releases/download/${V_HURL}/hurl-${V_HURL}-${ARCH_GNU}-unknown-linux-gnu.tar.gz" "$TMP/hurl.tgz"
  tar -C "$TMP" -xzf "$TMP/hurl.tgz" && install_bin "$TMP/hurl-${V_HURL}-${ARCH_GNU}-unknown-linux-gnu/bin/hurl" hurl \
    && install_bin "$TMP/hurl-${V_HURL}-${ARCH_GNU}-unknown-linux-gnu/bin/hurlfmt" hurlfmt
}
i_yq() {
  dl "https://github.com/mikefarah/yq/releases/download/v${V_YQ}/yq_linux_${ARCH}" "$TMP/yq" && install_bin "$TMP/yq" yq
}
i_grpcurl() {
  dl "https://github.com/fullstorydev/grpcurl/releases/download/v${V_GRPCURL}/grpcurl_${V_GRPCURL}_linux_${ARCH_X86}.tar.gz" "$TMP/grpcurl.tgz"
  tar -C "$TMP" -xzf "$TMP/grpcurl.tgz" grpcurl && install_bin "$TMP/grpcurl" grpcurl
}
i_gitleaks() {
  local a="x64"; [ "$ARCH" = arm64 ] && a="arm64"
  dl "https://github.com/gitleaks/gitleaks/releases/download/v${V_GITLEAKS}/gitleaks_${V_GITLEAKS}_linux_${a}.tar.gz" "$TMP/gl.tgz"
  tar -C "$TMP" -xzf "$TMP/gl.tgz" gitleaks && install_bin "$TMP/gitleaks" gitleaks
}
i_nuclei() {
  dl "https://github.com/projectdiscovery/nuclei/releases/download/v${V_NUCLEI}/nuclei_${V_NUCLEI}_linux_${ARCH}.zip" "$TMP/nuclei.zip"
  (cd "$TMP" && unzip -oq nuclei.zip nuclei) && install_bin "$TMP/nuclei" nuclei
}
i_xh() {
  dl "https://github.com/ducaale/xh/releases/download/v${V_XH}/xh-v${V_XH}-${ARCH_GNU}-unknown-linux-musl.tar.gz" "$TMP/xh.tgz"
  tar -C "$TMP" -xzf "$TMP/xh.tgz" && install_bin "$TMP/xh-v${V_XH}-${ARCH_GNU}-unknown-linux-musl/xh" xh
  ln -sf /usr/local/bin/xh /usr/local/bin/xhs
}
i_websocat() {
  local a="x86_64"; [ "$ARCH" = arm64 ] && a="aarch64"
  dl "https://github.com/vi/websocat/releases/download/v${V_WEBSOCAT}/websocat.${a}-unknown-linux-musl" "$TMP/websocat" \
    && install_bin "$TMP/websocat" websocat
}
i_trivy() {
  local a="64bit"; [ "$ARCH" = arm64 ] && a="ARM64"
  dl "https://github.com/aquasecurity/trivy/releases/download/v${V_TRIVY}/trivy_${V_TRIVY}_Linux-${a}.tar.gz" "$TMP/trivy.tgz"
  tar -C "$TMP" -xzf "$TMP/trivy.tgz" trivy && install_bin "$TMP/trivy" trivy
}
i_mkcert() {
  dl "https://github.com/FiloSottile/mkcert/releases/download/v${V_MKCERT}/mkcert-v${V_MKCERT}-linux-${ARCH}" "$TMP/mkcert" \
    && install_bin "$TMP/mkcert" mkcert
}
i_lazygit() {
  local a="x86_64"; [ "$ARCH" = arm64 ] && a="arm64"
  dl "https://github.com/jesseduffield/lazygit/releases/download/v${V_LAZYGIT}/lazygit_${V_LAZYGIT}_Linux_${a}.tar.gz" "$TMP/lg.tgz"
  tar -C "$TMP" -xzf "$TMP/lg.tgz" lazygit && install_bin "$TMP/lazygit" lazygit
}

try gost     i_gost
try hurl     i_hurl
try yq       i_yq
try grpcurl  i_grpcurl
try gitleaks i_gitleaks
try nuclei   i_nuclei
try xh       i_xh
try websocat i_websocat
try trivy    i_trivy
try mkcert   i_mkcert
try lazygit  i_lazygit

echo "[20-binaries] installed: ${OK[*]:-none}"
if [ "${#FAIL[@]}" -gt 0 ]; then
  echo "[20-binaries] FAILED: ${FAIL[*]}" >&2
  exit 1
fi
echo "[20-binaries] done"
