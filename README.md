<h1 align="center">🚀 qBittorrent Seed Szerver Telepítő (IP + Domain mód)</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/qBittorrent-Linuxserver.io-blue?style=for-the-badge&logo=qBittorrent" />
  <img src="https://img.shields.io/badge/Caddy-HTTPS-green?style=for-the-badge&logo=caddy" />
  <img src="https://img.shields.io/badge/Transdrone-Compatible-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Author-Doky-purple?style=for-the-badge" />
</p>

---

## 📌 Leírás

Ez a telepítő script egy automatizált qBittorrent Seed Szerver környezetet hoz létre Debian 13 rendszeren, Docker alapokon.

Jellemzők:
- linuxserver/qbittorrent konténer használata
- IP vagy Domain alapú telepítési mód
- Domain módban automatikus HTTPS Caddy reverse proxyval
- qBittorrent automatikusan generált admin jelszó kiolvasása (session log alapján)
- 6881 TCP/UDP torrent port automatikusan megnyitva
- 100%-os Transdrone kompatibilitás IP-n keresztül

A telepítő stabil, egyszerű, biztonságos és naprakész.

---

## 📦 Követelmények

A telepítő futtatásához szükséges:

- Debian 13 (ajánlott tiszta rendszer)
- Root jogosultság
- Internetkapcsolat (Docker image-ek miatt)
- Szabad 8080-as port (qBittorrent WebUI)
- Szabad 6881 TCP/UDP port (torrent bejövő port)
- Domain mód esetén:
  - működő domain név
  - domain A rekord → VPS IP-re mutasson
  - szabad 80 és 443 port (Caddy számára)

---

## 🌐 Elérés

### IP mód esetén

WebUI:  
http://szerver_ip:8080

Transdrone:  
Host: szerver_ip  
Port: 8080

### Domain mód esetén

WebUI (HTTPS):  
https://te.domained.hu

IP (mindig működik):  
http://szerver_ip:8080

Transdrone:  
Host: szerver_ip  
Port: 8080

---

## 🧩 Funkciók

| Funkció | Részletek |
|--------|-----------|
| Telepítési mód | IP vagy Domain (Caddy + HTTPS) |
| qBittorrent | linuxserver.io image |
| Reverse proxy | Caddy |
| HTTPS | automatikus tanúsítványkezelés |
| Portok | 6881 TCP/UDP + 8080 WebUI |
| Transdrone | Teljes kompatibilitás IP-n |
| Jelszó | Automatikusan kiolvasva a logokból |

---

## 📥 Telepítés

1) Hozd létre a telepítő fájlt:  
   ```bash
   nano qbittorrent_install.sh
   - Másold bele a scriptet és mentsd el.

2) Futási jog adása:  
   ```bash
   chmod +x qbittorrent_install.sh

3) Telepítés indítása:  
   ```bash
   sudo ./qbittorrent_install.sh

A telepítő kérni fogja:
- IP vagy DOMAIN mód kiválasztását  
- DOMAIN mód esetén a domaint (pl. te.domained.hu)

A telepítő automatikusan:
- telepíti a Dockert (ha nincs)
- generálja a docker-compose.yml-t
- domain módban létrehozza a Caddyfile-t
- elindítja a konténereket
- kiolvassa az admin jelszót
- végül rendezett összegzést ad

---

## 📱 Transdrone beállítás

A Transdrone alkalmazás segítségével távolról kezelheted a qBittorrent szerveredet.

### Transdrone letöltése (Google Play)

Link:  
https://play.google.com/store/apps/details?id=org.transdroid.lite

Google Play-ben kereshető:  
Transdrone  
vagy  
Transdroid Lite

### Transdrone beállítás (IP alapján)

Host: szerver_ip  
Port: 8080  
User: admin  
Pass: a telepítő végén kiírt jelszó

---

## 🔧 Konténerek kézi frissítése

A konténerek manuálisan is frissíthetők sima Docker parancsokkal.

### 1) Új image-ek letöltése  
docker pull lscr.io/linuxserver/qbittorrent:latest  
docker pull caddy:latest   (csak domain mód esetén)

### 2) Konténerek újraindítása  
cd /opt/qbittorrent-seed  
docker compose down  
docker compose up -d

### 3) Régi image-ek törlése  
docker image prune -f

---

# 🆙 Frissítő Script (Update Script)

### 📥 Telepítés

1) Hozd létre az update script fájlt:
   ```bash
   nano /opt/qbittorrent-seed/qbittorrent_update.sh

4) Másold bele az itt található **qbittorrent_update.sh** script tartalmát, majd mentsd el.

5) Adj futási jogot:
   ```bash
   chmod +x /opt/qbittorrent-seed/qbittorrent_update.sh

4) Indítsd el:
   ```bash
   sudo /opt/qbittorrent-seed/qbittorrent_update.sh

---

## 📂 Könyvtárstruktúra

/opt/qbittorrent-seed  
 ├── config  
 ├── downloads  
 ├── Caddyfile (ha domain mód)  
 ├── caddy-data (ha domain mód)  
 ├── caddy-config (ha domain mód)  
 └── docker-compose.yml

---

## ❤️ Készítette: Doky  
📅 2025