#!/usr/bin/env bash
# Tier 1: everything Ubuntu's apt carries. apt is the first choice; later tiers
# (pinned binaries, Go/Node/Python, Homebrew) only cover what apt does NOT have.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates curl wget gnupg lsb-release apt-transport-https \
  build-essential pkg-config \
  git git-lfs openssh-client \
  zsh tmux neovim vim nano less \
  ripgrep fd-find bat eza fzf direnv \
  jq tree htop rsync unzip zip file procps sudo locales man-db \
  python3 python3-pip python3-venv pipx \
  nmap ncat netcat-openbsd socat tcpdump mtr-tiny dnsutils whois iputils-ping \
  net-tools iproute2 iperf3 openssl \
  httpie

# Ubuntu ships these under alternate names; expose the expected commands.
ln -sf "$(command -v fdfind)"  /usr/local/bin/fd
ln -sf "$(command -v batcat)"  /usr/local/bin/bat

# UTF-8 locale for a sane shell.
sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen en_US.UTF-8

git lfs install --system || true

rm -rf /var/lib/apt/lists/*
echo "[00-apt] done"
