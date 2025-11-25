<h1 align="center">🚀 qBittorrent Seed Szerver Telepítő (Docker + Caddy)</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Debian-13-red?style=for-the-badge&logo=debian" />
  <img src="https://img.shields.io/badge/Docker-Supported-2496ED?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/qBittorrent-Enabled-blue?style=for-the-badge&logo=qBittorrent" />
  <img src="https://img.shields.io/badge/Caddy-HTTPS-green?style=for-the-badge&logo=caddy" />
  <img src="https://img.shields.io/badge/Secure-HTTPS%20Only-brightgreen?style=for-the-badge&logo=letsencrypt" />
  <img src="https://img.shields.io/badge/Author-Doky-purple?style=for-the-badge&logo=github" />
</p>

<p align="center">
  <b>Debian 13 | HTTPS | Domain vagy IP alapú elérés | 6881 TCP/UDP port automatikusan nyitva</b>
</p>

---

## 📌 Leírás

Ez a projekt egy teljesen automatizált telepítő scriptet tartalmaz, amellyel gyorsan és egyszerűen létrehozhatsz egy biztonságos qBittorrent seed szervert Docker környezetben.

A script telepítés közben megkérdezi:
- hogyan szeretnéd elérni a WebUI-t  
  ✔ IP (http://IP:8080)  
  ✔ Domain + HTTPS (Caddy reverse proxy)

Domain mód esetén:
- automatikus HTTPS (Let's Encrypt)
- IP alapú elérés tiltása
- kizárólag domain hozzáférés
- automatikus jelszókiolvasás

ℹ️ Fontos:  
A telepítő alapértelmezetten megnyitja a **6881-es TCP és UDP bejövő portokat**, így a qBittorrent aktív módban működik (DHT, peer-ek, seeding teljes sebességgel).

---

## 🚀 Funkciók

- Teljesen automatizált telepítés (Docker + qBittorrent + Caddy)
- IP vagy DOMAIN alapú elérés
- Automatikus Let's Encrypt HTTPS
- IP hozzáférés tiltása domain módban
- qBittorrent jelszó automatikus kiolvasása
- Letisztított, biztonságos Docker stack
- **6881 TCP/UDP port automatikusan nyitva**
- Telepítési könyvtár: `/opt/qbittorrent-install`

---

## 📥 Telepítés

1. Hozd létre a telepítő fájlt:
   ```bash
   nano qbittorrent_install.sh

3. Másold bele a scriptet és mentsd el.

4. Adj futási jogot:
   ```bash
   chmod +x qbittorrent_install.sh

6. Futtasd:
   ```bash
   sudo ./qbittorrent_install.sh

A telepítő kérni fogja:
- IP vagy DOMAIN mód kiválasztását  
- DOMAIN mód esetén a domaint (pl. qb.pelda.hu)

---

## 🌐 Elérés

### ➤ IP alapú
- WebUI: `http://IP:8080`  
- Felhasználó: `admin`  
- Jelszó: automatikusan kiírva  
- Bejövő port: **6881 TCP/UDP (nyitva)**

### ➤ Domain + HTTPS
- WebUI: `https://sajatdomain.hu`  
- HTTPS automatikusan  
- IP hozzáférés tiltva  
- Felhasználó: `admin`  
- Jelszó: megjelenik a telepítés végén  

---

## 🔐 Biztonság

Domain mód esetén:
- 443-as IP elérés → *403 Forbidden*  
- automatikus HTTPS  
- automatikus tanúsítvány megújítás  
- kizárólag domainen működik a WebUI  

---

## 🛠 Követelmények

- Debian 13
- Root jog
- VPS
- Domain mód esetén: A/AAAA rekord + nyitott 80/443

---

# 🔄 Konténerek frissítése

1. A konténerek kézi frissítéséhez futtasd:
   ```bash
   cd /opt/qbittorrent-install
   docker compose pull
   docker compose up -d
   docker image prune -f

---

# 🆙 Frissítő Script (Update Script)

### 📥 Telepítés

1) Hozd létre az update script fájlt:
   ```bash
   nano /opt/qbittorrent-install/qbittorrent_update.sh

4) Másold bele az itt található **qbittorrent_update.sh** script tartalmát, majd mentsd el.

5) Adj futási jogot:
   ```bash
   chmod +x /opt/qbittorrent-install/update.sh

4) Indítsd el:
   ```bash
   sudo /opt/qbittorrent-install/update.sh

---

## 🧑‍💻 Készítette

**Doky**

2025.11.25
