# My Plex container

[![Check running](https://github.com/Luctia/ezarr/actions/workflows/check_running.yml/badge.svg)](https://github.com/Luctia/ezarr/actions/workflows/check_running.yml)

This repository

- [Sonarr](https://sonarr.tv/) is an application to manage TV shows. It is capable of keeping track
  of what you'd like to watch, at what quality, in which language and more, and can find a place to
  download this if connected to Prowlarr and qBittorrent. It can also reorganize the media you
  already own in order to create a more uniformly formatted collection.
- [Radarr](https://radarr.video/) is like Sonarr, but for movies.
- [Readarr](https://readarr.com/) is like Sonarr, but for books.
- [Audiobookshelf](https://www.audiobookshelf.org/) is a self-hosted audiobook and podcast server.
- [Prowlarr](https://wiki.servarr.com/prowlarr) can keep track of indexers, which are services that
  keep track of Torrent or UseNet links. One can search an indexer for certain content and find a
  where to download this. **Note**: when adding an indexer, please do not set the "seed ratio" to
  less than 1. Less than 1 means that you upload less than you download. Not only is this
  unfriendly towards your fellow users, but it can also get you banned from certain indexers.
- [qBittorrent](https://www.qbittorrent.org/) can download torrents and provides a bunch more
  features for management.
- [PleX](https://www.plex.tv/) is a mediaserver. Using this, you get access to a Netflix-like
  interface across many devices like your laptop or computer, your phone, your TV and more. For
  some features, you need a [PleX pass](https://www.plex.tv/nl/plex-pass/).
- [Tautulli](https://tautulli.com/) is a monitoring application for PleX  which can keep track of
  what has been watched, who watched it, when and where they watched it, and how it was watched.
- [Overseerr](https://overseerr.dev/) is a show and movie request management and media discovery
   tool.

## Setup

1. To get started, clone the repository in a directory of your choosing. **Note: this will be where
   your installation and media will be as well, so think about this a bit.**
2. Copy `.env.sample` to a real `.env` by running `$ cp .env.sample .env`.
3. Set the environment variables to your liking. Note that `ROOT_DIR` should be the directory you
   have cloned this in.
4. Run `setup.sh` as superuser. This will set up your users, a system of directories, ensure
   permissions are set correctly and sets some more environment variables for docker compose.
5. Take a look at the `docker-compose.yml` file. If there are services you would like to ignore,
   you can comment them out by placing `#` in front of the lines. This ensures they are ignored by Docker compose.
6. Run `docker compose up`.

That's it! Your containers are now up and you can continue to set up the settings in them. Please
take a look at [important notes](#important-notes) before you continue.

## Update Docker Compose Containers

To update your containers to the latest images:

1. Pull latest images:

   ```bash
   docker compose pull
   ```

2. Then restart containers:

   ```bash
   docker compose up -d --remove-orphans
   ```

3. Optionally, remove obsolete images:

```bash
docker image prune
```

## Get IP Address

To get your server's IP address:

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## Services Documentation

This stack includes the following services:

### Active Services

- **gluetun** (VPN)
  - Port: 8080 (for qBittorrent)
  - VPN service provider wrapper that routes traffic through a VPN. Used by qBittorrent and qbittorrent-natmap.

- **qbittorrent** (Torrent Client)
  - Port: 8080 (via gluetun)
  - BitTorrent client with web UI. Downloads torrents found by the *arr services.

- **qbittorrent-natmap** (NAT Mapping)
  - No exposed ports (uses gluetun network)
  - Automatically maps NAT ports for qBittorrent to improve connectivity.

- **sonarr** (TV Shows)
  - Port: 8989
  - Manages TV show collection, monitors for new episodes, and organizes downloads.

- **radarr** (Movies)
  - Port: 7878
  - Manages movie collection, monitors for releases, and organizes downloads.

- **prowlarr** (Indexer Manager)
  - Port: 9696
  - Manages indexers (torrent/usenet trackers) and syncs them with Sonarr, Radarr, and other *arr services.

- **plex** (Media Server)
  - Port: 32400 (web), 32469 (DLNA), 1900 (DLNA UDP), 3005 (GDM), 8324 (roku), 32410-32414 (additional ports)
  - Media server that organizes and streams your media collection.
  - **Troubleshooting**:
    - **Database corruption error**: If you see "database disk image is malformed", the database was likely corrupted during migration:
      1. Stop Plex: `docker compose stop plex`
      2. Backup the corrupted database: `cp /config/plex-config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db /config/plex-config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/backups/`
      3. Remove corrupted database files: `rm -f /config/plex-config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db*`
      4. Start Plex: `docker compose up -d plex` (Plex will create a new database)
      5. Re-add your media libraries through the web interface
    - **Permission issues**: Ensure the Plex config directory has correct ownership matching `PUID_PLEX` and `PGID`

- **tautulli** (Plex Monitoring)
  - Port: 8181
  - Monitors Plex media server activity, tracks what's being watched, and provides analytics.

- **plextraktsync** (Plex-Trakt Sync)
  - No exposed ports
  - Syncs movies, shows, and ratings between Plex and Trakt.tv. Runs scheduled syncs every 6 hours via Ofelia scheduler.
  - **Setup**:
    1. Create a Trakt API app at <https://trakt.tv/oauth/applications/new>
       - Use `urn:ietf:wg:oauth:2.0:oob` as the redirect URL
       - You can leave JavaScript origins and Permissions checkboxes blank
    2. Start the containers: `docker compose up -d plex plextraktsync`
    3. Run the login command: `docker compose exec -it plextraktsync plextraktsync login`
       - Follow the prompts to authenticate with both Plex and Trakt
       - PlexTraktSync will automatically discover your Plex server
       - If you have 2FA enabled on Plex, enter the code when prompted
    4. Configuration files (`.env`, `.pytrakt.json`, `servers.yml`) will be created in `/config/plextraktsync-config`
    5. After authentication, the scheduler will automatically run syncs every 6 hours
  - **Scheduler**: Uses Ofelia to run sync jobs automatically. To change the interval, modify the `ofelia.job-exec.plextraktsync.schedule` label in docker-compose.yml (e.g., `@every 12h` for 12 hours).

- **overseerr** (Media Requests)
  - Port: 5055
  - Media request management and discovery tool. Allows users to request movies and TV shows.

- **bazarr** (Subtitles)
  - Port: 6767
  - Manages and downloads subtitles for movies and TV shows in your collection.

- **tdarr** (Media Transcoding)
  - Ports: 8265 (webUI), 8266 (server), 8267 (internal node)
  - Distributed transcoding system for optimizing media files. Includes server and node components.

- **tdarr-node** (Transcoding Node)
  - No exposed ports (uses tdarr network)
  - Worker node for tdarr that performs the actual transcoding tasks.

- **recyclarr** (Quality Profile Sync)
  - No exposed ports (CLI tool, no web UI)
  - Automatically synchronizes recommended settings from TRaSH guides to Sonarr and Radarr instances.
  - **Setup**:
    1. Start the container: `docker compose up -d recyclarr`
    2. Generate default configuration file:

       ```bash
       docker compose exec recyclarr recyclarr config create
       ```

       This creates `/config/recyclarr-config/recyclarr.yml`
    3. Get API keys from Sonarr and Radarr:
       - Sonarr: Settings → General → API Key
       - Radarr: Settings → General → API Key
    4. Edit `/config/recyclarr-config/recyclarr.yml` and add your instances:

       ```yaml
       sonarr:
         - base_url: http://sonarr:8989
           api_key: YOUR_SONARR_API_KEY_HERE
       
       radarr:
         - base_url: http://radarr:7878
           api_key: YOUR_RADARR_API_KEY_HERE
       ```

    5. Test the configuration:

       ```bash
       docker compose exec recyclarr recyclarr sync
       ```

  - **Manual sync**: Run `docker compose exec recyclarr recyclarr sync` anytime to sync manually
  - **Scheduling**: To run Recyclarr automatically, set up a cron job or use your system's task scheduler to run the sync command periodically.

### Commented Out Services

The following services are available in docker-compose.yml but are commented out by default:

- **readarr-ebooks** (Books - Ebooks instance)
- **readarr-audiobooks** (Books - Audiobooks instance)
- **ersatztv** (Live TV/DVR)
- **audiobookshelf** (Audiobook Server)
- **epicgames-freegames** (Epic Games Free Games)

To enable any of these services, uncomment their configuration in `docker-compose.yml`.

## Important notes

- When linking one service to another, remember to use the container name instead of `localhost`.
- Please set the settings of the *arr containers as soon as possible to the following (use
  advanced):
  - Media management:
    - Use hardlinks instead of Copy: `true`
    - Root folder: `/data/media/` and then tv, movies or music depending on service
  - Make sure to set a username and password for all servarr services and qBittorrent!
- In qBittorrent, after connecting it to the *arr services, you can indicate it should move
  torrents in certain categories to certain directories, like torrents in the `radarr` category
  to `/data/torrents/movies`. You should do this. Also set the `Default Save Path` to
  `/data/torrents`. Set "Run external program on torrent completion" to true and enter this in the
  field: `chmod -R 775 "%F/"`.
- You'll have to add indexers in Prowlarr by hand. Use Prowlarrs settings to connect it to the
  other *arr apps.
