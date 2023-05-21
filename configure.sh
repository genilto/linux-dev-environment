#!/bin/bash
# This is a very simple script to configure my personal development environment
#
# (C) Genilto Vanzin <genilto.vanzin@gmail.com>
set -e
set -o pipefail

export TMP_DIR=/tmp

#####################################################
## 1. fix-cedilla - Ajustar teclado corretamente
## DESCOBRI QUE É SÓ USAR O TECLADO: English (US, intl., with dead keys)
#####################################################
#echo "Configurando teclado..."
#setxkbmap us intl
#echo " -> OK"


#####################################################
# 2. Install Visual Studio Code
# UNINSTALL:
# sudo apt remove code
#####################################################
echo "Baixando e Instalando Visual Studio Code..."
curl --location -s --output $TMP_DIR/vscode.deb --url https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
echo " -> Download OK"
echo " -> Intalando..."
dpkg -i $TMP_DIR/vscode.deb
echo " -> OK"
echo " -> Removendo instalador..."
rm $TMP_DIR/vscode.deb
echo " -> OK"

#####################################################
# 3. Install Docker engine
#####################################################
echo ""
echo "DOCKER ENGINE"

echo "Instalando dependencias APT para HTTPS..."
sudo apt update
sudo apt install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
echo " -> OK"

echo "Adicionando Docker official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo " -> OK"

echo "Configurando Repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  echo " -> OK"

echo "Instalando Docker Engine e docker-compose..."
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose
echo " -> OK"

echo "Configurando acesso do Usuario..."
sudo usermod -aG docker $USER
echo " -> OK... Necessário logout e login novamente."

#####################################################
# Instalando JDK 8
#####################################################
sudo apt install openjdk-8-jdk

#####################################################
# Instalando JDK 11
#####################################################
sudo apt install openjdk-11-jdk

#####################################################
# Maven
#####################################################
sudo apt install maven

#####################################################
# Eclipse
# Download da ultima versão no site do eclipse
# Exemplo: https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2022-06/R/eclipse-jee-2022-06-R-linux-gtk-x86_64.tar.gz&mirror_id=576
#####################################################
cd /opt
sudo tar -xvzf ~/Downloads/eclipse-jee-2022-06-R-linux-gtk-x86_64.tar.gz

# Corrigir erro com wildlfy
echo '--add-opens=java.base/java.security=ALL-UNNAMED' | sudo tee -a /opt/eclipse/eclipse.ini

# Adicionar Ícone no menu
echo "[Desktop Entry]
Name=Eclipse
Type=Application
Exec=/opt/eclipse/eclipse
Terminal=false
Icon=/opt/eclipse/icon.xpm
Comment=Integrated Development Environment
NoDisplay=false
Categories=Development;IDE;
Name[en]=Eclipse
Name[en_US]=Eclipse" | sudo tee -a /opt/eclipse.desktop > /dev/null

sudo desktop-file-install eclipse.desktop

# if you want to remove the RemoteSystemsTempFiles, just go under Window -> Preferences -> General -> Startup and Shutdown and uncheck "RSE UI". 
# Then you can remove the folder and eclipse won't recreate it.

#####################################################
# NVM
#####################################################
sudo apt install curl
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

# Node
nvm install --lts
nvm use --lts

#####################################################
# ZSH
#####################################################
sudo apt install zsh

# Oh My ZSH
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# RESTART

# Enabling Plugins (zsh-autosuggestions & zsh-syntax-highlighting)
# Download zsh-autosuggestions by
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

# Download zsh-syntax-highlighting by
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

nano ~/.zshrc

# Append zsh-autosuggestions & zsh-syntax-highlighting to plugins() like this
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Reopen terminal

# Dracula ZSH Theme - NOT USED
#git clone https://github.com/dracula/zsh.git ~/dracula-themes/zsh
#ln -s ~/dracula-themes/zsh/dracula.zsh-theme $ZSH_CUSTOM/themes/dracula.zsh-theme

# Activating theme
# Go to your ~/.zshrc file and set ZSH_THEME="dracula".

#####################################################
# GNOME TERMINAL Dracula
#####################################################
sudo apt-get install dconf-cli
git clone https://github.com/dracula/gnome-terminal ~/dracula-themes/gnome-terminal
cd ~/dracula-themes/gnome-terminal

# Primeiro - Criar um perfil de cores novo no GNOME TERMINAL
./install.sh

# Adicionar a linha abaixo no .zshrc
eval `/home/genilto/.dir_colors/dircolors`

#####################################################
# To solve the "The following packages have been kept back" problem when using "apt upgrade"
#####################################################
sudo apt-get install aptitude
sudo aptitude safe-upgrade
