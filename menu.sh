#!/usr/bin/env bash

# Colour text
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m' # Reset warna

WALLET_FILE="$HOME/.xmrig_wallet"
POOL_FILE="$HOME/.xmrig_pool"
THREAD_FILE="$HOME/.xmrig_threads"
WORKER_FILE="$HOME/.xmrig_worker"
XMRIG_DIR="$HOME/xmrig/build"
DEFAULT_POOL="pool.supportxmr.com:80"

function get_wallet() {
    cat "$WALLET_FILE" 2>/dev/null || echo "Belum ditetapkan"
}
function get_pool() {
    cat "$POOL_FILE" 2>/dev/null || echo "$DEFAULT_POOL"
}
function get_threads() {
    cat "$THREAD_FILE" 2>/dev/null || echo "Auto (default)"
}
function get_worker() {
    cat "$WORKER_FILE" 2>/dev/null || echo "Tiada (default)"
}

while true; do
    clear
    echo -e "${CYAN}========== MENU XMRig ==========${NC}"
    printf "${YELLOW}%-8s${NC}: %s\n" "Wallet"  "$(get_wallet)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Pool"    "$(get_pool)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Threads" "$(get_threads)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Worker"  "$(get_worker)"
    echo -e "${CYAN}================================${NC}"
    echo -e "${GREEN}1.${NC} Change wallet"
    echo -e "${GREEN}2.${NC} Change pool domain & port"
    echo -e "${GREEN}3.${NC} Set thread CPU"
    echo -e "${GREEN}4.${NC} Change worker name"
    echo -e "${GREEN}5.${NC} Start mining"
    echo -e "${GREEN}6.${NC} Exit"
    echo -e "${CYAN}================================${NC}"
    read -p "Pilih menu [1-6]: " choice

    case $choice in
        1)
            read -p "Masukkan alamat wallet Monero anda: " wallet
            echo "$wallet" > "$WALLET_FILE"
            echo "Wallet disimpan ke $WALLET_FILE"
            read -n 1 -s -r -p "Press any key.."
            ;;
        2)
            read -p "Masukkan domain dan port pool (cth: pool.supportxmr.com:80): " pool
            echo "$pool" > "$POOL_FILE"
            echo "Pool disimpan ke $POOL_FILE"
            read -n 1 -s -r -p "Press any key..."
            ;;
        3)
            max_threads=$(nproc)
            read -p "Masukkan bilangan thread yang ingin digunakan (1 hingga $max_threads), atau tekan Enter untuk auto: " threads
            if [[ -z "$threads" ]]; then
                rm -f "$THREAD_FILE"
                echo "Thread dikembalikan ke mod auto."
            elif [[ "$threads" =~ ^[0-9]+$ ]]; then
                if (( threads > max_threads )); then
                    echo "Amaran: Peranti anda hanya menyokong hingga $max_threads thread. Menetapkan ke maksimum."
                    threads=$max_threads
                fi
                echo "$threads" > "$THREAD_FILE"
                echo "Thread ditetapkan ke $threads."
            else
                echo "Input tidak sah. Masukkan nombor sahaja."
            fi
            read -n 1 -s -r -p "Press any key..."
            ;;
        4)
            read -p "Masukkan nama worker (biarkan kosong untuk default): " worker
            echo "$worker" > "$WORKER_FILE"
            echo "Worker name disimpan ke $WORKER_FILE"
            read -n 1 -s -r -p "Press any key..."
            ;;
        5)
            wallet=$(get_wallet)
            pool=$(get_pool)
            threads=$(get_threads)
            worker=$(get_worker)

            if [[ "$wallet" == "Belum ditetapkan" ]]; then
                echo "Wallet belum ditetapkan. Sila pilih menu 1 dahulu."
            else
                echo ""
                echo "================================"
                echo " Starting XMRig Miner"
                echo "================================"
                echo " Wallet : $wallet"
                echo " Pool   : $pool"
                echo " Threads: $threads"
                echo " Worker : $worker"
                echo "================================"
                sleep 2
                cd "$XMRIG_DIR" || { echo "XMRig tidak dijumpai."; exit 1; }

                # Gabung wallet + worker jika ada
                if [[ -n "$worker" && "$worker" != "Tiada (default)" ]]; then
                    wallet_full="${wallet}.${worker}"
                else
                    wallet_full="$wallet"
                fi

                if [[ "$threads" == "Auto (default)" ]]; then
                    ./xmrig -o "$pool" -u "$wallet_full" --coin monero
                else
                    ./xmrig -o "$pool" -u "$wallet_full" --coin monero --threads "$threads"
                fi
            fi
            read -n 1 -s -r -p "Press any key..."
            ;;
        6)
            echo "Keluar."
            exit 0
            ;;
        *)
            echo "Pilihan tidak sah. Sila pilih 1-6."
            read -n 1 -s -r -p "Press any key..."
            ;;
    esac
done
