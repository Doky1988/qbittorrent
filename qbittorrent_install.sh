#!/usr/bin/env bash
set -euo pipefail

echo "=== qBittorrent Telepítő (Docker) ==="

# --- Root check ---
if [ "$EUID" -ne 0 ]; then
  echo "Ezt a scriptet rootként kell futtatni!"
  exit 1
fi

echo
echo "Hogyan szeretnéd elérni a qBittorrent WebUI-t?"
echo "1) IP címmel (http://IP:PORT)"
echo "2) Domainnel + HTTPS (Caddy reverse proxy)"
echo
read -rp "Válassz (1 vagy 2): " MODE

if [[ "$MODE" != "1" && "$MODE" != "2" ]]; then
    echo "Hibás választás!"
    exit 1
fi

# --- Ha 2-t választ, AZONNAL kérje a domaint ---
if [ "$MODE" == "2" ]; then
    echo
    echo "=== DOMAIN + HTTPS mód kiválasztva ==="
    read -rp "Add meg a domaint (pl. qb.domain.hu): " DOMAIN
    if [ -z "$DOMAIN" ]; then
      echo "A domain nem lehet üres."
      exit 1
    fi
fi

INSTALL_DIR="/opt/qbittorrent-install"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# === Docker telepítés ===
echo "=== Docker telepítése ==="
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings || true

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker


# --- MODE 1 → IP alapú telepítés ---
if [ "$MODE" == "1" ]; then
    echo "=== IP alapú qBittorrent telepítés készül ==="

    cat > docker-compose.yml <<'EOF'
version: "3.8"

services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Budapest
      - WEBUI_PORT=8080
    ports:
      - "8080:8080"
      - "6881:6881"
      - "6881:6881/udp"
    volumes:
      - ./qbittorrent/config:/config
      - ./qbittorrent/downloads:/downloads
    restart: unless-stopped
EOF

    echo "=== Konténerek indítása ==="
    docker compose pull
    docker compose up -d

    echo "=== Jelszó keresése ==="
    PASSWORD=""
    for i in {1..60}; do
      PASSWORD=$(docker logs qbittorrent 2>&1 \
        | grep -oP "temporary password .*: \K.*" || true)
      [ -n "$PASSWORD" ] && break
      sleep 2
    done
    [ -z "$PASSWORD" ] && PASSWORD="NEM TALÁLHATÓ – futtasd: docker logs qbittorrent"

    IP=$(hostname -I | awk '{print $1}')

    echo
    echo "==========================================="
    echo "      ✔ IP ALAPÚ TELEPÍTÉS KÉSZ"
    echo "==========================================="
    echo "WebUI:       http://${IP}:8080"
    echo "Felhasználó: admin"
    echo "Jelszó:      ${PASSWORD}"
    echo "Aktív port:  6881"
    echo "Telepítési könyvtár: ${INSTALL_DIR}"
    echo "==========================================="
    exit 0
fi


# --- MODE 2 → DOMAIN + HTTPS telepítés ---
echo "DOMAIN=${DOMAIN}" > .env

cat > docker-compose.yml <<EOF
version: "3.8"

services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Budapest
      - WEBUI_PORT=8080
    ports:
      - "6881:6881"
      - "6881:6881/udp"
    volumes:
      - ./qbittorrent/config:/config
      - ./qbittorrent/downloads:/downloads
    restart: unless-stopped

  caddy:
    image: caddy:latest
    container_name: caddy
    depends_on:
      - qbittorrent
    ports:
      - "80:80"
      - "443:443"
    environment:
      - DOMAIN=${DOMAIN}
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy_data:/data
      - ./caddy_config:/config
    restart: unless-stopped
EOF

# Caddyfile
cat > Caddyfile <<EOF
:80 {
  redir https://{host}{uri}
}

:443 {
  respond "Access via IP is disabled" 403
}

${DOMAIN} {
  encode gzip
  reverse_proxy qbittorrent:8080
}
EOF

echo "=== Konténerek indítása ==="
docker compose pull
docker compose up -d

echo "=== Jelszó keresése ==="
PASSWORD=""
for i in {1..60}; do
  PASSWORD=$(docker logs qbittorrent 2>&1 \
    | grep -oP "temporary password .*: \K.*" || true)
  [ -n "$PASSWORD" ] && break
  sleep 2
done
[ -z "$PASSWORD" ] && PASSWORD="NEM TALÁLHATÓ – futtasd: docker logs qbittorrent"

echo
echo "==========================================="
echo "     ✔ HTTPS DOMAIN TELEPÍTÉS KÉSZ"
echo "==========================================="
echo "Domain:      https://${DOMAIN}"
echo "WebUI:       https://${DOMAIN}"
echo "Felhasználó: admin"
echo "Jelszó:      ${PASSWORD}"
echo "Aktív port:  6881"
echo "Telepítési könyvtár: ${INSTALL_DIR}"
echo "Let’s Encrypt automatikusan működik."
echo "==========================================="
