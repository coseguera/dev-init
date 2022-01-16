#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export DEBIAN_FRONTEND=noninteractive

echo "Installing Neovim"

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim

echo "Neovim is installed"