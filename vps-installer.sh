#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="vps-installer.sh"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global flags
NONINTERACTIVE=false
ASSUME_YES=false
WANTED_OS=""
INSTALL_DOCKER=false
INSTALL_COMPOSE=false
DRY_RUN=false

# ANSI colors for panel styling
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
MAGENTA="\033[1;35m"
RED="\033[1;31m"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Options:
  --auto                Auto-detect distro and run default setup
  --os <name[:ver]>     Target OS (ubuntu:22.04, debian, centos, alpine, arch)
  --non-interactive     Run without prompts (use with --yes to accept defaults)
  --yes                 Implicit yes to prompts
  --docker              Install Docker
  --compose             Install Docker Compose
  --dry-run             Show what would run without making changes
  -h, --help            Show this help

Examples:
  sudo $SCRIPT_NAME --auto --docker
  sudo $SCRIPT_NAME --os ubuntu:22.04 --non-interactive --yes --docker --compose
  sudo $SCRIPT_NAME --dry-run
