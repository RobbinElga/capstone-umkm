#!/usr/bin/env bash
# Pakai: bash scripts/backup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

set -a; source .env; set +a
mkdir -p backups
FILE="backups/umkm-$(date +%F-%H%M).sql"
docker compose exec -T db pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$FILE"
echo "Backup selesai: $FILE ($(wc -c < "$FILE") bytes)"