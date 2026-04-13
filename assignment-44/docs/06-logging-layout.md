# Logging Layout

## Log Sources

### Nginx Logs (nginx_logs volume)
- /var/log/nginx/access.log — all HTTP requests
- /var/log/nginx/error.log — proxy errors

### App Logs (stdout)
- console.log() output captured by Docker
- View with: docker logs epicbook-app -f

### DB Logs (stdout)
- MySQL startup and error messages
- View with: docker logs epicbook-db -f

## Viewing Logs
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f db
docker compose logs -f nginx

# Nginx access log (from volume)
docker exec epicbook-nginx cat /var/log/nginx/access.log

## Log Retention
- Docker stdout: last 100MB per container (default)
- Nginx volume: persists until manually rotated
- Recommended: logrotate for production

## Optional Enhancement
Fluent Bit sidecar could forward logs to Azure Monitor
or Elasticsearch — not implemented in this version.
