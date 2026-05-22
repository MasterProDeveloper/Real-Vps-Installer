<div align="center">

# 🚀 Real VPS Installer

### ⚡ Powerful • Interactive • Multi-OS VPS Setup Tool

<p align="center">
A premium all-in-one VPS installer with a clean interactive menu, security setup, Docker support, web stacks, and automation tools.
</p>

<p align="center">

![Platform](https://img.shields.io/badge/Platform-Linux-blue)
![Shell](https://img.shields.io/badge/Bash-Script-green)
![Status](https://img.shields.io/badge/Status-Active-success)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Version](https://img.shields.io/badge/Installer-Real%20VPS-red)

</p>

</div>

---

# ✨ Features

🔥 Beautiful colorful interface with animated startup panel  
⚡ One-command installation process  
🖥️ Supports many Linux distributions  
🔐 Security setup and SSH hardening  
🐳 Docker + Docker Compose support  
🌐 LAMP and LEMP web stack installer  
🛡️ Firewall and Fail2Ban protection  
💾 Automatic swap setup  
👤 Create a new sudo user after installation  
🚀 Full setup mode with automation support  
📦 Install common VPS tools instantly  

---

# 🖥️ Supported Operating Systems

✅ Ubuntu 20.04 / 22.04  
✅ Debian  
✅ CentOS / RHEL  
✅ AlmaLinux  
✅ Rocky Linux  
✅ Fedora  
✅ Alpine Linux  
✅ Arch Linux  

---

# ⚡ Quick Start

Clone the repository and run the installer:

```bash
git clone https://github.com/MasterProDeveloper/Real-Vps-Installer.git

cd Real-Vps-Installer

chmod +x vps-installer.sh vpsinstaller

sudo ./vpsinstaller
```

---

# 🌐 Run Directly From GitHub

No need to clone manually.

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/MasterProDeveloper/Real-Vps-Installer/main/vps-installer.sh | sudo bash
```

---

# 🔥 How It Works

Run the installer:

```bash
sudo ./vps-installer.sh
```

Then simply follow the menu:

### Step 1
Choose your operating system  
or allow automatic detection

### Step 2
Select installation actions

Examples:

- Install Docker
- Install Docker Compose
- Setup firewall
- Install security tools
- Install LAMP
- Install LEMP
- Configure SSH

### Step 3

Create a new user account if needed

Done ✅

---

# 🚀 Example Commands

Automatic installation:

```bash
sudo ./vps-installer.sh --auto --non-interactive --yes --docker --compose
```

Dry run mode:

```bash
sudo ./vps-installer.sh --dry-run
```

Run shortcut wrapper:

```bash
sudo ./vpsinstaller
```

---

# ⭐ Full Setup Mode

Choose:

**Install Full Setup + Add User**

This option will:

✅ Install essential packages  
✅ Install security tools  
✅ Configure firewall  
✅ Configure SSH hardening  
✅ Install Docker and Compose (optional)  
✅ Create a new sudo user  
✅ Setup login access  

Perfect for fresh VPS servers.

---

# 📁 Project Structure

```bash
Real-Vps-Installer/
│
├── vps-installer.sh
├── vpsinstaller
│
└── templates/
    ├── sshd_hardening.conf
    └── SSH_HARDENING.md
```

---

# 📄 Important Notes

⚠️ Use on a fresh VPS for best results

⚠️ Keep another SSH session open before applying SSH changes

⚠️ This project configures an existing VPS

⚠️ It does NOT create cloud VPS instances

---

# 🛠 Included Components

- Docker
- Docker Compose
- Firewall tools
- Fail2Ban
- Swap configuration
- Security packages
- SSH hardening
- LAMP stack
- LEMP stack
- User management

---

<div align="center">

# ⭐ Support The Project

If this project helped you, consider giving it a star.

🚀 Your support helps improve the project.

</div>

---

<div align="center">

# 📜 License

MIT License

Made with ❤️ by MasterProDeveloper

</div>
