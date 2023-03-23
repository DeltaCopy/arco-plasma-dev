#!/usr/bin/bash
# feed into pacman a list of packages, but   ignore commented packages
set -o pipefail

packages_x86_64=$1

test -s "$packages_file" &&

  while read pkg; do
    echo "$pkg" | grep "^[#;]" || sudo pacman -S "$pkg" --needed --noconfirm
  done < "$packages_x86_64"
