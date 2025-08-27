# 🧠🔐📡 AI + IoT + Cybersecurity Developer Environment (Windows + Ubuntu WSL2)

This repository provides a **complete, free, and open-source development setup** for **AI, IoT, and Cybersecurity** on **Windows 10/11 Home** using **PowerShell** and **WSL2 (Ubuntu 24.04)**.

---

## 📦 What's Included

### 🪟 Windows (PowerShell Script)
- **Package Manager**: Chocolatey
- **Dev Tools**: Git, VSCodium, Obsidian, Node.js, Python, Rust, .NET SDK
- **Linux Integration**: WSL2 + Ubuntu 24.04
- **Containerization**: Docker Desktop (WSL2 backend)
- **Embedded Development**: Arduino IDE
- **AI Runner**: Manual LM Studio (local LLM runner)

### 🐧 Ubuntu 24.04 (WSL2 Script Stack)
- **AI/ML Tools**: PyTorch, Transformers, Langchain, Jupyter Lab, Conda
- **IoT Tools**: PlatformIO, Node-RED, Mosquitto MQTT
- **Cyber Tools**: nmap, hashcat, Docker, GitHub CLI
- **Databases**: PostgreSQL, MariaDB, MongoDB, Redis
- **Dashboards**: Adminer, Mongo Express, Redis Commander, InfluxDB, Grafana, Portainer, Dozzle

---

## ⚙️ Setup Instructions

### ✅ Prerequisites
- **Windows 10/11 Home**
- **Admin access to PowerShell**
- **Virtualization enabled** in BIOS
- **Internet access**

---

## 🪟 Step 1: Run Windows Dev Setup

Open **PowerShell as Administrator** and run:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/windows-dev-setup.ps1 -OutFile setup.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
./setup.ps1
```

> Replace `YOUR_USERNAME` and `YOUR_REPO` with your actual GitHub info.

This installs:
- Chocolatey + Dev Tools
- WSL2 + Ubuntu 24.04
- Docker Desktop (WSL2 backend)
- Arduino IDE, Git, VSCodium, Node.js, Python, etc.

---

## 🐧 Step 2: Ubuntu (WSL2) Environment Setup

### 2.1 Clone this repo in Ubuntu:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
chmod +x *.sh
```

### 2.2 Run Setup Scripts:

```bash
./ubuntu-ai-iot-setup.sh        # AI/IoT/Cyber tools + conda env
./linux-db-setup.sh             # Databases + Adminer, Redis Commander
./linux-dashboard-setup.sh      # Grafana, InfluxDB, Portainer, Dozzle
```

> Optionally use `./run-all.sh` to launch all containers at once.

---

## 🧠 Start AI Dev Session

```bash
conda activate ai-dev
jupyter lab
```

Use this for AI/ML notebooks, testing LLMs locally, and sensor data analysis.

---

## 🌐 Dashboards

| Tool            | URL                      | Description                 |
|-----------------|--------------------------|-----------------------------|
| Adminer         | http://localhost:8080    | SQL DB manager              |
| Mongo Express   | http://localhost:8081    | MongoDB viewer              |
| Redis Commander | http://localhost:8082    | Redis key UI                |
| Portainer       | http://localhost:9000    | Docker container manager    |
| Dozzle          | http://localhost:9999    | Real-time log viewer        |
| InfluxDB        | http://localhost:8086    | Time-series data storage    |
| Grafana         | http://localhost:3000    | Metrics & visualization     |

---

## 📥 Optional: Local LLM (LM Studio)

Download LM Studio from [https://lmstudio.ai/download](https://lmstudio.ai/download) and run LLMs locally via GPU/CPU.

---

## 🔁 Restart Docker Services

```bash
./run-all.sh
```

---

## 🛡️ License

This project uses **only open-source or community software**. You are free to use, modify, and redistribute it.

---

## 🤝 Contributing

Pull requests, issues, and suggestions are welcome to improve this modern, robust AI + IoT + Cybersecurity development stack.

---

© 2025 [prmdpandit] — Free and Open Source