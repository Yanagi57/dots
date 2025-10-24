#!/usr/bin/env bash

set -euo pipefail

git submodule update --init --recursive

read -p "This will install and configure your system. Proceed? (y/n) " confirm
[[ "$confirm" == "y" ]] || exit 1

# Install kde
sudo pacman -S --needed libnotify ly kitty openssh dolphin kde-plasma-desktop plasma-pa bluedevil spectacle udisks2 stow rustup --noconfirm
sudo systemctl enable ly.service
# Redirect ly-session.log to cache
echo "session_log = /$HOME/.cache/ly-session.log" | sudo tee -a /etc/ly/config.ini

stow -d "$HOME/dotfiles" .

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
# Use XDG dirs for completion and history files
[ -d "$XDG_STATE_HOME"/zsh ] || mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
[ -d "$XDG_CACHE_HOME/zsh" ] || mkdir -p "$XDG_CACHE_HOME/zsh"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PATH="$CARGO_HOME:$PATH"
rustup default stable
rustup component add rust-analyzer # For neovim

# drivers
sudo pacman -S --needed sof-firmware pipewire pipewire-audio pipewire-pulse libva-nvidia-driver ufw mesa --noconfirm
sudo systemctl enable ufw.service 

if [ "$(systemd-detect-virt)" = "none" ]; then
  echo "Enabling UFW..."
  sudo ufw default deny 
  sudo ufw allow from 192.168.0.0/24
  sudo ufw limit ssh 
  sudo ufw enable
else
  echo "Skipping UFW (running inside a container/VM)"
fi

# Paru
if ! command -v paru &> /dev/null; then
    echo "==> Paru not found. Installing..."
    sudo pacman -S --needed base-devel --noconfirm
    git clone https://aur.archlinux.org/paru.git ~/paru
    cd ~/paru
    makepkg -si --noconfirm
    cd ~
    rm -rf ~/paru
else
    echo "==> Paru already installed."
fi

# Apps
paru --needed --noconfirm -S bat zellij zen-browser-bin neovim fzf zsh wl-clipboard ripgrep yazi

# Fonts & Text
paru --needed --noconfirm -S adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts noto-fonts-emoji ttf-roboto ttf-firacode-nerd fcitx5-im fcitx5-rime fcitx5-skin-fluentdark-git 

# Required apps
paru --needed --noconfirm -S brightnessctl network-manager-applet btop fastfetch mission-center nwg-look everforest-gtk-theme-git

# Dev
sudo pacman -S mise

# PulseAudio config for hyprland
echo "cookie-file = ~/.config/pulse/cookie" | sudo tee -a /etc/pulse/client.conf

echo "\n\nDone, enjoy your new system\n\n"

