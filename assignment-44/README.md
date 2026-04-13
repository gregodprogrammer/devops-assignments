# Assignment 44 — EpicBook Capstone

**DMI Cohort-2 | DevOps Micro-Internship by Pravin Mishra**
**Author:** Greg Odi (gregodprogrammer) | April 13, 2026

---

## Overview

EpicBook is a full-stack bookstore web application deployed as a containerized 3-tier stack on Microsoft Azure. The stack consists of:

- **Nginx** — reverse proxy (port 80, public)
- **Node.js/Express** — EpicBook application (port 8080, internal only)
- **MySQL 8.0** — bookstore database (port 3306, internal only)

The application uses Docker Compose for orchestration, with isolated Docker networks, named volumes for data persistence, healthcheck-based startup ordering, and a multi-stage Dockerfile that reduces the Node.js image from ~2GB to ~94MB.

---

## Architecture

```
Internet → Port 80
    ↓
  Nginx (epicbook-nginx)       [frontend-net only]
    ↓ proxy_pass http://app:8080
  Node.js App (epicbook-app)   [frontend-net + backend-net]
    ↓ Sequelize ORM / mysql2
  MySQL (epicbook-db)          [backend-net ONLY]
```

### Networks
| Network | Services Connected |
|---|---|
| frontend-net | nginx ↔ app |
| backend-net | app ↔ db |

### Ports
| Service | Internal Port | External Port |
|---|---|---|
| nginx | 80 | 80 (public) |
| app | 8080 | none (internal) |
| db | 3306 | none (internal) |

---

## Project Structure

```
assignment-44/
├── app/                        # EpicBook Node.js source
│   ├── Dockerfile              # Multi-stage: builder + runtime
│   ├── .dockerignore
│   ├── config/config.json      # DB config (host=db, password from env)
│   ├── db/
│   │   ├── BuyTheBook_Schema.sql
│   │   ├── author_seed.sql
│   │   └── books_seed.sql
│   ├── models/
│   ├── routes/
│   ├── views/
│   ├── public/
│   ├── server.js
│   └── package.json
├── nginx/
│   └── nginx.conf              # Reverse proxy: port 80 → app:8080
├── docs/                       # Architecture and design docs
├── screenshots/                # Deployment proof screenshots
├── .env.example                # Env variable template (no secrets)
├── .gitignore                  # Excludes .env, *.log, node_modules
└── docker-compose.yml          # Full 3-tier stack definition
```

---

## Part 1 — Local Development Setup (WSL)

All configuration files were written and tested locally on WSL (Ubuntu on Windows) before being pushed to GitHub.

### Prerequisites
- WSL2 with Ubuntu installed
- Git configured (`git config --global user.name` and `user.email`)
- Azure CLI installed (`az --version`)
- Docker Desktop (optional for local testing)

### Step 1 — Clone the Upstream Source

The EpicBook application source was cloned from the original repo and integrated into this monorepo:

```bash
# Clone upstream source
git clone https://github.com/pravinmishraaws/theepicbook.git /tmp/epicbook-source

# Copy into assignment folder
cp -r /tmp/epicbook-source/* ~/devops-assignments/assignment-44/app/
```

### Step 2 — Modify app/config/config.json

Update the database host to use the Docker Compose service name `db` instead of `localhost`:

```json
{
  "development": {
    "username": "root",
    "password": "EpicBook2026",
    "database": "bookstore",
    "host": "db",
    "dialect": "mysql",
    "logging": false
  }
}
```

### Step 3 — Create the Dockerfile (Multi-Stage)

Located at `app/Dockerfile`:

```dockerfile
# Stage 1 — Install dependencies
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2 — Runtime image
FROM node:18-alpine
WORKDIR /app
RUN addgroup -S epicbook && adduser -S epicbook -G epicbook
COPY --from=builder /app/node_modules ./node_modules
COPY . .
RUN chown -R epicbook:epicbook /app
USER epicbook
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:8080/ || exit 1
CMD ["node", "server.js"]
```

**Result:** ~2GB → 94MB (95.6% size reduction)

### Step 4 — Create nginx/nginx.conf

```nginx
upstream epicbook_app {
    server app:8080;
}

server {
    listen 80;

    location / {
        proxy_pass http://epicbook_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /health {
        return 200 'healthy';
        add_header Content-Type text/plain;
    }

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
}
```

### Step 5 — Create docker-compose.yml

The Compose file defines all 3 services, 2 networks, and 2 volumes with healthcheck-based dependency ordering:

```yaml
services:
  db:
    image: mysql:8.0
    container_name: epicbook-db
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
    volumes:
      - db_data:/var/lib/mysql
      - ./app/db:/docker-entrypoint-initdb.d
    networks:
      - backend-net
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

  app:
    build: ./app
    container_name: epicbook-app
    environment:
      NODE_ENV: ${NODE_ENV}
      PORT: ${PORT}
      DB_HOST: ${DB_HOST}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: ${DB_NAME}
    networks:
      - frontend-net
      - backend-net
    depends_on:
      db:
        condition: service_healthy

  nginx:
    image: nginx:alpine
    container_name: epicbook-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - nginx_logs:/var/log/nginx
    networks:
      - frontend-net
    depends_on:
      app:
        condition: service_healthy

networks:
  frontend-net:
  backend-net:

volumes:
  db_data:
  nginx_logs:
```

### Step 6 — Create .env.example (Safe to Commit)

```bash
NODE_ENV=development
PORT=8080
DB_HOST=db
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=bookstore
MYSQL_ROOT_PASSWORD=your_password_here
NGINX_PORT=80
```

### Step 7 — Create .gitignore

```
.env
*.log
node_modules/
```

### Step 8 — Push Everything to GitHub

```bash
cd ~/devops-assignments

git add assignment-44/
git commit -m "feat: Assignment 44 - EpicBook Capstone - Docker Compose stack with Nginx, Node.js, MySQL"
git push
```

> ⚠️ **Never push the `.env` file.** It contains real credentials and is excluded by `.gitignore`.

---

## Part 2 — Azure VM Provisioning

### Azure Details
| Field | Value |
|---|---|
| Subscription | 7ad60dd1-1f06-4b1f-a6b1-6a5a5a7bcc50 |
| Resource Group | rg_assignment_44 |
| VM Name | vm-epicbook |
| Region | southafricanorth |
| Size | Standard_B2s_v2 (2 vCPUs, 8 GiB RAM) |
| OS | Ubuntu 22.04 LTS |
| Public IP | 20.164.216.83 |
| Admin User | azureuser |

> **Note:** Azure CLI 2.85.0 has a JSON parsing bug. VM was provisioned using a Python REST API script (`create_vm.py`) instead of `az vm create`.

### NSG Rules
| Port | Rule Name | Priority | Status |
|---|---|---|---|
| 22 | allow-ssh | 110 | Open |
| 80 | allow-http | 100 | Open |
| 3306 | — | — | Closed (internal only) |
| 8080 | — | — | Closed (internal only) |

### Step 1 — Verify VM is Running

From local WSL:

```bash
az vm show \
  --resource-group rg_assignment_44 \
  --name vm-epicbook \
  --show-details \
  --query "{Name:name, State:powerState, IP:publicIps}" \
  --output table
```

Expected output:
```
Name          State       IP
----------    ----------  ---------------
vm-epicbook   VM running  20.164.216.83
```

---

## Part 3 — VM Deployment

### Step 2 — SSH Into the VM

```bash
ssh azureuser@20.164.216.83
```

Type `yes` when prompted about the host fingerprint. Your prompt will change to:
```
azureuser@vm-epicbook:~$
```

### Step 3 — Verify Docker is Ready

The VM was provisioned with a `cloud-init` script that installs Docker automatically. Wait 3-4 minutes after VM boot, then verify:

```bash
sudo grep -i docker /var/log/cloud-init-output.log | tail -5
docker --version
docker compose version
```

Expected:
```
Docker version 29.1.3, build 29.1.3-0ubuntu3~22.04.1
Docker Compose version 2.40.3+ds1-0ubuntu1~22.04.1
```

### Step 4 — Clone the Repository

```bash
git clone https://github.com/gregodprogrammer/devops-assignments.git
cd devops-assignments/assignment-44
```

### Step 5 — Create the .env File

The `.env` file is NOT in Git and must be created manually on each deployment target:

```bash
cat > .env <<'EOF'
NODE_ENV=development
PORT=8080
DB_HOST=db
DB_USER=root
DB_PASSWORD=EpicBook2026
DB_NAME=bookstore
MYSQL_ROOT_PASSWORD=EpicBook2026
NGINX_PORT=80
EOF
```

Verify:
```bash
cat .env
```

### Step 6 — Build and Deploy the Stack

```bash
docker compose up -d --build
```

This will:
1. Build the Node.js app image (multi-stage, ~94MB)
2. Pull `mysql:8.0` and `nginx:alpine`
3. Create networks: `assignment-44_frontend-net`, `assignment-44_backend-net`
4. Create volumes: `assignment-44_db_data`, `assignment-44_nginx_logs`
5. Start `epicbook-db` first (waits for healthcheck)
6. Start `epicbook-app` once DB is healthy
7. Start `epicbook-nginx` once app is healthy

> ⚠️ **Known issue:** On first deploy, `epicbook-app` may initially show as unhealthy. This is a startup race condition — Node.js tries to connect to MySQL before it finishes seeding. The app auto-recovers after a few restart cycles. See Troubleshooting below.

### Step 7 — Start Nginx (if needed after initial deploy)

If nginx did not start because the app was initially unhealthy:

```bash
docker compose up -d nginx
```

### Step 8 — Verify All Containers Are Healthy

```bash
docker compose ps
```

Expected output:
```
NAME             IMAGE                COMMAND                  SERVICE   STATUS              PORTS
epicbook-app     assignment-44-app    "docker-entrypoint.s…"   app       Up (healthy)        8080/tcp
epicbook-db      mysql:8.0            "docker-entrypoint.s…"   db        Up (healthy)        3306/tcp, 33060/tcp
epicbook-nginx   nginx:alpine         "/docker-entrypoint.…"   nginx     Up                  0.0.0.0:80->80/tcp
```

### Step 9 — Check App Logs

```bash
docker compose logs --tail=20 app
```

Look for:
```
epicbook-app  | App listening on PORT 8080
```

### Step 10 — Test in Browser

Open in any browser:
```
http://20.164.216.83
```

You should see the EpicBook homepage with books loaded from the MySQL database. Test the full flow:
- Browse the Gallery
- Add books to cart
- Click Checkout → "Your order is placed!" confirmation

---

## Part 4 — Persistence Test

Verify that data survives a full container restart (named volume `db_data` persists MySQL data):

```bash
# Bring the entire stack down
docker compose down

# Bring it back up
docker compose up -d

# Check all containers are healthy
docker compose ps
```

Refresh the browser — all books and data are still present. The second startup is noticeably faster because MySQL skips re-seeding (volume already has data).

---

## Troubleshooting

### epicbook-app shows as unhealthy on first deploy

**Cause:** Node.js attempts to connect to MySQL immediately on startup. MySQL may still be initializing even after reporting healthy, causing `ECONNREFUSED`.

**Fix:** Wait ~30 seconds and check again. The app auto-restarts and connects once MySQL is fully ready. Then bring nginx up manually:
```bash
docker compose up -d nginx
```

**Long-term fix:** Add retry logic to `server.js`, or increase `start_period` in the app healthcheck.

### "version is obsolete" warning in docker-compose.yml

**Cause:** Docker Compose v2 deprecated the top-level `version:` key.

**Fix:** Remove the `version:` line from `docker-compose.yml`. It is safe to ignore for now.

### SSH connection refused

**Cause:** VM may still be booting, or NSG port 22 rule was not applied.

**Fix:** Wait 2-3 minutes after VM creation. Verify NSG rules with:
```bash
az network nsg rule list --resource-group rg_assignment_44 --nsg-name vm-epicbook-nsg --output table
```

---

## Screenshots

All deployment screenshots are in the `screenshots/` folder:

| File | Content |
|---|---|
| SS1.png | Azure Portal — VM overview (name, region, size, IP, status) |
| SS2.png | `docker compose ps` — all 3 containers healthy |
| SS3.png | `docker compose logs app` — App listening on PORT 8080 |
| SS4.png | Browser — EpicBook homepage loaded |
| SS5.png | Browser — Cart with books + "Your order is placed!" |
| SS6.png | `docker inspect` — healthcheck status |
| SS7.png | Persistence test — down → up → all healthy in 12 seconds |

---

## Cleanup

After assignment is graded, delete the resource group to stop Azure charges:

```bash
az group delete --name rg_assignment_44 --yes --no-wait
```

This deletes the VM, VNet, NSG, public IP, OS disk, and all associated resources.

---

## Key Lessons Learned

1. **Azure CLI 2.85.0 has a JSON bug** — use Python REST API for VM provisioning
2. **southafricanorth** was chosen because canadacentral vCPU quota was exhausted
3. **Multi-stage builds** reduce image size dramatically — 2GB → 94MB
4. **cloud-init** handles Docker installation automatically — no manual setup needed
5. **Healthcheck race conditions** are normal — understand them, don't just add `restart: always`
6. **Never use `!` in passwords** in bash — variable expansion silently breaks things
7. **Never commit `.env`** — always create it manually on each target machine
8. **Remove the `version:` key** from docker-compose.yml — deprecated in Compose v2

---

## Repository

**GitHub:** https://github.com/gregodprogrammer/devops-assignments

**Assignment folder:** `assignment-44/`

---

*Greg Odi | DevOps Micro-Internship (DMI) Cohort-2 by Pravin Mishra | April 2026*
