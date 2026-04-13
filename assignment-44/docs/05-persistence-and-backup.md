# Persistence & Backup Plan

## What Persists
- db_data volume: all MySQL data (books, authors, orders)
- nginx_logs volume: Nginx access and error logs

## Backup Strategy

### What to Backup
1. MySQL dump (logical backup)
2. db_data volume (physical backup)

### Backup Commands
# MySQL logical dump
docker exec epicbook-db mysqldump \
  -u root -pEpicBook2026 bookstore \
  > backup_$(date +%Y%m%d).sql

# Restore from dump
docker exec -i epicbook-db mysql \
  -u root -pEpicBook2026 bookstore \
  < backup_20260413.sql

### Backup Schedule
- Daily SQL dump at 02:00 AM (cron job)
- Weekly volume snapshot

### Where to Store
- Same VM: /home/azureuser/backups/ (short term)
- Azure Blob Storage (long term — production)

## Persistence Test
1. Add books to cart / place order
2. Run: docker compose down
3. Run: docker compose up -d
4. Verify data still present — volumes survive restarts
