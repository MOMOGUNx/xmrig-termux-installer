#!/usr/bin/env bash

# Colour text
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# File config
WALLET_FILE="$HOME/.xmrig_wallet"
POOL_FILE="$HOME/.xmrig_pool"
THREAD_FILE="$HOME/.xmrig_threads"
WORKER_FILE="$HOME/.xmrig_worker"
COIN_FILE="$HOME/.xmrig_coin"
ALGO_FILE="$HOME/.xmrig_algo"
TLS_FILE="$HOME/.xmrig_tls"
XMRIG_DIR="$HOME/xmrig/build"

# Default pool (HashVault)
DEFAULT_POOL="pool.hashvault.pro:80"

# Getter functions
get_wallet() { cat "$WALLET_FILE" 2>/dev/null || echo "Not set"; }
get_pool()   { cat "$POOL_FILE" 2>/dev/null || echo "$DEFAULT_POOL"; }
get_threads(){ cat "$THREAD_FILE" 2>/dev/null || echo "Auto (default)"; }
get_worker() { cat "$WORKER_FILE" 2>/dev/null || echo "None (default)"; }
get_coin()   { cat "$COIN_FILE" 2>/dev/null || echo "XMR"; }
get_algo()   { cat "$ALGO_FILE" 2>/dev/null || echo "rx/0"; }
get_tls()    { cat "$TLS_FILE" 2>/dev/null || echo "no"; }

while true; do
    clear
    echo -e "${CYAN}========== XMRig Menu (Multi Coin) ==========${NC}"
    printf "${YELLOW}%-8s${NC}: %s\n" "Wallet"  "$(get_wallet)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Pool"    "$(get_pool)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Threads" "$(get_threads)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Worker"  "$(get_worker)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Coin"    "$(get_coin)"
    printf "${YELLOW}%-8s${NC}: %s\n" "Algo"    "$(get_algo)"
    printf "${YELLOW}%-8s${NC}: %s\n" "TLS"     "$(get_tls)"
    echo -e "${CYAN}=============================================${NC}"
    echo -e "${GREEN}1.${NC} Change wallet address"
    echo -e "${GREEN}2.${NC} Change pool domain and port"
    echo -e "${GREEN}3.${NC} Set number of CPU threads"
    echo -e "${GREEN}4.${NC} Change worker name"
    echo -e "${GREEN}5.${NC} Change coin"
    echo -e "${GREEN}6.${NC} Change algorithm"
    echo -e "${GREEN}7.${NC} Use TLS (yes/no)"
    echo -e "${GREEN}8.${NC} Start mining"
    echo -e "${GREEN}9.${NC} Exit"
    echo -e "${CYAN}=============================================${NC}"
    read -p "Select an option [1-9]: " choice

    case $choice in
        1)
            read -p "Enter wallet address: " wallet
            echo "$wallet" > "$WALLET_FILE"
            ;;
        2)
            read -p "Enter pool domain and port (e.g., pool.hashvault.pro:80): " pool
            echo "$pool" > "$POOL_FILE"
            ;;
        3)
            max_threads=$(nproc)
            read -p "Enter number of threads (1-$max_threads), or press Enter for auto: " threads
            if [[ -z "$threads" ]]; then
                rm -f "$THREAD_FILE"
                echo "Threads set to auto mode."
            elif [[ "$threads" =~ ^[0-9]+$ ]]; then
                [[ "$threads" -gt "$max_threads" ]] && threads=$max_threads
                echo "$threads" > "$THREAD_FILE"
            else
                echo "Invalid input."
            fi
            ;;
        4)
            read -p "Enter worker name (leave empty for default): " worker
            echo "$worker" > "$WORKER_FILE"
            ;;
        5)
            read -p "Enter coin symbol (e.g., XMR, DOGE, SHIB): " coin
            echo "$coin" > "$COIN_FILE"
            ;;
        6)
            read -p "Enter algorithm name (e.g., rx/0, ghostrider): " algo
            echo "$algo" > "$ALGO_FILE"
            ;;
        7)
            read -p "Use TLS? (yes/no): " tls
            [[ "$tls" =~ ^(yes|no)$ ]] && echo "$tls" > "$TLS_FILE"
            ;;
        8)
            wallet=$(get_wallet)
            pool=$(get_pool)
            threads=$(get_threads)
            worker=$(get_worker)
            coin=$(get_coin)
            algo=$(get_algo)
            tls=$(get_tls)

            [[ "$wallet" == "Not set" ]] && {
                echo "Wallet is not set. Please select option 1 first."
                read -n 1 -s -r -p "Press any key to continue..."
                continue
            }

            echo ""
            echo "================================"
            echo " Starting XMRig Mining"
            echo "================================"
            echo " Coin   : $coin"
            echo " Algo   : $algo"
            echo " Wallet : $wallet"
            echo " Pool   : $pool"
            echo " TLS    : $tls"
            echo " Worker : $worker"
            echo " Threads: $threads"
            echo "================================"
            sleep 2

            cd "$XMRIG_DIR" || { echo "XMRig not found."; exit 1; }

            # Tentukan format wallet sesuai pool
            if [[ "$pool" == *"unmineable"* ]]; then
                [[ -n "$worker" && "$worker" != "None (default)" ]] && wallet_full="${coin}:${wallet}.${worker}" || wallet_full="${coin}:${wallet}"
            else
                [[ -n "$worker" && "$worker" != "None (default)" ]] && wallet_full="${wallet}.${worker}" || wallet_full="$wallet"
            fi

            [[ "$tls" == "yes" ]] && tls_flag="--tls" || tls_flag=""

            if [[ "$threads" == "Auto (default)" ]]; then
                ./xmrig -a "$algo" -o "$pool" -u "$wallet_full" -p x $tls_flag
            else
                ./xmrig -a "$algo" -o "$pool" -u "$wallet_full" -p x -t "$threads" $tls_flag
            fi

            read -n 1 -s -r -p "Press any key to return to menu..."
            ;;
        9)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select 1-9."
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
    esac
done
