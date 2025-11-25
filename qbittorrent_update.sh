#!/usr/bin/env bash
set -euo pipefail

echo "=== qBittorrent + Caddy Frissítő Script ==="

INSTALL_DIR="/opt/qbittorrent-install"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Hiba: A telepítési könyvtár nem található: $INSTALL_DIR"
    exit 1
fi

cd "$INSTALL_DIR"

echo "=== Konténerek leállítása nélkül — frissítések ellenőrzése ==="
docker compose pull

echo "=== Frissítések alkalmazása ==="
docker compose up -d

echo "=== Régi image-ek törlése ==="
docker image prune -f

echo "=== Kész! ==="
echo "qBittorrent + Caddy sikeresen frissítve."
echo "Telepítési könyvtár: $INSTALL_DIR"
echo "Dátum: $(date)"
