#!/data/data/com.termux/files/usr/bin/bash

clear
echo "⛏️  Memulai instalasi & build ccminer..."
echo "⏳ Mohon tunggu, proses ini bisa memakan waktu..."

pkg update -y > /dev/null 2>&1
pkg upgrade -y > /dev/null 2>&1
pkg install git clang build-essential libjansson autoconf automake libtool -y > /dev/null 2>&1

cd ~
rm -rf ccminer
git clone https://github.com/Darktron/ccminer > /dev/null 2>&1
cd ccminer

chmod +x autogen.sh build.sh
./autogen.sh > /dev/null 2>&1
./build.sh > /dev/null 2>&1

if [[ ! -f ./ccminer ]]; then
  echo "❌ Build gagal. Pastikan sistemmu tidak kekurangan resource."
  exit 1
fi

clear
echo "✅ Build selesai!"
read -p "🪙 Wallet: " WALLET
read -p "🌐 Pool URL (tanpa stratum+tcp://): " POOL
read -p "🔌 Port: " PORT
read -p "👷 Worker Name: " WORKER
read -p "🧵 Threads (cth: 4): " THREADS

echo "🔄 Menjalankan ccminer..."

while true; do
  ./ccminer -a verus -o stratum+tcp://$POOL:$PORT -u $WALLET.$WORKER -t $THREADS 2>/dev/null | \
  grep --line-buffered -E "yes|[0-9]+\.[0-9]+[ ]?Mh/s" | \
  awk -W interactive '
    /Mh\/s/ { rate=$1 }
    /yes/ { yes="| YES" }
    !/yes/ { yes="" }
    { 
      if (rate != prev_rate || yes != prev_yes) {
        system("clear")
        print "█████████████████████████████"
        printf("██  %s Mh/s %s\t██\n", rate, yes)
        print "█████████████████████████████"
        prev_rate=rate
        prev_yes=yes
      }
      fflush()
    }'
  sleep 5
done
