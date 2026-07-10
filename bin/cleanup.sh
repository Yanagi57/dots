#!/usr/bin/zsh

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


# Update system
paru -Syu
# Remove orphaned packages
sudo pacman -Rns $(pacman -Qdtq)

# update rust
rustup update stable
rustup update nightly

# update binaries installed by cargo
cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')

# Remove pacman cache, keep two versions
sudo paccache -k 2 -r

# Remove paru cache
print -n "Remove paru cache? Not recommended if things ain't broke [y/N]: "
read confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    paru -Scc
else
    echo "Skipping paru cache removal."
fi

