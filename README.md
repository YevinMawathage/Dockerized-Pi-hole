# 🛡️ Dockerized Pi-hole: Network-Wide Ad Blocker

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Pi-hole](https://img.shields.io/badge/Pi--hole-96060C?style=for-the-badge&logo=pi-hole&logoColor=white)
![Bash](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)

## 📖 Overview

This project automates the deployment of a **Pi-hole DNS Sinkhole** inside a virtualized Ubuntu environment using Docker.

Unlike standard setups, this project implements a **Dual-Network Architecture** (Split-Horizon DNS) to bypass physical router restrictions and hardware-level Wi-Fi blocks. It establishes a private, dedicated tunnel between the Windows Host and the Linux VM, ensuring 100% reliable ad-blocking regardless of the physical network connection.

### 🚀 Key Features
- **Automated Deployment:** Full environment provisioning via Bash scripts.
- **Split-Horizon DNS:** Dedicated Host-Only network for stable DNS resolution.
- **Containerized:** Runs efficiently in Docker with persistent storage.
- **Router Agnostic:** Works independently of ISP router limitations.

---

## 🏗 Architecture

The system utilizes a dual-adapter setup to separate internet traffic from DNS queries:

| Interface | Type | Purpose |
|-----------|------|---------|
| **Adapter 1** | NAT | Allows the VM to access the internet (updates, blocklists). |
| **Adapter 2** | Host-Only | Dedicated private route (`192.168.56.x`) for Windows Host DNS queries. |

**Tech Stack:**
* **Host:** Windows 10/11
* **Guest:** Ubuntu Server 20.04/22.04 (VirtualBox)
* **Engine:** Docker & Docker Compose
* **Networking:** Netplan & TCP/IP Routing

---

## ⚙️ Prerequisites

Before running the installation, ensure you have the following:
- **VirtualBox** installed.
- **Ubuntu Server VM** created.
- **Git** installed on the VM (or copy files manually).

---

## 🛠️ Installation Guide

### 1. VirtualBox Network Configuration
**Crucial Step:** Configure the VM network settings *before* powering it on.

1.  Open VirtualBox and ensure the VM is **Powered Off**.
2.  Right-click the VM → **Settings** → **Network**.
3.  Configure the adapters:
    *   **Adapter 1:**
        *   Enable Network Adapter: ✅
        *   Attached to: **NAT**
    *   **Adapter 2:**
        *   Enable Network Adapter: ✅
        *   Attached to: **Host-Only Adapter**
        *   Name: `VirtualBox Host-Only Ethernet Adapter`
4.  Save and **Start** the VM.

### 2. Verify Network Connectivity
Login to the Ubuntu VM and verify the Host-Only IP address:

```bash
ip addr show
# Look for the interface (usually enp0s8) with IP 192.168.56.xxx
```

### 3. Deploy Pi-hole
Clone the repository and run the installation script.

```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd network-ad-blocker

# Make the script executable
chmod +x install.sh

# Run the installer
./install.sh
```

> **Note:** The script checks for Docker availability, installs dependencies if missing, and launches the container using `docker-compose.yml`.

---

## 🔌 Windows Client Configuration

Force Windows to use the Pi-hole VM for DNS resolution.

1.  Press `Win + R`, type `ncpa.cpl`, and hit **Enter**.
2.  Right-click your active connection (Wi-Fi/Ethernet) → **Properties**.
3.  Double-click **Internet Protocol Version 4 (TCP/IPv4)**.
4.  Select **"Use the following DNS server addresses"**:
    *   **Preferred DNS server:** `<YOUR_VM_IP>` (e.g., `192.168.56.101`)
    *   **Alternate DNS server:** `8.8.8.8` (Google DNS as backup)
5.  Click **OK**.

---

## ✅ Verification

Open **Command Prompt** on Windows and run the following tests:

### 1. Test Connectivity
```cmd
ping 192.168.56.xxx
```
*Response should indicate a successful reply.*

### 2. Test Ad Blocking
```cmd
nslookup doubleclick.net
```
**Expected Output:**
```text
Server:  UnKnown
Address: 192.168.56.101

Name:    doubleclick.net
Address: 0.0.0.0
```
*If the address is `0.0.0.0`, the ad blocker is working correctly.*

---

## 📊 Dashboard Access

Manage your Pi-hole instance via the web interface.

*   **URL:** `http://192.168.56.xxx/admin`
*   **Default Password:** `pihole` (Configured in `docker-compose.yml`)

---

## 🔧 Troubleshooting

### VM IP Not Found?
If `ip addr show` does not list the `192.168.56.x` interface, update Netplan:

1.  Edit the Netplan config:
    ```bash
    sudo vi /etc/netplan/00-installer-config.yaml
    ```
2.  Add the configuration for the second interface (`enp0s8`):
    ```yaml
    network:
      ethernets:
        enp0s3:
          dhcp4: true
        enp0s8:
          dhcp4: true
      version: 2
    ```
3.  Apply changes:
    ```bash
    sudo netplan apply
    ```

### Connection Issues?
For testing purposes, you can temporarily disable the firewall:
```bash
sudo ufw disable
```
In Pi-hole Settings > DNS > Interface Settings, select **"Permit all origins"** if you encounter strict origin checks.
