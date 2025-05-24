#!/data/data/com.termux/files/usr/bin/bash

WALLET_FILE="$HOME/.xmrig_wallet"
XMRIG_DIR="$HOME/xmrig/build"

while true; do
    echo ""
    echo "========== MENU XMRig =========="
    echo "1. Tukar wallet"
    echo "2. Mula mining"
    echo "3. Semak wallet semasa"
    echo "4. Keluar"
    echo "================================"
    read -p "Pilih menu [1-4]: " choice

    case $choice in
        1)
            read -p "Masukkan alamat wallet Monero anda: " wallet
            echo "$wallet" > "$WALLET_FILE"
            echo "Wallet disimpan ke $WALLET_FILE"
            ;;
        2)
            if [ ! -f "$WALLET_FILE" ]; then
                echo "Wallet belum ditetapkan. Sila pilih menu 1 dahulu."
            else
                wallet=$(cat "$WALLET_FILE")
                echo "Memulakan mining menggunakan wallet: $wallet"
                cd "$XMRIG_DIR" || { echo "XMRig tidak dijumpai."; exit 1; }
                ./xmrig -o pool.supportxmr.com:80 -u "$wallet" --coin monero
            fi
            ;;
        3)
            if [ -f "$WALLET_FILE" ]; then
                echo "Wallet semasa: $(cat "$WALLET_FILE")"
            else
                echo "Wallet belum ditetapkan."
            fi
            ;;
        4)
            echo "Keluar."
            exit 0
            ;;
        *)
            echo "Pilihan tidak sah. Sila pilih 1-4."
            ;;
    esac
done
