# Recyclarr Setup Guide

Recyclarr automatically synchronizes recommended settings from TRaSH guides to Sonarr and Radarr instances.

## Setup

1. Start the container:
   ```bash
   docker compose up -d recyclarr
   ```

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

## Manual Sync

Run `docker compose exec recyclarr recyclarr sync` anytime to sync manually.

## Scheduling

To run Recyclarr automatically, set up a cron job or use your system's task scheduler to run the sync command periodically.

Example cron job (runs every 6 hours):
```bash
0 */6 * * * docker compose -f /path/to/docker-compose.yml exec -T recyclarr recyclarr sync
```

