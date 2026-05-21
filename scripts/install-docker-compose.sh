#!/usr/bin/env bash
# Helper to install Docker Compose v2 CLI plugin
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Install Docker first."
  exit 1
fi

VERSION=${1:-v2.20.2}
BIN_DIR=/usr/local/lib/docker/cli-plugins
mkdir -p "$BIN_DIR"
URL="https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m)"

curl -SL "$URL" -o "$BIN_DIR/docker-compose"
chmod +x "$BIN_DIR/docker-compose"
echo "docker compose installed to $BIN_DIR/docker-compose"
