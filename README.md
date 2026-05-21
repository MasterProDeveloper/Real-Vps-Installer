# Real-Vps-Installer

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Status](https://img.shields.io/badge/status-beta-yellow.svg)](README.md) [![Platform](https://img.shields.io/badge/platform-multi--distro-brightgreen.svg)]

Welcome — this repository contains a friendly, interactive VPS provisioning helper that
speeds up the initial hardening and runtime setup for new virtual machines.

Highlights
- Clean interactive OS + actions selection panel
- Non-interactive / automation mode for cloud-init or provisioning pipelines
- Supports Ubuntu, Debian, CentOS/RHEL, AlmaLinux/Rocky, Fedora, Alpine, Arch
- Common tasks: base packages, firewall, swap, fail2ban, Docker, Compose, LAMP/LEMP,
  SSH hardening, Netdata, unattended-upgrades

**Quick TL;DR (copy & paste)**

```bash
# clone
git clone https://github.com/MasterProDeveloper/Real-Vps-Installer.git
cd Real-Vps-Installer
# make executable and run interactive
chmod +x vps-installer.sh
sudo ./vps-installer.sh

# or non-interactive example (auto-detect + Docker + Compose)
sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose
```

**Why this repo?**
- Great for one-shot server bootstrap on fresh images
- Easy to read, modify and extend — shell-first approach avoids heavy dependencies
- Templates and helper scripts live in `templates/` and `scripts/`

Supported OS (at-a-glance)
| Family | Examples | Notes |
|---|---:|---|
| Debian family | Ubuntu 22.04, 20.04, Debian stable | Uses `apt` and `ufw` by default |
| RHEL family | CentOS, AlmaLinux, Rocky, RHEL | Uses `yum`/`dnf` and `firewalld` |
| Fedora | Fedora latest | `dnf` |
| Alpine | Alpine Linux | `apk` |
| Arch | Arch Linux | `pacman` |

Getting started — simplified commands
- Make the main script executable: `chmod +x vps-installer.sh`
- Run interactive: `sudo ./vps-installer.sh`
- Run unattended (example): `sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose`

Command reference (simple)
| Command | What it does | Example |
|---|---|---|
| `--auto` | Detect the distro automatically and choose defaults | `--auto --docker` |
| `--os <name[:ver]>` | Target a specific OS (ubuntu:22.04, debian, alpine, arch) | `--os ubuntu:22.04` |
| `--non-interactive` | No prompts (combine with `--yes`) | `--non-interactive --yes` |
| `--yes` | Accept defaults in non-interactive mode | `--non-interactive --yes` |
| `--docker` | Install Docker engine (get.docker.com) | `--docker` |
| `--compose` | Install Docker Compose v2 plugin | `--compose` |

Interactive flow (what you will see)
1. First panel: choose OS (auto-detect, or pick from list)
2. Actions panel: choose from base install, LEMP, LAMP, SSH hardening, add user, Docker, Compose, Netdata, unattended-upgrades or full recommended setup
3. Follow prompt confirmations (unless `--non-interactive --yes` used)

Safety / Best Practices
- Review the script before running on production — it performs package installs and restarts services.
- When applying SSH hardening, keep a session open to avoid lockout; templates provide guidance.
- For automated provisioning, prefer using `--non-interactive --yes` with a fresh image.

Templates & helpers
- `templates/sshd_hardening.conf` — plain fragment suitable to append to `/etc/ssh/sshd_config`
- `templates/SSH_HARDENING.md` — notes and sample edits
- `scripts/install-docker-compose.sh` — helper to install Compose v2 plugin

Developer notes (for contributors)
- The main script is `vps-installer.sh`. It's intentionally POSIX-ish Bash (uses `set -euo pipefail`).
- Add new distro support by adding an `*_install()` function and updating the menu mapping.
- Keep changes small and test with `bash -n vps-installer.sh` for syntax and a dry-run on disposable machines.

Quick cloud-init example (paste into your cloud provider userdata)

```yaml
#cloud-config
runcmd:
  - [ sh, -c, 'cd /root && git clone https://github.com/MasterProDeveloper/Real-Vps-Installer.git' ]
  - [ sh, -c, 'cd /root/Real-Vps-Installer && chmod +x vps-installer.sh && sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose' ]
```

FAQ / Troubleshooting
- Q: The installer asked about modified `sshd_config` while upgrading packages — what to pick?
  - A: If prompted by `dpkg` choose to **keep the local version** if you previously customized SSH; otherwise choose the package maintainer's version and re-apply hardening via the action menu.
- Q: Swap creation failed with `swapon: invalid argument`?
  - A: The script now tries `mkswap -f` and will leave a candidate `/swapfile` for inspection if enabling fails. You can enable manually: `sudo mkswap /swapfile && sudo swapon /swapfile`.

Roadmap (short)
- Add cloud-init templates for popular providers
- Add `--dry-run` and a `--no-reboot` toggle
- Add CI checks with `shellcheck` and a small acceptance test container

Contributing
- PRs welcome. For new features, open an issue first so we can align on scope.

License
- MIT — see `LICENSE`

Enjoy — if you want I can also:
- add polished cloud-init snippets for DigitalOcean/Azure/AWS
- add `--dry-run` and `--apply=actions.csv` for scripted runs
