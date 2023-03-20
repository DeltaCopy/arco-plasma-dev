#!/usr/bin/env bash

pacman -R kvantum
yay -S --noconfirm --cleanafter lightly-git
yay -S --noconfirm --cleanafter chromium-extension-ublock-origin
