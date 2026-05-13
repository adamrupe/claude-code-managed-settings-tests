#!/usr/bin/env bash
set -euo pipefail

docker build -t managed-settings-test .

docker run --rm \
  -e ANTHROPIC_AUTH_TOKEN=$CBORG_API_KEY \
  -e ANTHROPIC_BASE_URL=https://api.cborg.lbl.gov \
  managed-settings-test
