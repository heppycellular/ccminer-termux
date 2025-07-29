#!/data/data/com.termux/files/usr/bin/bash
clear
echo "🔧 Menginstall dependensi Termux..."
sleep 1

pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1
pkg install wget curl libjansson nano dos2unix -y > /dev/null 2>&1

echo "✅ Semua dependensi siap!"
sleep 1

mkdir -p ~/ccminer
cd ~/ccminer

if [ ! -f "./ccminer" ]; then
    echo "⬇️  Mengunduh ccminer precompiled..."
    wget -q https://github.com/Darktron/pre-compiled/releases/download/ccminer-android/ccminer -O ccminer
    chmod +x ccminer
fi

# 📥 INPUT DATA USER
echo "🌐 Silakan masukkan data mining kamu:"
read -p "Pool URL (tanpa stratum+tcp://): " POOL
read -p "Port: " PORT
read -p "Wallet Address: " WALLET
read -p "Worker Name: " WORKER
read -p "Threads (2 disarankan): " THREADS

# ✍️ Generate config.json otomatis
cat > config.json <<EOF
{
  "algo": "lyra2v2",
  "url": "stratum+tcp://$POOL:$PORT",
  "user": "$WALLET.$WORKER",
  "pass": "x",
  "threads": $THREADS,
  "quiet": true
}
EOF

# 🔁 Auto restart + tampil minimal
run_miner() {
  while true; do
    ./ccminer --config config.json 2>&1 | awk '
      /hashrate/ {
        match($0, /[0-9]+\.[0-9]+[[:space:]]*[kKmMgG][hH]\/s/, rate);
        hashrate = rate[0];
      }
      /accepted: yes/ {
        if (hashrate != "") {
          system("clear");
          print "██████████████████████████";
          printf("██  %-16s ██\n", hashrate " | YES");
          print "██████████████████████████";
          fflush();
        }
      }
    '
    echo -e "\n❗ CCMiner berhenti/crash. Mengulang dalam 5 detik..."
    sleep 5
    clear
  done
}

echo "🚀 Menjalankan CCMiner..."
sleep 1
run_miner
