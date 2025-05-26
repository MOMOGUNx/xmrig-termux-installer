#!/bin/bash

clear
echo -e "\e[1;32m=========================================="
echo -e "           Script by @MOMOGUNx"
echo -e "           GOD IS ALWAYS GOOD"
echo -e "==========================================\e[0m"
sleep 2

echo -e "\e[1;33mPreparing for installation...\e[0m"
sleep 1

# Install git && curl
sudo apt update 
sudo apt install -y git curl

# Semak whitelist
read -p "Masukkan username anda: " username
ALLOWED_URL="https://raw.githubusercontent.com/MOMOGUNx/xmrig-termux-installer/main/allowed_users.txt"

if curl -s "$ALLOWED_URL" | grep -qw "$username"; then
    echo "Akses dibenarkan. Meneruskan pemasangan..."
else
    echo "Maaf, anda tidak dibenarkan memasang skrip ini."
    exit 1
fi

# Clone repo XMRig
echo "Cloning repo XMRig..."
if ! git clone https://github.com/xmrig/xmrig.git; then
    echo "Gagal clone repo."
    exit 1
fi

cd xmrig || { echo "Direktori xmrig tidak wujud. Clone gagal?"; exit 1; }

# Install dependensi
echo ""
echo "Memasang pakej diperlukan..."
sudo apt update
sudo apt install -y cmake build-essential clang libssl-dev libhwloc-dev libuv1-dev automake autoconf libtool

# Compile XMRig
echo ""
echo "Memulakan proses compile XMRig (sabar, ini mungkin ambil masa)..."
mkdir -p build && cd build
cmake -DWITH_HWLOC=OFF ..
make -j"$(nproc)"

# Download menu
echo ""
echo "Muat turun menu..."
mkdir -p ~/xmrig
curl -s -o ~/xmrig/menu.sh https://raw.githubusercontent.com/MOMOGUNx/xmrig-termux-installer/main/menu.sh
chmod +x ~/xmrig/menu.sh

#Bashrc
if ! grep -q "alias menu=" ~/.bashrc; then
    echo "alias menu='bash \$HOME/xmrig/menu.sh'" >> ~/.bashrc
    echo "Alias 'menu' ditambah ke .bashrc"
else
    echo "Alias 'menu' sudah wujud dalam .bashrc"
fi

echo ""
echo "Installation done"
echo "reboot..please wait.."
sleep 3
clear
reboot
