# docker-proxy

A small, discreet HTTP(S) + SOCKS4/5 proxy in a single container. The proxy
([3proxy](https://github.com/3proxy/3proxy)) is **compiled from source** inside
the image — the only base image used is official Alpine. Final image is ~8–12 MB.

- **HTTP(S) proxy** (CONNECT tunneling) on `:3128`
- **SOCKS4/5** on `:1080`
- Username/password auth, source-IP restriction, or (opt-in) open relay
- Config from environment variables, or a bind-mounted config file
- Runs as a non-root user, foreground, under `tini`

> This is a **relay/forward proxy**, not a MITM/TLS-inspecting proxy. HTTPS is
> tunneled opaquely via `CONNECT` and SOCKS relays raw TCP — the proxy never
> decrypts traffic. With `ANONYMOUS=1`, plaintext HTTP requests carry no
> `Via` / `X-Forwarded-For` headers; HTTPS and SOCKS add no proxy headers at all.

## Build

```sh
docker build -t docker-proxy .
# multi-arch:
docker buildx build --platform linux/amd64,linux/arm64 -t docker-proxy .
```

## Run

**With username/password auth (recommended for any exposed host):**

```sh
docker run -d --name proxy -p 3128:3128 -p 1080:1080 \
  -e PROXY_USER=admin -e PROXY_PASS='s3cret' -e ANONYMOUS=1 \
  docker-proxy
```

```sh
curl -x http://admin:s3cret@localhost:3128 https://ifconfig.me   # HTTP proxy
curl --socks5 admin:s3cret@localhost:1080  https://ifconfig.me   # SOCKS5
```

**No password, restricted to a source network (e.g. Tailscale / LAN):**

```sh
docker run -d -p 3128:3128 -p 1080:1080 \
  -e ALLOW_CIDR=100.64.0.0/10 docker-proxy
```

**Mounted config (full control; env is ignored when this file exists):**

```sh
docker run -d -p 3128:3128 -p 1080:1080 \
  -v "$PWD/3proxy.cfg:/etc/3proxy/3proxy.cfg:ro" docker-proxy
```

See `3proxy.cfg.example` for the file format, and `docker-compose.yml` for a
hardened (read-only rootfs, dropped caps) example.

## Access control

The entrypoint **refuses to start as an accidental open relay**. You must pick
exactly one mode:

| Mode | Set | 3proxy auth | Who may connect |
|------|-----|-------------|-----------------|
| Password | `PROXY_USER` + `PROXY_PASS` | `strong` | anyone with valid credentials |
| Source IP | `ALLOW_CIDR` | `iponly` | any client within the CIDR(s) |
| Open relay | `ALLOW_OPEN=1` | `none` | **anyone** (dangerous) |

`ALLOW_CIDR` accepts a comma-separated list (e.g. `100.64.0.0/10,192.168.0.0/16`).
If `PROXY_USER` and `ALLOW_CIDR` are both set, clients must satisfy **both**.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PROXY_USER` / `PROXY_PASS` | — | Enable password auth (both required together) |
| `ALLOW_CIDR` | — | Restrict by source network(s); comma-separated |
| `ALLOW_OPEN` | `0` | `1` = run a deliberate open relay (no ACL) |
| `ANONYMOUS` | `0` | `1` = strip `Via`/`X-Forwarded-For` from HTTP |
| `HTTP_PORT` | `3128` | HTTP proxy port |
| `SOCKS_PORT` | `1080` | SOCKS port |
| `ENABLE_HTTP` | `1` | `0` = disable the HTTP listener |
| `ENABLE_SOCKS` | `1` | `0` = disable the SOCKS listener |
| `BIND_ADDR` | `0.0.0.0` | Listener bind address |
| `NAMESERVER` | — | Upstream DNS server for 3proxy's resolver |
| `NSCACHE` | `65536` | DNS cache size (bytes) |
| `MAXCONN` | `200` | Max concurrent connections per service |

## Build arguments

| Arg | Default | Description |
|-----|---------|-------------|
| `ALPINE_VERSION` | `3.21` | Base image tag |
| `THREEPROXY_VERSION` | `1.0.0` | 3proxy release to build |
| `THREEPROXY_SHA256` | (pinned) | Source tarball checksum (verified at build) |

## Notes

- 3proxy is built **without** TLS/PCRE/PAM — a forward proxy tunnels TLS, it
  doesn't terminate it, so no crypto libraries are needed. This keeps the image
  minimal and the attack surface small.
- There is no `daemon` directive: 3proxy runs in the foreground and `tini`
  forwards signals, so `docker stop` is immediate and clean.
