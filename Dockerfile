# syntax=docker/dockerfile:1
#
# docker-proxy: a small HTTP(S) + SOCKS4/5 relay built from 3proxy source.
# Only official OS base images are used; the proxy itself is compiled here.

ARG ALPINE_VERSION=3.21

# ---- builder: compile 3proxy from a checksum-pinned source tarball ----
FROM alpine:${ALPINE_VERSION} AS builder

ARG THREEPROXY_VERSION=1.0.0
ARG THREEPROXY_SHA256=35b07de1046f3aaeac4a7085101b7e5c453efa3527cbdc42a84690366c7ecfa8

RUN apk add --no-cache build-base

WORKDIR /build
ADD https://github.com/3proxy/3proxy/archive/refs/tags/${THREEPROXY_VERSION}.tar.gz src.tar.gz
RUN set -eux; \
    echo "${THREEPROXY_SHA256}  src.tar.gz" | sha256sum -c -; \
    tar xzf src.tar.gz --strip-components=1; \
    mkdir -p bin; \
    # Plain build: no STATIC/WOLFSSL. SSL/PCRE/PAM are auto-probed and skipped
    # since those libs are absent -> a lean CONNECT+SOCKS relay (TLS is tunneled,
    # never terminated, so no crypto libs are needed).
    make -f Makefile.Linux; \
    strip bin/3proxy; \
    ./bin/3proxy --help >/dev/null 2>&1 || true

# ---- final: minimal runtime image ----
FROM alpine:${ALPINE_VERSION}

# tini: proper PID 1 (signal forwarding + zombie reaping). It's a package,
# not a base image, so it stays within the "official OS base only" constraint.
RUN apk add --no-cache tini \
 && addgroup -S proxy \
 && adduser -S -G proxy -H -s /sbin/nologin proxy

COPY --from=builder /build/bin/3proxy /usr/local/bin/3proxy
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER proxy

# HTTP proxy (CONNECT) and SOCKS4/5. These are the entrypoint defaults;
# override with HTTP_PORT / SOCKS_PORT.
EXPOSE 3128 1080

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
