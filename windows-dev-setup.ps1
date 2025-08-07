# Windows AI & IoT Developer Setup Script (PowerShell + Chocolatey)
# License: Free, Open Source or Community Tools Only
# Target OS: Windows 10/11 Home (PowerShell Admin Mode Required)

# --- Step 1: Install Chocolatey (if not already installed) ---
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# --- Step 2: Install Core Development Tools ---
choco install -y git
choco install -y vscodium
choco install -y obsidian
choco install -y nodejs-lts
choco install -y python
choco install -y dotnet-sdk
choco install -y rust

# --- Step 3: Install WSL2 + Ubuntu ---
wsl --install -d Ubuntu-24.04

# --- Step 4: Install Docker (WSL2 Backend) ---
choco install -y docker-desktop
Start-Sleep -Seconds 5
Write-Host "Please enable WSL2 integration for Ubuntu in Docker Desktop settings manually."

# --- Step 5: Install Arduino IDE (Graphical) ---
choco install -y arduino

# --- Step 6: Optional Tools ---
Write-Host "Download LM Studio (Free LLM Runner) from: https://lmstudio.ai/download"

# --- Final Notes ---
Write-Host "[CHECKMARK] Base setup for Windows AI & IoT Development Complete!"
Write-Host "[BRAIN] For Python/AI development, open Ubuntu (WSL2) and run the Linux script provided."
Write-Host "[GEAR] Run VSCodium, Obsidian, and Arduino from Start Menu"
Write-Host "[PACKAGE] Docker and GitHub CLI available after reboot."

# --- Optional: Reboot ---
# Restart-Computer -Force
