#!/data/data/com.termux/files/usr/bin/bash
clear
echo "🔧 Memulai setup CCMiner Termux..."

# Instal dependensi
pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1
pkg install wget curl libjansson nano dos2unix -y > /dev/null 2>&1

# Folder kerja
mkdir -p ~/ccminer
cd ~/ccminer

# 🔥 Bersihkan file lama
echo "🧹 Membersihkan file lama..."
rm -f ccminer config.json ril*.* > /dev/null 2>&1

# Unduh ccminer
echo "⬇️ Mengunduh ccminer precompiled..."
wget -q https://github.com/Darktron/pre-compiled/releases/download/ccminer-android/ccminer -O ccminer
chmod +x ccminer

# Input manual dari user
echo "🌐 Masukkan data mining kamu:"
read -p "Pool URL (tanpa stratum+tcp://): " POOL
read -p "Port: " PORT
read -p "Wallet Address: " WALLET
read -p "Worker Name: " WORKER
read -p "Threads (rekomendasi 2): " THREADS

# Buat config.json baru
echo "⚙️ Membuat config.json baru..."
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

# Fungsi mining (loop + tampil minimal)
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
    echo -e "\n⚠️ Miner crash atau keluar. Restart dalam 5 detik..."
    sleep 5
    clear
  done
}

echo "🚀 Menjalankan CCMiner..."
sleep 1
run_miner
