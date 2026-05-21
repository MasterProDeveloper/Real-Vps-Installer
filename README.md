# Real-Vps-Installer

<!-- Badges (placeholders) -->
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-beta-yellow.svg)](README.md)

This repository provides an interactive VPS setup helper that performs common server
hardening and runtime setup tasks across many distributions. It's designed for quick
first-run provisioning on fresh VPS instances and CI-friendly automation.

Supported platforms (partial):
- Ubuntu (22.04, 20.04)
- Debian (stable/latest)
- CentOS / RHEL family / AlmaLinux / Rocky
- Fedora
- Alpine Linux
- Arch Linux

What it does:
- Installs common packages (`curl`, `wget`, `git`, etc.)
- Optional swap file creation
- Basic firewall setup (`ufw` on Debian/Ubuntu, `firewalld` on RHEL/Fedora)
- Optional `fail2ban` installation and enablement
- Optional Docker and Docker Compose installation
- Provides templates and guidance for SSH hardening in `templates/`

Files in this repo:
- [vps-installer.sh](vps-installer.sh) — main interactive installer with CLI flags and non-interactive mode
- [templates/SSH_HARDENING.md](templates/SSH_HARDENING.md) — recommended sshd configuration snippets and notes
- [scripts/install-docker-compose.sh](scripts/install-docker-compose.sh) — helper to install Docker Compose v2 plugin

Command reference
---------------

- `--auto` : auto-detect target OS and run default setup (prompts unless `--non-interactive` is used)
- `--os <name[:ver]>` : target OS, e.g. `ubuntu:22.04`, `debian`, `alpine`, `arch`
- `--non-interactive` : run without interactive prompts
- `--yes` : accept defaults (use with `--non-interactive`)
- `--docker` : install Docker
- `--compose` : install Docker Compose (v2 plugin)

Interactive action menu
-----------------------

On launch (without `--non-interactive`) the installer presents a first panel to pick the
target OS and then an actions panel. Actions include: base install, LEMP, LAMP, SSH hardening,
create sudo user, Docker, Compose, Netdata, unattended-upgrades, or a full recommended setup.

Examples
--------

```bash
# Interactive: choose OS and actions from panels
sudo ./vps-installer.sh

# Auto-detect and install Docker + Compose non-interactively
sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose

# Target Ubuntu 22.04 and run full recommended setup
sudo ./vps-installer.sh --os ubuntu:22.04
```

Quick Start

1. Pull the repository on the new VPS (or upload the files) and make the main script executable:

```bash
chmod +x vps-installer.sh
sudo ./vps-installer.sh
```

2. For unattended runs or provisioning via cloud-init / automation, use CLI flags:

```bash
# Auto-detect and install with Docker and Compose, non-interactive
sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose

# Target a specific OS/version
sudo ./vps-installer.sh --os ubuntu:22.04 --yes --docker
```

Security & Safety Notes
- Review the script before running on critical systems — it performs package installs and
	enables/disables services.
- When changing `sshd_config`, keep an active session open to avoid being locked out. Use
	the templates in `templates/` for guidance.
- The script intentionally avoids destructive actions (no disk repartitioning or bootloader
	changes).

Extending and Customization
- Edit [vps-installer.sh](vps-installer.sh) to add custom package lists or extra steps per distro.
- Add automation-friendly hooks or cloud-init snippets if you want to provision VMs from images.

Contributing
- Pull requests and issues welcome. If adding new distro support, include install steps and
	any required runtime permissions in a short README snippet.

License & Public Use
- This repo is public; do not store secrets or private keys in it. Use secure channels for any
	credentials.

Next steps you can ask me to do:
- Add cloud-init snippets for automated provisioning
- Add a non-root install path or containerized runner
- Add CI to run static shell checks (shellcheck) and minimal smoke tests

