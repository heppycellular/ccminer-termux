#!/data/data/com.termux/files/usr/bin/bash

clear
echo -e "\e[92m[•] Sedang mempersiapkan lingkungan...\e[0m"

# Tampilkan progress tanpa scroll panjang
( pkg update -y >/dev/null 2>&1 && pkg upgrade -y >/dev/null 2>&1 && pkg install wget curl libjansson -y >/dev/null 2>&1 ) &

sp='/-\|'
sc=0
printf "\n[•] Menginstal paket"
while kill -0 $! 2>/dev/null; do
    printf "\r[•] Menginstal paket %s" "${sp:sc++:1}"
    ((sc==${#sp})) && sc=0
    sleep 0.1
done

clear

# Setup direktori
cd ~
rm -rf ccminer
mkdir ccminer
cd ccminer

# Unduh ccminer binary
echo -e "\n[•] Mengunduh ccminer binary..."
curl -L -o ccminer https://github.com/Darktron/pre-compiled/releases/download/ccminer-android/ccminer >/dev/null 2>&1
chmod +x ccminer

# Input user
read -p "Masukkan Pool URL (contoh: stratum+tcp://rvn.2miners.com): " POOL
read -p "Masukkan Port (contoh: 6060): " PORT
read -p "Masukkan Wallet Address: " WALLET
read -p "Masukkan Nama Worker: " WORKER
read -p "Jumlah Thread (default 2): " THREAD
THREAD=${THREAD:-2}

# Buat config
cat > config.json <<EOF
{
  "url": "$POOL:$PORT",
  "user": "$WALLET.$WORKER",
  "pass": "x",
  "algo": "x16rv2",
  "threads": $THREAD
}
EOF

# Fungsi tampilan minimal
function run_miner() {
    while true; do
        clear
        ./ccminer --config config.json | while read line; do
            SPEED=$(echo "$line" | grep -oP '[0-9.]+ Mh/s')
            YES=$(echo "$line" | grep -o 'YES')
            if [[ "$SPEED" != "" ]]; then
                STATUS="████  $SPEED | ${YES:-    }  ████"
                printf "\033c%s\n" "$STATUS"
            fi
        done
        sleep 5
    done
}

# Jalankan miner
run_miner
