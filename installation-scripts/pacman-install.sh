#!/usr/bin/bash
# feed into pacman a list of packages, but   ignore commented packages
# used for installing packages on a vanilla archlinux system
set -o pipefail

pacman_conf="/etc/pacman.conf"
arcolinux_mirrorlist="/etc/pacman.d/arcolinux-mirrorlist"
if test -s "$pacman_conf"; then
  cat "$pacman_conf" | grep -qw "arcolinux_repo_iso" && cat "$pacman_conf" | grep -qw "arcolinux_repo" && cat "$pacman_conf" | grep -qw "arcolinux_repo_3party" && echo "[INFO] ArcoLinux setup inside $pacman_conf"
fi


# if this is a vanilla arch install setup pacman.conf, and import key

test -s "$arcolinux_mirrorlist" ||
  cat << EOF > /etc/pacman.d/arcolinux-mirrorlist
  # Europe Netherlands Amsterdam
#Server = https://ant.seedhost.eu/arcolinux/$repo/$arch

# Gitlab United States
Server = https://gitlab.com/arcolinux/$repo/-/raw/main/$arch

# Sweden - accum.se
Server = https://mirror.accum.se/mirror/arcolinux.info/$repo/$arch

# Europe Belgium Brussels
Server = https://ftp.belnet.be/arcolinux/$repo/$arch

# Australia
Server = https://mirror.aarnet.edu.au/pub/arcolinux/$repo/$arch

# South Korea
Server = https://mirror.funami.tech/arcolinux/$repo/$arch

# Singapore
Server = https://mirror.jingk.ai/arcolinux/$repo/$arch

# United States San Francisco - no xlarge repo here
Server = https://arcolinux.github.io/$repo/$arch
EOF

test -s "$arcolinux_mirrorlist" && echo "[INFO] ArcoLinux mirrorlist setup"


packages_x86_64=$1
if [ -f "$packages_x86_64" ]; then
 while read pkg; do

    echo "$pkg" | grep "^[#;]" || sudo pacman -S "$pkg" --needed --noconfirm
 done < "$packages_x86_64"
fi
