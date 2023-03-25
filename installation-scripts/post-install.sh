#!/usr/bin/env bash
set -o pipefail

arch_packages=("kvantum")
aur_packages=("lightly-git" "chromium-extension-ublock-origin" "libva-nvidia-driver")

for arch_pkg in "${arch_packages[@]}"; do
  pacman -R --noconfirm "$arch_pkg"
done

for aur_pkg in "${aur_packages[@]}"; do
  yay -S --noconfirm --cleanafter "$aur_pkg"
done
