#!/data/data/com.termux/files/usr/bin/bash

echo "Script by @MOMOGUNx"
echo "Sila masukkan nama pengguna anda untuk semakan whitelist"

read -p "Username: " input_user

# whitelist
ALLOWED_URL="https://raw.githubusercontent.com/MOMOGUNx/xmrig-termux-installer/main/allowed_users.txt"
allowed_users=$(curl -s "$ALLOWED_URL")

# Check username
if echo "$allowed_users" | grep -Fxq "$input_user"; then
    echo "Akses dibenarkan. Memulakan pemasangan..."
else
    echo "Akses ditolak. Username tidak ada dalam whitelist."
    exit 1
fi

# update and install requirements
pkg update -y && pkg upgrade -y
pkg install -y git cmake build-essential clang openssl curl

# Clone dan build xmrig
cd ~
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build
cmake -DWITH_HWLOC=OFF ..
make -j$(nproc)

# Buat fail wallet jika belum ada
WALLET_FILE="$HOME/.xmrig_wallet"
if [ ! -f "$WALLET_FILE" ]; then
    read -p "Masukkan alamat wallet Monero anda: " wallet
    echo "$wallet" > "$WALLET_FILE"
    echo "Wallet disimpan di $WALLET_FILE"
fi

# Muat turun menu.sh
curl -s -o ~/xmrig/menu.sh https://raw.githubusercontent.com/MOMOGUNx/xmrig-termux-installer/main/menu.sh
chmod +x ~/xmrig/menu.sh

echo "Pemasangan selesai. Jalankan menu dengan:"
echo "bash ~/xmrig/menu.sh"
