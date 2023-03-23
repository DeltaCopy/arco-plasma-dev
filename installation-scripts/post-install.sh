#!/usr/bin/env bash
set -o pipefail
konsave_import_file=$1
arch_packages=("kvantum")
aur_packages=("lightly-git" "chromium-extension-ublock-origin" "libva-nvidia-driver")

if [ ! -z "$konsave_backup" ]; then
  if test -s "$konsave_import_file"; then
    konsave -i "$konsave_import_file"
  fi
fi


for arch_pkg in "${arch_packages[@]}"; do
  pacman -R --noconfirm "$arch_pkg"
done

for aur_pkg in "${aur_packages[@]}"; do
  yay -S --noconfirm --cleanafter "$aur_pkg"
done
