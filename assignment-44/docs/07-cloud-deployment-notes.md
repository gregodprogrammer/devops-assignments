# Cloud Deployment Notes

## VM Details
- Provider: Microsoft Azure
- Region: South Africa North (southafricanorth)
- VM Size: Standard_B2s_v2 (2 vCPU, 4GB RAM)
- OS: Ubuntu 22.04 LTS
- Resource Group: rg_assignment_44

## NSG Rules (Inbound)
| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 80 | TCP | Any | HTTP web traffic |
| 22 | TCP | My IP only | SSH management |

## Ports NOT Exposed
- 3306 (MySQL) — internal only
- 8080 (App) — internal only

## Deployment Steps
1. Provision VM with Docker via cloud-init
2. SSH into VM
3. Clone devops-assignments repo
4. cd assignment-44
5. Copy .env file (not in Git)
6. docker compose up -d --build
7. Verify at http://<VM_PUBLIC_IP>

## Public URL
http://<VM_PUBLIC_IP>/
