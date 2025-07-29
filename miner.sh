#!/data/data/com.termux/files/usr/bin/bash

# Auto setup & run ccminer with pre-defined config

# ====== Konfigurasi di sini ======
POOL="rvn.2miners.com"
PORT="6060"
WALLET="RVNxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
WORKER="android001"
THREADS="2"
# =================================

# Sembunyikan proses update
clear
echo "⏳ Menyiapkan lingkungan... (harap tunggu)"

{ 
  pkg update -y >/dev/null 2>&1
  pkg upgrade -y >/dev/null 2>&1
  pkg install wget libjansson -y >/dev/null 2>&1
} &

# Tampilkan progress palsu (5 detik)
for i in {1..5}; do
  echo -ne "⏳ Loading dependencies [$i/5]...\r"
  sleep 1
done

# Masuk ke direktori kerja
cd ~
mkdir -p ccminer
cd ccminer

# Hapus file lama jika ada
rm -f ccminer config.json miner.log

# Unduh ccminer
echo "📥 Mengunduh ccminer..."
wget -q https://github.com/Darktron/pre-compiled/releases/download/ccminer-android/ccminer -O ccminer
chmod +x ccminer

# Buat file konfigurasi
cat > config.json <<EOF
{
  "url": "stratum+tcp://${POOL}:${PORT}",
  "user": "${WALLET}.${WORKER}",
  "pass": "x",
  "algo": "x16rv2",
  "threads": ${THREADS}
}
EOF

# Jalankan miner dan tampilkan hanya ringkasan
echo "🚀 Menjalankan miner..."
while true; do
  ./ccminer --config config.json 2>&1 | grep --line-buffered -E "YES|[0-9]+\.[0-9]+ Mh/s" | \
  while read -r line; do
    MH=$(echo "$line" | grep -oE "[0-9]+\.[0-9]+ Mh/s")
    YES=$(echo "$line" | grep -o "YES")
    clear
    echo "██████████████████████████"
    printf "██  %-13s %-4s ██\n" "$MH" "$YES"
    echo "██████████████████████████"
  done
  sleep 2
done
