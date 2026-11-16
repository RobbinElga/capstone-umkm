#!/usr/bin/env bash
# Pakai: bash scripts/loadtest.sh rr|lc|iphash [jumlah_request=1000] [concurrency=50]
# Jalankan DI VPS (terhadap localhost) supaya perbandingan antar algoritma adil.
set -euo pipefail
cd "$(dirname "$0")/.."

ALGO="${1:-}"
N="${2:-1000}"
C="${3:-50}"
URL="http://localhost/api/products"

[[ "$ALGO" =~ ^(rr|lc|iphash)$ ]] || { echo "Pakai: bash scripts/loadtest.sh rr|lc|iphash [N] [C]"; exit 1; }
command -v ab >/dev/null || { echo "Install dulu: sudo apt install apache2-utils -y"; exit 1; }
command -v python3 >/dev/null || { echo "python3 dibutuhkan"; exit 1; }

bash scripts/switch-lb.sh "$ALGO"
sleep 3
curl -fsS http://localhost/health >/dev/null || { echo "App belum sehat, cek: docker compose ps"; exit 1; }

mkdir -p results
START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
START_EPOCH=$(date +%s)

echo ">> ab -n $N -c $C $URL"
ab -n "$N" -c "$C" "$URL" > "results/${ALGO}-ab.txt"

sleep 6   # beri waktu Prometheus men-scrape titik terakhir
DUR=$(( $(date +%s) - START_EPOCH ))

# --- Distribusi request dari log Nginx ---
ip_of() { docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$(docker compose ps -q "$1")"; }
IP1=$(ip_of app1)
IP2=$(ip_of app2)
docker compose logs nginx --no-log-prefix --since "$START" > "results/${ALGO}-nginx.log" 2>&1 || true
C1=$(grep -c "upstream=${IP1}:3000" "results/${ALGO}-nginx.log" || true)
C2=$(grep -c "upstream=${IP2}:3000" "results/${ALGO}-nginx.log" || true)
TOTAL=$(( C1 + C2 ))
if [ "$TOTAL" -gt 0 ]; then
  P1=$(awk -v a="$C1" -v t="$TOTAL" 'BEGIN{printf "%.1f", a*100/t}')
  P2=$(awk -v a="$C2" -v t="$TOTAL" 'BEGIN{printf "%.1f", a*100/t}')
else
  P1="n/a"; P2="n/a"
fi

# --- Latensi rata-rata (Time per request, mean) ---
LAT=$(grep -m1 'Time per request' "results/${ALGO}-ab.txt" | awk '{print $4}')
FAILED=$(grep -m1 'Failed requests' "results/${ALGO}-ab.txt" | awk '{print $3}')

# --- Puncak CPU & RAM selama pengujian (Prometheus) ---
q() {
  curl -fsS --get 'http://localhost:9090/api/v1/query' --data-urlencode "query=$1" \
    | python3 -c 'import sys,json; r=json.load(sys.stdin)["data"]["result"]; print(round(float(r[0]["value"][1]),1) if r else "n/a")' \
    2>/dev/null || echo "n/a"
}
PEAK_CPU=$(q "max_over_time((100 - avg(rate(node_cpu_seconds_total{mode=\"idle\"}[15s])) * 100)[${DUR}s:5s])")
PEAK_RAM=$(q "max_over_time(((1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100)[${DUR}s:5s])")

# --- Simpan ringkasan ---
[ -f results/summary.csv ] || echo "algoritma,request,concurrency,app1_pct,app2_pct,latensi_ms,failed,peak_cpu_pct,peak_ram_pct" > results/summary.csv
echo "${ALGO},${N},${C},${P1},${P2},${LAT},${FAILED},${PEAK_CPU},${PEAK_RAM}" >> results/summary.csv

echo
echo "===== HASIL ${ALGO} ====="
echo "Distribusi app1:app2   : ${P1}% : ${P2}%  (${C1} : ${C2})"
echo "Latensi rata-rata      : ${LAT} ms"
echo "Failed requests        : ${FAILED}"
echo "Puncak CPU / RAM       : ${PEAK_CPU}% / ${PEAK_RAM}%"
echo "Detail: results/${ALGO}-ab.txt dan results/${ALGO}-nginx.log"