# Plex Setup Guide

Plex is a media server that organizes and streams your media collection. It provides a Netflix-like interface across many devices like your laptop, computer, phone, and TV.

## Ports

- **32400** - Web interface
- **32469** - DLNA
- **1900** - DLNA UDP
- **3005** - GDM
- **8324** - Roku
- **32410-32414** - Additional ports

## Initial Setup

1. Start the Plex container:
   ```bash
   docker compose up -d plex
   ```

2. Access the web interface at `http://your-server-ip:32400/web`

3. Complete the initial setup wizard:
   - Sign in or create a Plex account
   - Claim your server (if using `PLEX_CLAIM` environment variable, this is automatic)
   - Add your media libraries

4. Configure your media libraries:
   - Add libraries for Movies, TV Shows, Music, etc.
   - Point each library to the appropriate directory in `/data/media/`

## Configuration

The Plex configuration is stored in `/config/plex-config`. Ensure this directory has correct ownership matching `PUID_PLEX` and `PGID` environment variables.

## Troubleshooting

### Database Corruption Error

If you see "database disk image is malformed", the database was likely corrupted during migration:

1. Stop Plex:
   ```bash
   docker compose stop plex
   ```

2. Backup the corrupted database:
   ```bash
   cp /config/plex-config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db /config/plex-config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/backups/
   ```

3. Remove corrupted database files:
   ```bash
   rm -f /config/plex-config/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/Databases/com.plexapp.plugins.library.db*
   ```

4. Start Plex (it will create a new database):
   ```bash
   docker compose up -d plex
   ```

5. Re-add your media libraries through the web interface

### Permission Issues

If Plex cannot access your media files or configuration:

1. Ensure the Plex config directory has correct ownership:
   ```bash
   sudo chown -R plex:mediacenter /config/plex-config
   ```

2. Verify the `PUID_PLEX` and `PGID` environment variables in your `.env` file match the user/group IDs

3. Ensure media directories are accessible:
   ```bash
   sudo chmod -R 775 /data/media
   sudo chown -R $(id -u):mediacenter /data/media
   ```

## Plex Pass

Some features require a [Plex Pass](https://www.plex.tv/nl/plex-pass/), including:
- Hardware-accelerated transcoding
- Mobile sync
- Premium music features
- Early access to new features

## Additional Resources

- [Plex Documentation](https://support.plex.tv/)
- [Plex Forums](https://forums.plex.tv/)

