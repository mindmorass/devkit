# syntax=docker/dockerfile:1
# devkit — a developer toolbox container (Ubuntu 24.04).
# apt-first install policy; pinned vendor binaries, Go/Node/Python, then Homebrew
# only for what apt doesn't carry. Includes our 3proxy HTTP+SOCKS relay + gost.
FROM ubuntu:24.04

ARG NODE_MAJOR=22
ARG GO_VERSION=1.27.1
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    GOPATH=/home/dev/go \
    PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/usr/local/go/bin:/home/dev/go/bin:/home/dev/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# --- root-stage installs (one RUN per tier for better layer caching) ---
COPY scripts/ /opt/devkit/scripts/
RUN chmod +x /opt/devkit/scripts/*.sh
RUN /opt/devkit/scripts/00-apt.sh
RUN /opt/devkit/scripts/05-docker-cli.sh
RUN NODE_MAJOR=${NODE_MAJOR} GO_VERSION=${GO_VERSION} /opt/devkit/scripts/10-languages.sh
RUN /opt/devkit/scripts/20-binaries.sh
RUN /opt/devkit/scripts/30-3proxy.sh
RUN /opt/devkit/scripts/40-npm-tools.sh
RUN /opt/devkit/scripts/50-python-tools.sh
RUN /opt/devkit/scripts/90-testssl.sh

# --- non-root dev user (Ubuntu 24.04 ships a uid-1000 'ubuntu' user; replace it) ---
RUN userdel -r ubuntu 2>/dev/null || true; \
    useradd -m -u 1000 -s /usr/bin/zsh dev && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev && chmod 0440 /etc/sudoers.d/dev && \
    install -d -o dev -g dev /home/dev/work /home/dev/go /home/dev/.local/bin
COPY --chown=dev:dev devkit.zshrc /home/dev/.zshrc
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/start-proxy.sh /usr/local/bin/start-proxy
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/start-proxy

# --- Homebrew as the dev user (brew refuses root) ---
USER dev
RUN /opt/devkit/scripts/60-brew.sh

WORKDIR /home/dev/work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
