#!/bin/bash

WALLET_FILE="$HOME/.xmrig_wallet"

while true; do
    echo ""
    echo "========== MENU XMRig =========="
    echo "1. Tukar wallet"
    echo "2. Mula mining"
    echo "3. Semak wallet semasa"
    echo "4. Keluar"
    echo "================================"
    read -p "Pilih menu: " choice

    case $choice in
        1)
            read -p "Masukkan alamat wallet Monero anda: " wallet
            echo "$wallet" > "$WALLET_FILE"
            echo "Wallet disimpan."
            ;;
        2)
            if [ ! -f "$WALLET_FILE" ]; then
                echo "Wallet belum ditetapkan."
            else
                wallet=$(cat "$WALLET_FILE")
                cd ~/xmrig/build
                ./xmrig -o pool.supportxmr.com:80 -u "$wallet" --coin monero
            fi
            ;;
        3)
            echo "Wallet semasa: $(cat $WALLET_FILE 2>/dev/null || echo 'Belum ditetapkan')"
            ;;
        4) exit 0 ;;
        *) echo "Pilihan tidak sah." ;;
    esac
done
