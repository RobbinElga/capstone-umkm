#!/usr/bin/env bash
# Bukti LB untuk satu algoritma (untuk screenshot). Pakai: bash scripts/evidence.sh rr|lc|iphash
set -euo pipefail
cd "$(dirname "$0")/.."

ALGO="${1:-}"
[[ "$ALGO" =~ ^(rr|lc|iphash)$ ]] || { echo "Pakai: bash scripts/evidence.sh rr|lc|iphash"; exit 1; }

bash scripts/switch-lb.sh "$ALGO"
sleep 2
echo
echo "=== nginx.conf (blok upstream) ==="
sed -n 5,9p nginx.conf
for i in $(seq 1 10); do curl -s -o /dev/null http://localhost/api/products/1; done
echo
echo "=== docker compose logs nginx --tail=10 ==="
docker compose logs nginx --no-log-prefix --tail=10