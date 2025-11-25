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
  <b>Debian 13 | HTTPS | Domain vagy IP alapú elérés</b>
</p>

---

## 📌 Leírás

Ez a projekt egy teljesen automatizált telepítő scriptet tartalmaz, amellyel gyorsan és egyszerűen létrehozhatsz egy biztonságos qBittorrent seed szervert Docker környezetben.

A script telepítés közben rákérdez:
- hogyan szeretnéd elérni a WebUI-t  
  ✔ IP: http://IP:8080  
  ✔ Domain + HTTPS (Caddy reverse proxy)

Domain mód esetén automatikusan konfigurálja:
- a HTTPS-t (Let's Encrypt)
- az IP alapú elérés tiltását
- a kizárólag domain-hozzáférést

A script a qBittorrent által generált ideiglenes jelszót is automatikusan kiolvassa és megjeleníti.

---

## 🚀 Funkciók

- Teljesen automatizált telepítés (Docker + qBittorrent + Caddy)
- IP vagy DOMAIN alapú WebUI elérés
- Automatikus Let's Encrypt tanúsítványkezelés
- Reverse proxy Caddy-vel
- IP alapú elérés automatikus tiltása domain módban
- Első induláskor generált admin jelszó automatikus kiolvasása
- Stabil, biztonságos alapbeállítások
- Telepítés dedikált könyvtárba: `/opt/qbittorrent-install`

---

## 📥 Telepítés

1. Hozd létre a telepítő fájlt:  
   `nano qbittorrent_install.sh`

2. Másold bele a scriptet és mentsd el.

3. Adj futási jogot:  
   `chmod +x qbittorrent_install.sh`

4. Futtasd:  
   `sudo ./qbittorrent_install.sh`

5. A script futás közben kérni fogja:
   - hogy IP vagy DOMAIN módot választasz
   - DOMAIN mód esetén a saját domaint (pl. qb.pelda.hu)

---

## 🌐 Elérés

### ➤ 1) IP alapú telepítés esetén  
- WebUI: `http://IP:8080`  
- Felhasználó: `admin`  
- Jelszó: automatikusan kiírva  
- Port: `6881` (TCP/UDP)

### ➤ 2) Domain + HTTPS telepítés esetén  
- WebUI: `https://sajatdomain.hu`  
- Felhasználó: `admin`  
- Jelszó: automatikusan kiírva  
- Automatikus HTTPS (Let's Encrypt)  
- IP elérés tiltva  

---

## 🔐 Biztonság

Domain mód esetén:
- IP elérés automatikusan blokkolva (403 Forbidden)
- HTTPS automatikusan aktiválva
- qBittorrent WebUI csak domainen keresztül érhető el

---

## 🛠 Követelmények

- Debian 12 vagy 13
- Root jogosultság
- VPS (KVM)
- Domain módhoz:
  - A/AAAA rekord a VPS IP-re mutasson
  - 80 és 443 port legyen nyitva

---

## 🔄 Konténerek frissítése

A konténerek frissítéséhez futtasd:

- `docker compose pull`
- `docker compose up -d`
- `docker image prune -f`

---

## 🧑‍💻 Készítette

**Doky**  
2025.11.25
