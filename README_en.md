# Gost v3 Interactive Management Tool (Private Backup)

A powerful automation deployment and management script based on [GOST (Go Safety Tunnel)](https://github.com/go-gost/gost) v3. This project aims to provide a stable, fast, and self-hosted GOST deployment solution for individual users.

---

## 🙏 Credits to Original Author

The core functionality of this project is powered by **[GOST](https://github.com/go-gost/gost)**. Sincere thanks to the **[gost-core](https://github.com/go-gost)** team and all contributors.

> **Note**: This repository is a personal backup forked from the official project to ensure binary deployment availability in extreme environments.

---

## 🚀 Quick Start

Run the following command on your VPS to launch the interactive management menu:
```bash
wget -O install_gost.sh https://raw.githubusercontent.com/cntaoge/gost/master/install_gost.sh && chmod +x install_gost.sh && ./install_gost.sh
```

## 🌟 Key Features
Private Security: Installation packages are downloaded from this repository's Release area, independent of external changes.

Smart Update: Automatically detects and notifies you of the latest official releases.

Zero-Residue Cleanup: Automatically removes temporary files after installation to keep the system clean.

Safe Uninstall: Only removes Gost-related files without touching system base components.

## 🛠️ Menu Functionality
Fresh Install: One-click configuration for SOCKS5 proxy and daemon process.

Service Status: View real-time operation logs.

Reload Config: Quickly apply changes made to Systemd.

Restart Service: Fast restart of the proxy process.

Firewall Check: Automatically detects UFW / Firewalld status.

Process Check: Monitor port occupancy and process status.

Check for Updates: Guide to sync with the latest official version.

Public IP: Display the external access address of your VPS.

Complete Uninstall: Safely remove all associated files.

⚖️ Disclaimer
This script is for personal research and learning purposes only. Do not use it for any activities that violate local laws and regulations. Users assume all associated risks.

## 🌟 Support Original Project
If you find Gost useful, please head over to **[go-gost/gost](https://github.com/go-gost/gost)** and give the author a Star!
