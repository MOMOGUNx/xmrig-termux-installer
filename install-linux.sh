#!/bin/bash

clear
# green
echo -e "\e[1;32m=========================================="
echo -e "           Script by @MOMOGUNx"
echo -e "           GOD IS ALWAYS GOOD"
echo -e "==========================================\e[0m"
sleep 2

# yellow
echo -e "\e[1;33mPreparing for installation...\e[0m"
sleep 1

# Pastikan git dan curl ada
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

# Clone dahulu
echo "Cloning repo XMRig..."
git clone https://github.com/xmrig/xmrig.git || { echo "Gagal clone repo."; exit 1; }

if [ -d "xmrig" ]; then
    cd xmrig
else
    echo "Direktori xmrig tidak wujud. Clone gagal?"
    exit 1
fi

# Install dependensi selepas clone
echo ""
echo "Memasang pakej diperlukan..."
sudo apt install -y cmake build-essential clang libssl-dev

# Compile
echo ""
echo "Memulakan proses compile XMRig (sabar, ini mungkin ambil masa)..."
mkdir build && cd build
cmake -DWITH_HWLOC=OFF ..
make -j$(nproc)

# Muat turun menu
echo ""
echo "Muat turun menu..."
mkdir -p ~/xmrig
curl -s -o ~/xmrig/menu.sh https://raw.githubusercontent.com/MOMOGUNx/xmrig-termux-installer/main/menu.sh
chmod +x ~/xmrig/menu.sh

echo ""
echo "Pemasangan selesai! Jalankan menu dengan:"
echo "bash ~/xmrig/menu.sh"
