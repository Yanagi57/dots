# My dotfiles

This directory contains the dotfiles for my system

## Theme

I use the [everforest](https://github.com/sainnhe/everforest) theme for all my applications that support themes.

- Everforest for KDE Plasma (.local/share/color-schemes)
- Everforest for Kitty (.config/kitty)
- Everforest for Neovim (.config/nvim/after/plugin/colors.lua)
- Everforest for Wofi (.config/wofi/style.css)
- Everforest for Hyprpanel (Set in hyprpanel settings)

## Setup for a New System

Make sure you have git installed, then run the following commands

```sh
git clone https://github.com/Yanagi57/dots ~/dotfiles
cd ~/dotfiles
chmod +x bin/setup.sh
./bin/setup_desktop.sh
```

> Note: use this for new system only, as it will mess with your existing configurations

## Usage

As this repo has been growing for a while, it is not recommended to clone it to an existing
system. Instead, you can copy some configurations you want from this repo. I recommend checking
out the `.config` directory for application configurations.

Here's a list of applications I use and their configurations can be found in this repo:

- Zsh (with custom theme, native)
- Neovim
- Kitty (with everforest theme)
- Hyprland
- Hyprpanel (with everforest theme)
- Wlogout (with custom everforest theme)
- Hyprpaper
- Wofi (with custom everforest theme)

## Special Thanks

I made this repo because I watched this Youtube video made by [Dreams of Autonomy](https://www.youtube.com/watch?v=y6XCebnB9gs)

