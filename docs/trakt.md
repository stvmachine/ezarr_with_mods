# PlexTraktSync Setup Guide

PlexTraktSync syncs movies, shows, and ratings between Plex and Trakt.tv. It runs scheduled syncs every 6 hours via Ofelia scheduler.

## Setup

1. Create a Trakt API app at <https://trakt.tv/oauth/applications/new>
   - Use `urn:ietf:wg:oauth:2.0:oob` as the redirect URL
   - You can leave JavaScript origins and Permissions checkboxes blank

2. Start the containers:
   ```bash
   docker compose up -d plex plextraktsync
   ```

3. Run the login command:
   ```bash
   docker compose exec -it plextraktsync plextraktsync login
   ```
   - Follow the prompts to authenticate with both Plex and Trakt
   - PlexTraktSync will automatically discover your Plex server
   - If you have 2FA enabled on Plex, enter the code when prompted

4. Configuration files (`.env`, `.pytrakt.json`, `servers.yml`) will be created in `/config/plextraktsync-config`

5. After authentication, the scheduler will automatically run syncs every 6 hours

## Scheduler

Uses Ofelia to run sync jobs automatically. To change the interval, modify the `ofelia.job-exec.plextraktsync.schedule` label in docker-compose.yml (e.g., `@every 12h` for 12 hours).

## Manual Sync

You can also run syncs manually:
```bash
docker compose exec plextraktsync plextraktsync sync
```

