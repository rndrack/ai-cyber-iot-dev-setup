#!/bin/bash

# AI & IoT Developer Environment Setup (Open Source / Community Tools)
# Target OS: Ubuntu 24.04 LTS (WSL2 recommended for Windows users)

# Update System
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget git unzip zip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install languages
sudo apt install -y python3 python3-pip python3-venv
wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update && sudo apt install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0
sudo apt install -y g++ cmake
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# Miniconda & AI tools
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
rm miniconda.sh
export PATH="$HOME/miniconda/bin:$PATH"
conda create -y -n ai-dev python=3.11
source "$HOME/miniconda/bin/activate" ai-dev
pip install torch torchvision torchaudio transformers datasets jupyterlab langchain llama-index

# Ollama
curl https://ollama.com/install.sh | sh
echo "➡ Download LM Studio (optional): https://lmstudio.ai/download"

# IoT tools
pip install platformio
sudo apt install -y mosquitto mosquitto-clients
sudo npm install -g --unsafe-perm node-red
sudo apt install -y screen minicom

# Cybersecurity tools
sudo apt install -y wireshark nmap net-tools john hashcat
echo "➡ For advanced pentesting, use Kali Linux in Docker or VM."

# DevOps tools
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
sudo apt install -y docker-compose
sudo apt install -y git
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh

# VSCodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor > codium-archive-keyring.gpg
sudo install -o root -g root -m 644 codium-archive-keyring.gpg /usr/share/keyrings/
echo 'deb [signed-by=/usr/share/keyrings/codium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update && sudo apt install -y codium
echo "➡ Download Obsidian (free) from: https://obsidian.md/download"

# Cleanup
sudo apt autoremove -y
echo "✅ Setup complete. Use 'conda activate ai-dev' to begin AI development."
