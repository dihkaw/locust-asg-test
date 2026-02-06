#!/bin/bash

# --- KONFIGURASI PARAMETER (Edit di sini) ---
LOCUST_FILE="locustfile.py"
ALB_URL="http://alamatALB"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Fungsi umum untuk menjalankan locust (Headless)
run_locust() {
    local USERS=$1
    local SPAWN_RATE=$2
    local DURATION=$3
    local REPORT_NAME=$4

    echo ">> Menjalankan: $USERS User | Spawn: $SPAWN_RATE User/s | Durasi: $DURATION"
    
    locust -f "$LOCUST_FILE" \
        --host "$ALB_URL" \
        --headless \
        -u "$USERS" \
        -r "$SPAWN_RATE" \
        --run-time "$DURATION" \
        --html "$REPORT_NAME" \
        --only-summary # Opsional: agar terminal tidak penuh log
}

echo "===================================================="
echo " PENGUJIAN REPLIKASI ASG - $TIMESTAMP "
echo "===================================================="

# Skenario 1: Baseline (Beban Normal)
echo "[1/3] Tahap Awal: Memastikan sistem stabil..."
run_locust 200 5 1m "report_baseline_$TIMESTAMP.html"

echo "Jeda 1 menit untuk stabilisasi..."
sleep 60

# Skenario 2: Ramp-up (Memicu CPU 60%)
# Kita naikkan user secara signifikan untuk memaksa CPU bekerja keras
echo "[2/3] Tahap Stress: Memicu Auto Scaling Replikassi..."
run_locust 500 10 1m "report_scaling_trigger_$TIMESTAMP.html"

echo "Jeda 1 menit agar ASG sempat melakukan provisioning..."
sleep 60

# Skenario 3: Peak Load (Menguji Hasil Replikasi)
# Menguji apakah instance baru sudah sanggup menangani beban maksimal
echo "[3/3] Tahap Peak: Validasi kapasitas replikasi..."
run_locust 1000 20 1m "report_peak_validation_$TIMESTAMP.html"

echo "===================================================="
echo " Pengujian Selesai. Semua laporan .html telah dibuat."
echo "===================================================="