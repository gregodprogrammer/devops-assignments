# Environment Variables & Ports

## Environment Variables

| Variable | Used By | Description |
|----------|---------|-------------|
| NODE_ENV | app | Runtime environment (development) |
| PORT | app | App listening port (8080) |
| DB_HOST | app | DB service name (db) |
| DB_USER | app | MySQL username (root) |
| DB_PASSWORD | app | MySQL password |
| DB_NAME | app | Database name (bookstore) |
| MYSQL_ROOT_PASSWORD | db | MySQL root password |
| NGINX_PORT | nginx | Nginx listen port (80) |

## Port Map

| Service | Internal Port | External Port | Accessible From |
|---------|--------------|---------------|-----------------|
| nginx | 80 | 80 | Public internet |
| app | 8080 | None | Internal only |
| db | 3306 | None | Internal only |

## Data That Must Persist
- /var/lib/mysql — all book, author, order data
- /var/log/nginx — access and error logs

## Seed Files (auto-loaded on first boot)
- BuyTheBook_Schema.sql — creates tables
- author_seed.sql — seeds authors
- books_seed.sql — seeds book catalogue
