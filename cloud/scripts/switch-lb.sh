#!/usr/bin/env bash
# Pakai: bash scripts/switch-lb.sh rr|lc|iphash
set -euo pipefail
cd "$(dirname "$0")/.."

ALGO="${1:-}"
case "$ALGO" in
  rr|lc|iphash) ;;
  *) echo "Pakai: bash scripts/switch-lb.sh rr|lc|iphash"; exit 1 ;;
esac

cp "nginx/${ALGO}.conf" nginx.conf
docker compose restart nginx >/dev/null
echo "Algoritma aktif: ${ALGO}"
grep -E '^\s*(least_conn|ip_hash)' nginx.conf || echo "(tidak ada direktif = Round Robin default)"