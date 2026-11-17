# Risk Register — Katalog UMKM Kuliner Pontianak

Skor = Probabilitas (1-5) × Dampak (1-5). Kategori: **Tinggi** ≥ 15, **Sedang** 8-14, **Rendah** < 8.

| No | Risiko | Probabilitas | Dampak | Skor | Kategori | Mitigasi |
|----|--------|:-----------:|:------:|:----:|:--------:|----------|
| 1 | Brute-force login SSH | 4 | 4 | 16 | Tinggi | SSH key-only (`PasswordAuthentication no`), fail2ban aktif untuk sshd, UFW hanya membuka port 22/80/443 |
| 2 | SQL Injection pada endpoint produk | 3 | 5 | 15 | Tinggi | Semua query memakai parameterized query (`$1`), validasi input `id` (integer), pesan error generik ke klien |
| 3 | VPS dihentikan/di-reclaim provider karena idle atau akun bermasalah | 3 | 5 | 15 | Tinggi | Pantau aktivitas via Grafana, backup `pg_dump` rutin, infrastruktur dapat dibangun ulang dengan `docker compose up` + pipeline CI/CD |
| 4 | Dashboard monitoring (Grafana/Prometheus) terekspos ke publik | 3 | 4 | 12 | Sedang | Hanya listen di `127.0.0.1`, akses lewat SSH tunnel, password admin Grafana diganti dari default |
| 5 | Data terhapus tidak sengaja / volume database hilang | 2 | 5 | 10 | Sedang | Backup `pg_dump` terjadwal (`scripts/backup.sh`), volume `pgdata` persisten |
| 6 | Kebocoran kredensial database | 2 | 5 | 10 | Sedang | Password disimpan di `.env` (masuk `.gitignore`), tidak ada kredensial di repository, port 5432 tidak dipublikasikan |
| 7 | Salah satu container aplikasi mati | 3 | 3 | 9 | Sedang | Nginx otomatis mengalihkan trafik ke container lain, `restart: unless-stopped` pada semua service |
| 8 | Sertifikat TLS IP (berlaku ±6 hari) gagal diperpanjang sehingga HTTPS mati | 3 | 3 | 9 | Sedang | Perpanjangan otomatis lewat cron `certbot renew` tiap 12 jam, `--deploy-hook` me-reload Nginx, HTTP port 80 tetap aktif sebagai cadangan, tanggal kedaluwarsa dicek dengan `certbot certificates` sebelum penilaian. Sertifikat terikat ke IP, sehingga instance tidak boleh dibuat ulang |

## Aset yang dilindungi
- Data katalog produk (PostgreSQL), kredensial (`.env`), akses server (SSH), ketersediaan layanan (Nginx + 2 container app).