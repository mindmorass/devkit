#!/usr/bin/env bash
# testssl.sh: a single self-contained bash script (not in apt). Clone pinned tag.
set -euo pipefail
V_TESTSSL="${V_TESTSSL:-v3.2.2}"
git clone --depth 1 --branch "$V_TESTSSL" https://github.com/testssl/testssl.sh /opt/testssl
ln -sf /opt/testssl/testssl.sh /usr/local/bin/testssl.sh
echo "[90-testssl] done"
