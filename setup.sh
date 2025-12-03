#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  set -a
  source .env
  set +a
else
  echo "Error: .env file not found. Please copy .env.sample to .env and configure it first."
  exit 1
fi

# Make users and group
sudo groupadd mediacenter -g ${PGID:-13000} 2>/dev/null || true

# Active services - create users using PUID values from .env
sudo useradd sonarr -u ${PUID_SONARR:-13001} 2>/dev/null || true
sudo useradd radarr -u ${PUID_RADARR:-13002} 2>/dev/null || true
sudo useradd prowlarr -u ${PUID_PROWLARR:-13006} 2>/dev/null || true
sudo useradd qbittorrent -u ${PUID_QBITTORRENT:-13032} 2>/dev/null || true
sudo useradd gluetun -u ${PUID_GLUETUN:-13031} 2>/dev/null || true
sudo useradd qbittorrent-natmap -u ${PUID_QBITTORRENT_NATMAP:-13033} 2>/dev/null || true
sudo useradd plex -u ${PUID_PLEX:-13020} 2>/dev/null || true
sudo useradd tautulli -u ${PUID_TAUTULLI:-13007} 2>/dev/null || true
sudo useradd plextraktsync -u ${PUID_PLEXTRAKTSYNC:-13015} 2>/dev/null || true
sudo useradd overseerr -u ${PUID_OVERSEERR:-13008} 2>/dev/null || true
sudo useradd bazarr -u ${PUID_BAZARR:-13009} 2>/dev/null || true
sudo useradd tdarr -u ${PUID_TDARR:-13010} 2>/dev/null || true
sudo useradd tdarr-node -u ${PUID_TDARR_NODE:-13011} 2>/dev/null || true
sudo useradd recyclarr -u ${PUID_RECYCLARR:-13003} 2>/dev/null || true

# Add users to mediacenter group
sudo usermod -a -G mediacenter sonarr 2>/dev/null || true
sudo usermod -a -G mediacenter radarr 2>/dev/null || true
sudo usermod -a -G mediacenter prowlarr 2>/dev/null || true
sudo usermod -a -G mediacenter qbittorrent 2>/dev/null || true
sudo usermod -a -G mediacenter gluetun 2>/dev/null || true
sudo usermod -a -G mediacenter qbittorrent-natmap 2>/dev/null || true
sudo usermod -a -G mediacenter plex 2>/dev/null || true
sudo usermod -a -G mediacenter tautulli 2>/dev/null || true
sudo usermod -a -G mediacenter plextraktsync 2>/dev/null || true
sudo usermod -a -G mediacenter overseerr 2>/dev/null || true
sudo usermod -a -G mediacenter bazarr 2>/dev/null || true
sudo usermod -a -G mediacenter tdarr 2>/dev/null || true
sudo usermod -a -G mediacenter tdarr-node 2>/dev/null || true
sudo usermod -a -G mediacenter recyclarr 2>/dev/null || true

# Make directories (using absolute paths as in docker-compose.yml)
sudo mkdir -pv /config/{gluetun-config,qbittorrent-config,qbittorrent-natmap-config,sonarr-config,radarr-config,prowlarr-config,plex-config,tautulli-config,plextraktsync-config,overseerr-config,bazarr-config,tdarr-server-config,tdarr-client-config,recyclarr-config}
sudo mkdir -pv /config/tmp/gluetun
sudo mkdir -pv /data/{torrents,media}
sudo mkdir -pv /transcode_cache

# Set permissions
sudo chmod -R 775 /data/
sudo chmod -R 775 /config/
sudo chown -R $(id -u):mediacenter /data/
sudo chown -R $(id -u):mediacenter /config/
sudo chown -R sonarr:mediacenter /config/sonarr-config
sudo chown -R radarr:mediacenter /config/radarr-config
sudo chown -R prowlarr:mediacenter /config/prowlarr-config
sudo chown -R qbittorrent:mediacenter /config/qbittorrent-config
sudo chown -R gluetun:mediacenter /config/gluetun-config
sudo chown -R qbittorrent-natmap:mediacenter /config/qbittorrent-natmap-config
sudo chown -R plex:mediacenter /config/plex-config
sudo chown -R tautulli:mediacenter /config/tautulli-config
sudo chown -R plextraktsync:mediacenter /config/plextraktsync-config
sudo chown -R overseerr:mediacenter /config/overseerr-config
sudo chown -R bazarr:mediacenter /config/bazarr-config
sudo chown -R tdarr:mediacenter /config/tdarr-server-config
sudo chown -R tdarr-node:mediacenter /config/tdarr-client-config
sudo chown -R recyclarr:mediacenter /config/recyclarr-config

echo "UID=$(id -u)" >> .env
