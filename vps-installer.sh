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
EOF
  exit 0
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --auto)
        WANTED_OS=auto
        shift
        ;;
      --os)
        shift
        WANTED_OS=${1:-}
        shift
        ;;
      --non-interactive)
        NONINTERACTIVE=true
        shift
        ;;
      --yes)
        ASSUME_YES=true
        shift
        ;;
      --docker)
        INSTALL_DOCKER=true
        shift
        ;;
      --compose)
        INSTALL_COMPOSE=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
  done
}

confirm() {
  local prompt=${1:-"Proceed? (y/N): "}
  if $NONINTERACTIVE; then
    $ASSUME_YES && return 0 || return 1
  fi
  read -rp "$prompt" ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

pause() {
  read -rp "Press Enter to continue...";
}

ensure_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Use sudo ./vps-installer.sh"
    exit 1
  fi
}

run_action() {
  if $DRY_RUN; then
    echo "[DRY-RUN] Would run: $*"
  else
    "$@"
  fi
}

print_banner() {
  if [ -t 1 ]; then
    clear
  fi

  local lines=(
    "${CYAN}██████╗ ██╗   ██╗███████╗███████╗ ██████╗ ██╗███████╗███████╗${RESET}"
    "${CYAN}██╔══██╗██║   ██║██╔════╝██╔════╝██╔════╝ ██║██╔════╝██╔════╝${RESET}"
    "${GREEN}██████╔╝██║   ██║█████╗  ███████╗██║  ███╗██║█████╗  ███████╗${RESET}"
    "${GREEN}██╔══██╗██║   ██║██╔══╝  ╚════██║██║   ██║██║██╔══╝  ╚════██║${RESET}"
    "${YELLOW}██████╔╝╚██████╔╝███████╗███████║╚██████╔╝██║███████╗███████║${RESET}"
    "${YELLOW}╚═════╝  ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝╚══════╝╚══════╝${RESET}"
  )

  for line in "${lines[@]}"; do
    printf '%b\n' "$line"
    sleep 0.03
  done
  echo
  printf '%b\n' "${MAGENTA}${BOLD}Created by MasterProDeveloper${RESET}"
  printf '%b\n' "${GREEN}Use the panel to choose OS, install base packages, and create a login user.${RESET}"
  echo
}

detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_ID=${ID,,}
    DISTRO_NAME=${NAME}
    DISTRO_VER=${VERSION_ID}
  else
    DISTRO_ID="unknown"
    DISTRO_NAME="Unknown"
    DISTRO_VER=""
  fi
}

apt_update_install() {
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y "$@"
}

dnf_update_install() {
  dnf -y upgrade --refresh || true
  dnf -y install "$@"
}

yum_update_install() {
  yum -y update || true
  yum -y install "$@"
}

apk_update_install() {
  apk update
  apk upgrade
  apk add --no-cache "$@"
}

pacman_update_install() {
  pacman -Syu --noconfirm
  pacman -S --noconfirm "$@"
}

install_common() {
  echo "Installing common packages: curl, wget, git, sudo, ca-certificates"
  case "$DISTRO_ID" in
    ubuntu|debian)
      apt_update_install curl wget git sudo ca-certificates gnupg lsb-release
      ;;
    centos|rhel|rocky|almalinux)
      yum_update_install curl wget git sudo ca-certificates
      ;;
    fedora)
      dnf_update_install curl wget git sudo ca-certificates
      ;;
    alpine)
      apk_update_install curl wget git sudo ca-certificates
      ;;
    arch)
      pacman_update_install curl wget git sudo ca-certificates
      ;;
    *)
      echo "Unknown distro; attempting generic install with apt-get"
      apt_update_install curl wget git sudo ca-certificates || true
      ;;
  esac
}

install_swap() {
  if $NONINTERACTIVE && ! $ASSUME_YES; then
    echo "Skipping swap in non-interactive mode (no --yes)"
    return
  fi

  local do_swap=false
  if $NONINTERACTIVE; then
    $ASSUME_YES && do_swap=true || do_swap=false
  else
    read -rp "Create 1G swap file? (y/N): " DO_SWAP
    [[ "$DO_SWAP" =~ ^[Yy]$ ]] && do_swap=true || do_swap=false
  fi

  if ! $do_swap; then
    echo "Skipping swap creation"
    return
  fi

  if [ -f /swapfile ]; then
    echo "/swapfile already exists"
    if ! swapon --show=NAME | grep -q "/swapfile"; then
      echo "Attempting to enable existing /swapfile"
      chmod 600 /swapfile || true
      mkswap -f /swapfile || true
      if swapon /swapfile 2>/dev/null; then
        echo "/swapfile enabled"
      else
        echo "Failed to enable existing /swapfile; skipping"
      fi
    else
      echo "/swapfile already active"
    fi
    return
  fi

  echo "Creating 1G /swapfile"
  if ! fallocate -l 1G /swapfile 2>/dev/null; then
    echo "fallocate failed, using dd (slower)"
    dd if=/dev/zero of=/swapfile bs=1M count=1024 status=progress || dd if=/dev/zero of=/swapfile bs=1M count=1024
  fi
  chmod 600 /swapfile
  if ! mkswap /swapfile 2>/dev/null; then
    echo "mkswap failed, trying with -f"
    mkswap -f /swapfile || { echo "mkswap ultimately failed"; return 1; }
  fi
  if swapon /swapfile 2>/dev/null; then
    if ! grep -q '/swapfile' /etc/fstab; then
      echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi
    echo "Swap created and enabled"
  else
    echo "swapon failed; leaving /swapfile in place for manual inspection"
  fi
}

install_firewall() {
  echo "Configuring basic firewall"
  case "$DISTRO_ID" in
    ubuntu|debian)
      apt_update_install ufw || true
      ufw allow OpenSSH || true
      ufw --force enable || true
      ;;
    centos|rhel|rocky|almalinux|fedora)
      if command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --permanent --add-service=ssh || true
        firewall-cmd --reload || true
      else
        yum_update_install firewalld || dnf_update_install firewalld || true
        systemctl enable --now firewalld || true
        firewall-cmd --permanent --add-service=ssh || true
        firewall-cmd --reload || true
      fi
      ;;
    alpine)
      apk_update_install openrc iptables || true
      ;;
    arch)
      pacman_update_install firewalld || true
      systemctl enable --now firewalld || true
      firewall-cmd --permanent --add-service=ssh || true
      firewall-cmd --reload || true
      ;;
    *)
      echo "No firewall configuration for this distro"
      ;;
  esac
}

apply_ssh_hardening() {
  local conf_src="$REPO_DIR/templates/sshd_hardening.conf"
  if [ ! -f "$conf_src" ]; then
    echo "Hardening fragment not found: $conf_src"
    return 1
  fi
  if grep -q "# SSH hardening fragment" /etc/ssh/sshd_config 2>/dev/null || grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
    echo "SSH hardening appears already applied (skipping append)."
    return 0
  fi
  echo "Backing up /etc/ssh/sshd_config to /etc/ssh/sshd_config.bak"
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak || true
  echo "Appending hardening fragment. Keep an active session when applying."
  printf "\n# SSH hardening fragment - appended by vps-installer\n" >> /etc/ssh/sshd_config
  cat "$conf_src" >> /etc/ssh/sshd_config
  if systemctl restart sshd 2>/dev/null; then
    echo "sshd restarted"
  else
    systemctl restart ssh 2>/dev/null || true
  fi
  echo "SSH hardening applied (verify before closing sessions)."
}

create_sudo_user() {
  if $NONINTERACTIVE; then
    NEW_USER=${NEW_USER:-vpsadmin}
    if id -u "$NEW_USER" >/dev/null 2>&1; then
      echo "User $NEW_USER already exists"
      return
    fi
    useradd -m -s /bin/bash -G sudo "$NEW_USER"
    echo "Created user $NEW_USER (no password). Add SSH keys to /home/$NEW_USER/.ssh/authorized_keys"
    return
  fi

  read -rp "New username: " NEW_USER
  if [ -z "$NEW_USER" ]; then
    echo "No username entered, skipping user creation."
    return
  fi
  if id -u "$NEW_USER" >/dev/null 2>&1; then
    echo "User $NEW_USER already exists"
    return
  fi

  read -rp "Create with password-based login? (y/N): " PASS_OPT
  if [[ "$PASS_OPT" =~ ^[Yy]$ ]]; then
    read -rsp "Password for $NEW_USER: " PW
    echo
    useradd -m -s /bin/bash -G sudo "$NEW_USER"
    echo "$NEW_USER:$PW" | chpasswd
  else
    useradd -m -s /bin/bash -G sudo "$NEW_USER"
    mkdir -p /home/$NEW_USER/.ssh
    read -rp "Paste public SSH key (or leave empty to skip): " PUBKEY
    if [ -n "$PUBKEY" ]; then
      echo "$PUBKEY" > /home/$NEW_USER/.ssh/authorized_keys
      chown -R "$NEW_USER":"$NEW_USER" /home/$NEW_USER/.ssh
      chmod 700 /home/$NEW_USER/.ssh
      chmod 600 /home/$NEW_USER/.ssh/authorized_keys
    fi
  fi
  echo "User $NEW_USER created and added to sudoers (wheel on some systems)."
}

install_lemp() {
  echo "Installing LEMP stack (nginx, mariadb, php)"
  case "$DISTRO_ID" in
    ubuntu|debian)
      apt_update_install nginx mariadb-server php-fpm php-mysql
      systemctl enable --now nginx mariadb
      ;;
    centos|rhel|rocky|almalinux)
      yum_update_install nginx mariadb-server php-fpm php-mysqlnd
      systemctl enable --now nginx mariadb
      ;;
    alpine)
      apk_update_install nginx mariadb php-fpm php-mysqli
      rc-service nginx start || systemctl enable --now nginx || true
      ;;
    *)
      echo "LEMP install not supported on this distro via script."
      ;;
  esac
}

install_lamp() {
  echo "Installing LAMP stack (apache, mariadb, php)"
  case "$DISTRO_ID" in
    ubuntu|debian)
      apt_update_install apache2 mariadb-server php libapache2-mod-php php-mysql
      systemctl enable --now apache2 mariadb
      ;;
    centos|rhel|rocky|almalinux)
      yum_update_install httpd mariadb-server php php-mysqlnd
      systemctl enable --now httpd mariadb
      ;;
    alpine)
      apk_update_install apache2 mariadb php php-apache2
      rc-service apache2 start || systemctl enable --now apache2 || true
      ;;
    *)
      echo "LAMP install not supported on this distro via script."
      ;;
  esac
}

install_netdata() {
  echo "Installing Netdata (one-line installer)"
  bash <(curl -Ss https://my-netdata.io/kickstart.sh) --dont-wait || true
}

configure_unattended_upgrades() {
  echo "Configuring unattended-upgrades (Debian/Ubuntu)"
  case "$DISTRO_ID" in
    ubuntu|debian)
      apt_update_install unattended-upgrades apt-listchanges || true
      dpkg-reconfigure -plow unattended-upgrades || true
      ;;
    *)
      echo "Unattended upgrades configuration not supported for $DISTRO_ID"
      ;;
  esac
}

install_fail2ban() {
  echo "Installing fail2ban"
  case "$DISTRO_ID" in
    ubuntu|debian)
      apt_update_install fail2ban || true
      systemctl enable --now fail2ban || true
      ;;
    centos|rhel|rocky|almalinux|fedora)
      yum_update_install epel-release || true
      yum_update_install fail2ban || dnf_update_install fail2ban || true
      systemctl enable --now fail2ban || true
      ;;
    alpine)
      apk_update_install fail2ban || true
      ;;
    arch)
      pacman_update_install fail2ban || true
      ;;
    *)
      echo "Skipping fail2ban for unknown distro"
      ;;
  esac
}

install_docker() {
  echo "Installing Docker (official script will be used)"
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sh /tmp/get-docker.sh
  if [ -n "${SUDO_USER:-}" ]; then
    usermod -aG docker "$SUDO_USER" || true
  fi
  systemctl enable --now docker || true
}

install_docker_compose() {
  echo "Installing Docker Compose (v2 plugin)"
  if command -v docker >/dev/null 2>&1; then
    mkdir -p /usr/local/lib/docker/cli-plugins || true
    curl -SL "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose || true
    echo "Docker Compose installed"
  else
    echo "Docker not found - skipping Compose"
  fi
}

ubuntu_install() {
  echo "Running Ubuntu ($DISTRO_VER) preparations"
  install_common
  install_swap
  install_firewall
  install_fail2ban
  if $INSTALL_DOCKER; then
    install_docker
  fi
  if $INSTALL_COMPOSE; then
    install_docker_compose
  fi
  echo "Ubuntu setup complete"
}

debian_install() {
  echo "Running Debian ($DISTRO_VER) preparations"
  install_common
  install_swap
  install_firewall
  install_fail2ban
  if $INSTALL_DOCKER; then
    install_docker
  fi
  if $INSTALL_COMPOSE; then
    install_docker_compose
  fi
  echo "Debian setup complete"
}

centos_install() {
  echo "Running CentOS/RHEL family preparations"
  yum_update_install epel-release || true
  install_common
  install_swap
  install_firewall
  install_fail2ban
  if $INSTALL_DOCKER; then
    install_docker
  fi
  if $INSTALL_COMPOSE; then
    install_docker_compose
  fi
  echo "CentOS/RHEL setup complete"
}

alpine_install() {
  echo "Running Alpine preparations"
  install_common
  install_swap
  install_firewall
  install_fail2ban
  if $INSTALL_DOCKER; then
    install_docker
  fi
  echo "Alpine setup complete"
}

arch_install() {
  echo "Running Arch Linux preparations"
  install_common
  install_swap
  install_firewall
  install_fail2ban
  if $INSTALL_DOCKER; then
    install_docker
  fi
  echo "Arch setup complete"
}

generic_install() {
  echo "Generic installer: will attempt best-effort setup"
  install_common
  install_swap
  install_firewall
  install_fail2ban
  echo "Generic setup complete"
}

install_full_recommended() {
  echo "Running full recommended install for $DISTRO_NAME $DISTRO_VER ($DISTRO_ID)"
  install_common
  install_swap
  install_firewall
  install_fail2ban
  if $INSTALL_DOCKER; then
    install_docker
  fi
  if $INSTALL_COMPOSE; then
    install_docker_compose
  fi
  echo "Full install complete. Next step: create sudo user."
}

install_full_with_user() {
  install_full_recommended
  create_sudo_user
}

full_panel() {
  PS3="Choose OS (or 0 to exit): "
  os_options=("Auto-detect" "Ubuntu 22.04" "Ubuntu 20.04" "Debian" "CentOS/RHEL" "AlmaLinux/Rocky" "Fedora" "Alpine" "Arch" "Exit")
  select o in "${os_options[@]}"; do
    case $REPLY in
      1)
        detect_distro
        echo "Detected: $DISTRO_NAME $DISTRO_VER ($DISTRO_ID)"
        break
        ;;
      2)
        DISTRO_ID=ubuntu
        DISTRO_VER=22.04
        break
        ;;
      3)
        DISTRO_ID=ubuntu
        DISTRO_VER=20.04
        break
        ;;
      4)
        DISTRO_ID=debian
        break
        ;;
      5)
        DISTRO_ID=centos
        break
        ;;
      6)
        DISTRO_ID=centos
        break
        ;;
      7)
        DISTRO_ID=fedora
        break
        ;;
      8)
        DISTRO_ID=alpine
        break
        ;;
      9)
        DISTRO_ID=arch
        break
        ;;
      10|0)
        echo "Exiting"
        return 0
        ;;
      *)
        echo "Invalid"
        ;;
    esac
  done

  PS3="Choose action (or 0 to exit): "
  actions=("Install base" "Install LEMP" "Install LAMP" "Apply SSH hardening" "Create sudo user" "Install Docker" "Install Docker Compose" "Install Netdata" "Configure unattended-upgrades" "Install full setup + add user" "Exit")
  select a in "${actions[@]}"; do
    case $REPLY in
      1)
        run_action generic_install
        break
        ;;
      2)
        run_action install_lemp
        break
        ;;
      3)
        run_action install_lamp
        break
        ;;
      4)
        run_action apply_ssh_hardening
        break
        ;;
      5)
        run_action create_sudo_user
        break
        ;;
      6)
        run_action install_docker
        break
        ;;
      7)
        run_action install_docker_compose
        break
        ;;
      8)
        run_action install_netdata
        break
        ;;
      9)
        run_action configure_unattended_upgrades
        break
        ;;
      10)
        run_action install_full_with_user
        break
        ;;
      11|0)
        echo "Exiting"
        return 0
        ;;
      *)
        echo "Invalid"
        ;;
    esac
  done
}

show_menu() {
  print_banner
  full_panel
}

main() {
  ensure_root
  parse_args "$@"
  echo "VPS Installer — interactive helper for common setup tasks"
  echo
  if [ -n "$WANTED_OS" ]; then
    if [ "$WANTED_OS" = "auto" ]; then
      detect_distro
    else
      case "$WANTED_OS" in
        ubuntu:*) DISTRO_ID=ubuntu; DISTRO_VER=${WANTED_OS#*:} ;;
        ubuntu) DISTRO_ID=ubuntu ;;
        debian) DISTRO_ID=debian ;;
        centos|rhel) DISTRO_ID=centos ;;
        rocky|almalinux) DISTRO_ID=centos ;;
        fedora) DISTRO_ID=fedora ;;
        alpine) DISTRO_ID=alpine ;;
        arch) DISTRO_ID=arch ;;
        *) DISTRO_ID=generic ;;
      esac
    fi

    case "$DISTRO_ID" in
      ubuntu)
        run_action ubuntu_install
        ;;
      debian)
        run_action debian_install
        ;;
      centos)
        run_action centos_install
        ;;
      alpine)
        run_action alpine_install
        ;;
      arch)
        run_action arch_install
        ;;
      fedora)
        run_action bash -c 'dnf_update_install && install_common'
        ;;
      *)
        run_action generic_install
        ;;
    esac
  else
    show_menu
  fi

  echo "Done. See README.md for notes and templates in the templates/ folder."
}

main "$@"
