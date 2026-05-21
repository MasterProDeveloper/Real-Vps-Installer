# Real VPS Installer

**Simple interactive VPS setup for Ubuntu, Debian, CentOS/RHEL, AlmaLinux/Rocky, Fedora, Alpine, and Arch.**

This repo gives you a clean menu-driven installer. Run one command and choose the OS + action you want. It installs base tools, security hardening, Docker, LEMP/LAMP, Netdata, and can add a login user after install.

## Quick start

```bash
git clone https://github.com/MasterProDeveloper/Real-Vps-Installer.git
cd Real-Vps-Installer
chmod +x vps-installer.sh vpsinstaller
sudo ./vpsinstaller
```

If you want to install directly from raw GitHub content:

```bash
curl -fsSL https://raw.githubusercontent.com/MasterProDeveloper/Real-Vps-Installer/main/vps-installer.sh | sudo bash
```

## What it does

- Shows a colorful animated menu banner
- Lets you choose a target OS
- Installs common packages, firewall, swap, fail2ban
- Installs Docker and Docker Compose when selected
- Installs LEMP or LAMP stack
- Adds SSH hardening to `/etc/ssh/sshd_config`
- Lets you create a sudo user with password or SSH key
- Provides a full install action that installs and then creates a user

## How to use

Run the installer with:

```bash
sudo ./vps-installer.sh
```

The panel will ask:

1. Choose OS or auto-detect
2. Choose an install action
3. Follow prompts to create a user or secure SSH

## One-command install

For a non-interactive install with Docker and Compose:

```bash
sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose
```

To see what would happen without making changes:

```bash
sudo ./vps-installer.sh --dry-run
```

## Supported OS

- Ubuntu 22.04, Ubuntu 20.04
- Debian latest
- CentOS / RHEL
- AlmaLinux / Rocky Linux
- Fedora
- Alpine Linux
- Arch Linux

## Recommended action

Choose `Install full setup + add user` to:

- install the base system and security tools
- install Docker/Compose when requested
- immediately prompt for username and password or SSH key

This gives you a ready-to-use login user after the install.

## Notes

- This script is meant for an existing VPS or VM instance. It does not create a cloud VPS by itself.
- Use it on a fresh server image for best results.
- Keep one SSH session open while applying SSH hardening.
- Read the script if you want to customize package selection.

## Useful commands

```bash
sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose
sudo ./vps-installer.sh --dry-run
sudo ./vpsinstaller
```

## Files

- `vps-installer.sh` — main interactive installer
- `vpsinstaller` — simple wrapper command
- `templates/sshd_hardening.conf` — SSH hardening fragment
- `templates/SSH_HARDENING.md` — notes about SSH hardening

## License

MIT License
