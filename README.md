# devkit

A developer toolbox container (Ubuntu 24.04, CLI-first) that you shell into.
It bundles API-testing, networking/diagnostic, defensive-security, and AI CLIs,
plus a built-from-source **HTTP(S)+SOCKS proxy** (3proxy) and **gost** for
proxy-compatibility and egress testing.

> It is a *toolbox you exec into*, not a long-running service. The proxy is
> opt-in via `start-proxy`.

## Why a local proxy in here (legitimate uses)

- **Proxy-compatibility testing** — verify an app honors `HTTP_PROXY`/`ALL_PROXY`/
  `NO_PROXY`, handles `407`, and works over CONNECT. `start-proxy` is a
  reproducible fixture for CI.
- **Egress allowlist / firewall verification** on locked-down hosts — route test
  traffic through one auditable chokepoint and read the CONNECT log.
- **Single known egress identity** for a fleet of test containers.
- **SOCKS bastion** to internal-only services (containerized `ssh -D`).
- **Outbound-call observability** — see every host a test suite contacts.

## Install policy

apt first; then pinned vendor **binaries**; then **Go/Node/Python**; **Homebrew**
only for what apt doesn't carry. Homebrew runs as the non-root `dev` user. On
arm64, brew formulae without bottles build from source, so the brew list is kept
deliberately short (`glow`, `gum`).

## What's inside

| Category | Tools |
|---|---|
| API / HTTP | `curl` `wget` `httpie` `xh` `hurl` `newman` `grpcurl` `websocat` `jq` `yq` |
| Proxies | `3proxy` (ours) · `gost` · `mitmproxy`/`mitmdump`/`mitmweb` |
| Net diag | `nmap` `ncat` `tcpdump` `mtr` `dig` `whois` `openssl` `iperf3` `socat` `testssl.sh` |
| Security (defensive) | `trivy` `gitleaks` `semgrep` `nuclei` `mkcert` |
| Core dev | `git` `git-lfs` `gh` `docker` (CLI) `nvim` `tmux` `zsh` `ripgrep` `fd` `bat` `eza` `fzf` `direnv` `lazygit` `glow` `gum` |
| Languages | Node 22 · Go 1.27 · Python 3 + `uv` |
| AI | GitHub Copilot CLI (`copilot`) · OpenAI Codex CLI (`codex`) |


## Use

```sh
# Shell into the toolbox (mounts your cwd and the docker socket)
docker run -it --rm \
  -v "$PWD:/home/dev/work" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  mindmorass/devkit

# Run a single tool non-interactively
docker run --rm -v "$PWD:/home/dev/work" mindmorass/devkit newman run collection.json
```

### The proxy (`start-proxy`)

```sh
# 3proxy (default engine): HTTP :3128 + SOCKS :1080, password auth
docker run --rm -p 3128:3128 -p 1080:1080 \
  -e PROXY_USER=u -e PROXY_PASS=p -e ANONYMOUS=1 \
  mindmorass/devkit start-proxy

# gost engine: HTTP+SOCKS on one port; set GOST_LISTEN for TLS/WS transports
docker run --rm -p 8080:8080 \
  -e PROXY_ENGINE=gost -e PROXY_USER=u -e PROXY_PASS=p \
  mindmorass/devkit start-proxy
```

`start-proxy` **refuses to start as an accidental open relay** — set
`PROXY_USER`+`PROXY_PASS`, or `ALLOW_CIDR` (source-IP restriction), or
`ALLOW_OPEN=1` (deliberate). See the script header for all env vars; a mounted
`/etc/3proxy/3proxy.cfg` is used verbatim (env ignored).

## CI / publishing

`.github/workflows/build.yml` builds multi-arch (amd64+arm64) and pushes to
Docker Hub on pushes to `main` and `v*` tags. Configure in the GitHub repo:

- **Secret** `DOCKERHUB_USERNAME` — Docker Hub account username
- **Secret** `DOCKERHUB_TOKEN` — Docker Hub Personal Access Token (Read & Write)
- **Variable** `DOCKERHUB_IMAGE` — e.g. `mindmorass/devkit`

## Build locally

```sh
docker build -t devkit .
docker buildx build --platform linux/amd64,linux/arm64 -t devkit .
```
