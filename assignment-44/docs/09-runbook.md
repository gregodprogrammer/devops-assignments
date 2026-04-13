# Operations Runbook — EpicBook

## Start Stack
cd ~/devops-assignments/assignment-44
docker compose up -d --build

## Stop Stack
docker compose down

## Restart Single Service
docker compose restart app
docker compose restart nginx
docker compose restart db

## View Logs
docker compose logs -f           # all services
docker compose logs -f app       # app only
docker compose logs -f db        # database only

## Check Health
docker compose ps
docker inspect epicbook-app | grep Health

## Rollback Procedure
# Pull previous image version
docker compose down
git checkout <previous-commit>
docker compose up -d --build

## Rotate Secrets
1. Update .env with new password
2. docker compose down
3. docker volume rm assignment-44_db_data  # WARNING: destroys data
4. docker compose up -d --build
# OR for zero-data-loss rotation:
# Update MySQL password via SQL first, then update .env

## Backup & Restore
# Backup
docker exec epicbook-db mysqldump \
  -u root -pEpicBook2026 bookstore > backup.sql

# Restore
docker exec -i epicbook-db mysql \
  -u root -pEpicBook2026 bookstore < backup.sql

## Common Errors & Fixes

| Error | Fix |
|-------|-----|
| App fails to start | Check DB healthcheck: docker logs epicbook-db |
| Port 80 already in use | sudo lsof -i :80 then kill the process |
| DB connection refused | Wait 30s for MySQL init, check healthcheck |
| Container exits immediately | docker logs <container> to see error |
| Out of disk space | docker system prune to clean unused images |

## Log Locations
- App: docker logs epicbook-app
- DB: docker logs epicbook-db
- Nginx: docker exec epicbook-nginx cat /var/log/nginx/access.log
