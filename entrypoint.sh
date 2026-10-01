#!/usr/bin/env bash
# devkit entrypoint. No args -> interactive login shell. Otherwise exec the args
# (e.g. `docker run devkit start-proxy`, or `docker run devkit newman run ...`).
set -e
if [ "$#" -eq 0 ]; then
  exec zsh -l
fi
exec "$@"
