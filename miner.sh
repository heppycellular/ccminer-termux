#!/data/data/com.termux/files/usr/bin/bash
clear
echo "🔧 Memeriksa dan menginstall dependensi Termux..."
sleep 1

pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1
pkg install wget curl libjansson nano -y > /dev/null 2>&1

echo "✅ Semua dependensi sudah terpasang!"
sleep 1

mkdir -p ~/ccminer
cd ~/ccminer

if [ ! -f "./ccminer" ]; then
    echo "⬇️  Mengunduh ccminer precompiled..."
    wget -q https://github.com/Darktron/pre-compiled/releases/download/ccminer-android/ccminer -O ccminer
    chmod +x ccminer
    echo "✅ ccminer berhasil diunduh dan disiapkan!"
    sleep 1
fi

if [ ! -f "./config.json" ]; then
    echo "🛠️  Membuat config.json default..."
    cat > config.json <<EOF
{
  "algo": "lyra2v2",
  "url": "stratum+tcp://POOL:PORT",
  "user": "WALLET.WORKER",
  "pass": "x",
  "threads": 2,
  "quiet": true
}
EOF
    echo "📄 Silakan edit config.json untuk mengisi pool, port, wallet, worker"
    sleep 2
fi

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

if pgrep -f "ccminer --config config.json" > /dev/null; then
  echo "⚠️  CCMiner sudah berjalan. Tidak dimulai ulang."
  exit 1
else
  echo "🚀 Menjalankan CCMiner... Tekan CTRL + C untuk berhenti."
  sleep 1
  run_miner
fi
