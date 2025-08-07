# ai-cyber-iot-dev-setup

# 💻 Windows AI & IoT Developer Setup

PowerShell script to bootstrap a complete AI, IoT, and Cybersecurity developer environment on **Windows 10/11 Home** using only **free, open-source, or community edition** tools.

---

## 📦 What’s Included

- **Package Manager**: Chocolatey
- **Dev Tools**: Git, VSCodium, Obsidian, Node.js, Python, Rust, .NET SDK
- **Linux Support**: WSL2 + Ubuntu 24.04
- **Containerization**: Docker Desktop (WSL2 backend)
- **Embedded Dev**: Arduino IDE
- **AI Tools**: Manual download of LM Studio (local LLM runner)

---

## ⚙️ How to Use

### 🪟 Run in PowerShell (Admin)
```powershell
Invoke-WebRequest https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/windows-dev-setup.ps1 -OutFile setup.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
./setup.ps1
```

> 💡 Replace `YOUR_USERNAME` and `YOUR_REPO` with your actual GitHub username/repo name.

---

## 📘 After Installation
- Use **VSCodium**, **Arduino**, and **Obsidian** from the Start Menu
- Launch **Ubuntu (WSL2)** to start developing in Linux
- Enable **WSL2 integration** in Docker Desktop manually
- Download **LM Studio** from: [https://lmstudio.ai/download](https://lmstudio.ai/download)

---

## ✅ Requirements
- Windows 10/11 Home
- Admin access to PowerShell
- Virtualization enabled (for WSL2 + Docker)

---

## 🛡️ License
This script only installs **unlicensed**, **open-source**, or **community** software. You are free to use and modify it.

---

## 🌐 Contributing
Pull requests and issues welcome! Help us improve the base setup for AI + IoT devs on Windows.
