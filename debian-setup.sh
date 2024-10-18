#!/bin/bash

set -e  # Exit on any command failure

# Ensure system is updated
sudo apt update && sudo apt full-upgrade -y

# Setting up firewall
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh
sudo ufw allow http
sudo ufw allow https

# Check if UFW is already enabled
if ! sudo ufw status | grep -q "active"; then
    sudo ufw enable
fi
sudo systemctl enable ufw.service --now

# Install preferred software
sudo apt install -y vlc vim neofetch htop clamav clamtk i3 i3blocks flatpak gedit okular parcellite flameshot macchanger ncal pwgen

# Add Flathub repository and install Flatpaks
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update -y
flatpak install -y com.brave.Browser com.bitwarden.desktop io.freetubeapp.FreeTube org.gnome.DejaDup org.libreoffice.LibreOffice

# Remove unwanted software

# List of packages to uninstall
unwanted_packages=(
    "kate"
    "okular"
    "gwenview"
    "krita"
    "kdenlive"
    "kmail"
    "kontact"
    "korganizer"
    "kaddressbook"
    "kamoso"
    "gcompris"
    "kcalc"
    "ktorrent"
    "akregator"
    "kdiskfree"
    "skanlite"
    "spectacle"
    "falkon"
)

# Uninstall each package
for package in "${unwanted_packages[@]}"; do
    echo "Removing $package..."
    sudo apt remove --purge -y "$package"
done

sudo apt purge --autoremove

# Configure ClamAV
sudo systemctl stop clamav-freshclam.service || true
clamtk &  # Runs clamtk in the background
sleep 5   # Give clamtk some time to start up
sudo freshclam

echo "Setup completed successfully!"
