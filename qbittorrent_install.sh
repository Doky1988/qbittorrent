#!/usr/bin/env bash
set -euo pipefail

echo "=== qBittorrent Telepítő (Docker + Debian 13) ==="
echo

# --- Root check ---
if [ "$EUID" -ne 0 ]; then
  echo "Rootként futtasd!"
  exit 1
fi

# --- Mód választása ---
echo "Hogyan szeretnéd elérni a qBittorrent WebUI-t?"
echo "1) IP címmel (http://IP:8080)"
echo "2) Domainnel + HTTPS (Caddy reverse proxy)"
echo
read -rp "Válassz (1 vagy 2): " MODE

if [[ "$MODE" != "1" && "$MODE" != "2" ]]; then
  echo "Hibás választás!"
  exit 1
fi

DOMAIN=""
if [ "$MODE" == "2" ]; then
  read -rp "Add meg a domaint (pl. qb.domain.hu): " DOMAIN
  [ -z "$DOMAIN" ] && echo "Domain nem lehet üres." && exit 1
fi

# --- Könyvtárak ---
INSTALL_DIR="/opt/qbittorrent-seed"
CONFIG_DIR="$INSTALL_DIR/config"
DOWNLOADS_DIR="$INSTALL_DIR/downloads"

mkdir -p "$CONFIG_DIR" "$DOWNLOADS_DIR"
cd "$INSTALL_DIR"

# --- Docker + Compose telepítés (Debian 13) ---
if ! command -v docker >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

systemctl enable --now docker >/dev/null 2>&1 || true


# --- docker-compose.yml ---
if [ "$MODE" == "1" ]; then

cat > docker-compose.yml <<EOF
version: "3.9"
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    restart: unless-stopped
    environment:
      - PUID=0
      - PGID=0
      - TZ=Europe/Budapest
      - WEBUI_PORT=8080
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
EOF

else

mkdir -p caddy-data caddy-config

cat > docker-compose.yml <<EOF
version: "3.9"
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    restart: unless-stopped
    environment:
      - PUID=0
      - PGID=0
      - TZ=Europe/Budapest
      - WEBUI_PORT=8080
    volumes:
      - ./config:/config
      - ./downloads:/downloads
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
    networks:
      - qbt

  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy-data:/data
      - ./caddy-config:/config
    networks:
      - qbt

networks:
  qbt:
    driver: bridge
EOF

# --- LET'S ENCRYPT KÉNYSZERÍTETT CADDYFILE ---
cat > Caddyfile <<EOF
{
  email ssl@domain.hu
  acme_ca https://acme-v02.api.letsencrypt.org/directory
}

$DOMAIN {
  tls {
    issuer acme
  }
  reverse_proxy qbittorrent:8080
}
EOF

fi


# --- Konténerek indítása ---
docker compose up -d


# --- JELSZÓ KIOLVASÁS ---
QBT_PASS=""
for i in {1..40}; do
  LOGS="$(docker logs qbittorrent 2>/dev/null || true)"
  SESSION_LINE="$(echo "$LOGS" | grep -oE 'session:[[:space:]]*[A-Za-z0-9]+' | tail -n 1 || true)"

  if [ -n "$SESSION_LINE" ]; then
    QBT_PASS="$(echo "$SESSION_LINE" | sed 's/.*session:[[:space:]]*//')"
    QBT_PASS="$(echo "$QBT_PASS" | tr -d '[:space:]')"
  fi

  [ -n "$QBT_PASS" ] && break
  sleep 2
done

IP_ADDR="$(hostname -I | awk '{print $1}')"


# --- ÖSSZEGZÉS ---
echo
echo "---------- qBittorrent Összegzés ----------"
echo

if [ "$MODE" == "1" ]; then
  echo "[Mód]"
  echo "  IP alapú telepítés"
  echo
  echo "[WebUI]"
  echo "  URL:        http://$IP_ADDR:8080"
  echo "  User:       admin"
  echo "  Pass:       ${QBT_PASS:-'(nem olvasható ki)'}"
  echo
  echo "[Transdrone]"
  echo "  Host:       $IP_ADDR"
  echo "  Port:       8080"
  echo "  User:       admin"
  echo "  Pass:       ${QBT_PASS:-'(nincs)'}"
  echo

else
  echo "[Mód]"
  echo "  Domain alapú telepítés (Caddy + HTTPS)"
  echo
  echo "[WebUI]"
  echo "  DOMAIN:     https://$DOMAIN"
  echo "  IP:         http://$IP_ADDR:8080"
  echo "  User:       admin"
  echo "  Pass:       ${QBT_PASS:-'(nem olvasható ki)'}"
  echo
  echo "[Transdrone]"
  echo "  Host:       $IP_ADDR"
  echo "  Port:       8080"
  echo "  User:       admin"
  echo "  Pass:       ${QBT_PASS:-'(nincs)'}"
  echo
fi

echo "[Portok]"
echo "  6881/TCP, 6881/UDP"
echo
echo "--------------------------------------------"
