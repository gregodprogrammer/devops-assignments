# Healthchecks & Startup Order

## Startup Order
db → app → nginx

## Healthcheck Definitions

### DB Healthcheck
- Command: mysqladmin ping
- Interval: 10s
- Timeout: 5s
- Retries: 5
- Start period: 30s (MySQL takes time to initialize)

### App Healthcheck
- Command: wget -qO- http://localhost:8080/
- Interval: 30s
- Timeout: 10s
- Retries: 3
- Start period: 40s (waits for DB connection + Sequelize sync)

### Nginx Healthcheck
- Command: wget -qO- http://localhost/health
- Interval: 30s
- Timeout: 5s
- Retries: 3

## depends_on Logic
- app depends_on db: condition service_healthy
- nginx depends_on app: condition service_healthy

This guarantees MySQL is accepting connections before
the app starts, and the app is serving before Nginx
begins routing traffic.
