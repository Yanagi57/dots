#!/usr/bin/zsh
#
# Update system
paru -Syu 
# Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq)

# Remove pacman cache, keep two versions
sudo paccache -k 2 -r

# Remove temp dirs
rm -rf ~/.java ~/.m2

# Remove paru cache
print -n "Remove paru cache? Not recommended if things ain't broke [y/N]: "
read confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    paru -Scc
else
    echo "Skipping paru cache removal."
fi

# Remove podman cache
print -n "Remove all podman images? You will have to rebuild everything if you remove them [y/N]: "
read confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    sudo podman rmi -a && podman rmi -a
else
    echo "Skipping podman images removal."
fi

echo "Remove unused podman data?"
sudo podman system prune && podman system prune

echo "Remove unused podman volumes?"
sudo podman volume prune && podman volume prune
