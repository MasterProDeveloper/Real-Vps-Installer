# Real VPS Installer

**Simple interactive VPS setup for Ubuntu, Debian, CentOS/RHEL, AlmaLinux/Rocky, Fedora, Alpine, and Arch.**

This repository gives you a clean, menu-driven installer for a fresh VPS image.
Run one command, choose your OS, and select the setup steps you want.

## Quick start

```bash
git clone https://github.com/MasterProDeveloper/Real-Vps-Installer.git
cd Real-Vps-Installer
chmod +x vps-installer.sh vpsinstaller
sudo ./vpsinstaller
```

## Run from GitHub raw content

```bash
curl -fsSL https://raw.githubusercontent.com/MasterProDeveloper/Real-Vps-Installer/main/vps-installer.sh | sudo bash
```

## What it does

- Shows a colorful animated panel with a big heading
- Lets you pick OS and install actions
- Installs common packages, firewall, swap, fail2ban, and security tools
- Supports Docker and Docker Compose
- Installs LEMP or LAMP stacks
- Adds SSH hardening from `templates/sshd_hardening.conf`
- Lets you create a new sudo user after install
- Includes a full-install action that installs packages and then prompts for a login user

## How to use

Run the installer and follow the menu:

```bash
sudo ./vps-installer.sh
```

Then use the panel to:

1. Choose an OS or auto-detect
2. Choose an install action
3. Create a user if you want a login account

## Example commands

```bash
sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose
sudo ./vps-installer.sh --dry-run
sudo ./vpsinstaller
```

## Special action

Choose **Install full setup + add user** to:

- install base tools and security stack
- optionally install Docker/Compose
- then prompt for username and password or SSH key

This gives you a working login user after install.

## Supported OS

- Ubuntu 22.04, Ubuntu 20.04
- Debian latest
- CentOS / RHEL
- AlmaLinux / Rocky Linux
- Fedora
- Alpine Linux
- Arch Linux

## Notes

- Use this on an existing VPS or VM instance. It does not create a cloud VPS.
- Best on a fresh server image.
- Keep a second SSH session open when applying SSH hardening.
- If you use the wrapper, run `sudo ./vpsinstaller`.

## Files

- `vps-installer.sh` — main installer script
- `vpsinstaller` — shortcut wrapper to run the installer
- `templates/sshd_hardening.conf` — SSH hardening fragment
- `templates/SSH_HARDENING.md` — notes about SSH hardening

## License

MIT License
