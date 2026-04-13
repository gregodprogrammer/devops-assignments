# Architecture Diagram — EpicBook Capstone

## Component Diagram
## Network Isolation
- frontend-net: nginx ↔ app (public-facing)
- backend-net: app ↔ db (private, DB never exposed)

## Port Exposure
- Port 80: PUBLIC (Nginx only)
- Port 8080: INTERNAL only (app, not published)
- Port 3306: INTERNAL only (db, not published)

## Data Persistence
- db_data: MySQL data directory (named volume)
- nginx_logs: Nginx access + error logs (named volume)
