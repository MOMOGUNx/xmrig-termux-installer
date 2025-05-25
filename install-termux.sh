#!/data/data/com.termux/files/usr/bin/bash

clear
# green
echo -e "\e[1;32m=========================================="
echo -e "           Script by @MOMOGUNx"
echo -e "           GOD IS ALWAYS GOOD"
echo -e "==========================================\e[0m"
sleep 2

# yellow
echo -e "\e[1;33mPreparing for installation..\e[0m"
sleep 1

pkg install git -y

# Semak whitelist
read -p "Masukkan username anda: " username
ALLOWED_URL="https://raw.githubusercontent.com/MOMOGUNx/xmrig-termux-installer/main/allowed_users.txt"

if curl -s "$ALLOWED_URL" | grep -qw "$username"; then
    echo "Akses dibenarkan. Meneruskan pemasangan..."
else
    echo "Maaf, anda tidak dibenarkan memasang skrip ini."
    exit 1
fi

# Clone repo
echo "Cloning repo XMRig..."
git clone https://github.com/xmrig/xmrig.git || { echo "Gagal clone repo."; exit 1; }

if [ -d "xmrig" ]; then
    cd xmrig
else
    echo "Direktori xmrig tidak wujud. Clone gagal?"
    exit 1
fi

# Install dependensi
echo ""
echo "Memasang pakej diperlukan..."
pkg update && pkg upgrade -y
pkg install git cmake build-essential clang openssl curl -y

# Compile
echo ""
echo "Memulakan proses compile XMRig (sabar, ini mungkin ambil masa)..."
cd xmrig
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
