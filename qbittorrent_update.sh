#!/usr/bin/env bash
set -euo pipefail

echo "=== qBittorrent + Caddy Update Script ==="
echo

INSTALL_DIR="/opt/qbittorrent-seed"
cd "$INSTALL_DIR"

# Ellenőrizzük, hogy domain mód is fut-e
CADDY_MODE="0"
if [ -f "Caddyfile" ]; then
  CADDY_MODE="1"
fi

echo ">>> Legújabb image-ek letöltése..."
docker pull lscr.io/linuxserver/qbittorrent:latest

if [ "$CADDY_MODE" == "1" ]; then
  docker pull caddy:latest
fi

echo ">>> Konténerek újraindítása..."
docker compose down
docker compose up -d

echo ">>> Felesleges image-ek törlése..."
docker image prune -f

echo
echo "=== Frissítés kész! ==="
echo "qBittorrent és Caddy (ha van) frissítve."