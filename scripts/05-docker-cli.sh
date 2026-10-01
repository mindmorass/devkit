#!/usr/bin/env bash
# Docker CLI (client only — no daemon), plus buildx and compose plugins, from
# Docker's official apt repo. Point it at a mounted host socket:
#   docker run -v /var/run/docker.sock:/var/run/docker.sock ...
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
. "$(dirname "$0")/lib.sh"

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin
rm -rf /var/lib/apt/lists/*
echo "[05-docker-cli] done"
