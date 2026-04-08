# 🚀 Deploy a React App on Azure with Terraform

![Terraform](https://img.shields.io/badge/Terraform-v1.5+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-Web_Server-009639?style=for-the-badge&logo=nginx&logoColor=white)
![React](https://img.shields.io/badge/React-18-61DAFB?style=for-the-badge&logo=react&logoColor=black)
![Node.js](https://img.shields.io/badge/Node.js-v18.20.8-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)

> A complete Infrastructure as Code (IaC) project that provisions Azure cloud infrastructure using Terraform and deploys a React application on an Ubuntu 20.04 VM served by Nginx.

📖 **Read the full step-by-step Medium article:** [Deploy a React App on Azure with Terraform](https://medium.com/@greg.ethel)

---

## 📸 Screenshots

| Terraform Apply | React App Live | Azure Portal |
|---|---|---|
| ![Terraform Apply](screenshots/04-terraform-apply.png) | ![React App](screenshots/11-browser-app.png) | ![Azure Portal](screenshots/13-azure-portal-vm.png) |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│              Azure - Canada Central                  │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │         Resource Group: react-app-rg          │   │
│  │                                               │   │
│  │  ┌─────────────────────────────────────────┐ │   │
│  │  │     Virtual Network: 10.0.0.0/16         │ │   │
│  │  │                                          │ │   │
│  │  │  ┌──────────────────────────────────┐   │ │   │
│  │  │  │    Subnet: 10.0.1.0/24           │   │ │   │
│  │  │  │                                  │   │ │   │
│  │  │  │  ┌──────────────────────────┐   │   │ │   │
│  │  │  │  │  VM: react-app-vm        │   │   │ │   │
│  │  │  │  │  Ubuntu 20.04 LTS        │   │   │ │   │
│  │  │  │  │  Standard_B2ats_v2       │   │   │ │   │
│  │  │  │  │  Node.js v18 + Nginx     │   │   │ │   │
│  │  │  │  └──────────────────────────┘   │   │ │   │
│  │  │  └──────────────────────────────────┘   │ │   │
│  │  └─────────────────────────────────────────┘ │   │
│  │                                               │   │
│  │  NSG: Allows Port 22 (SSH) + Port 80 (HTTP)  │   │
│  │  Public IP: 20.151.129.189 (Static)          │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## 📋 Resources Provisioned by Terraform

| # | Resource | Name | Purpose |
|---|---|---|---|
| 1 | Resource Group | react-app-rg | Container for all resources |
| 2 | Virtual Network | react-app-vnet | Isolated cloud network |
| 3 | Subnet | react-app-subnet | VM network segment |
| 4 | Network Security Group | react-app-nsg | Firewall (ports 22 + 80) |
| 5 | Public IP Address | react-app-public-ip | Static external IP |
| 6 | Network Interface | react-app-nic | VM network connection |
| 7 | NIC-NSG Association | nic_nsg | Links firewall to NIC |
| 8 | Linux Virtual Machine | react-app-vm | Ubuntu server |

---

## ⚙️ Tech Stack

| Tool | Version | Purpose |
|---|---|---|
| Terraform | >= 1.5 | Infrastructure provisioning |
| Azure Provider (azurerm) | 3.117.1 | Azure resource management |
| Ubuntu | 20.04 LTS | VM operating system |
| Node.js | v18.20.8 | JavaScript runtime |
| npm | v10.8.2 | Package manager |
| Nginx | Latest | Web server / reverse proxy |
| React | 18 | Frontend framework |
| Git | Latest | Source control |

---

## 🚦 Prerequisites

Before you begin, make sure you have:

- [ ] [Terraform >= 1.5](https://developer.hashicorp.com/terraform/downloads) installed
- [ ] [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in
- [ ] An active Azure subscription
- [ ] Git installed
- [ ] SSH client available

---

## 🏃 Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/gregodprogrammer/terraform-react-azure.git
cd terraform-react-azure
```

### 2. Login to Azure

```bash
az login
az account show  # Verify correct subscription
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Preview infrastructure

```bash
terraform validate
terraform plan
```

### 5. Deploy infrastructure

```bash
terraform apply
# Type 'yes' when prompted
# Note the public_ip_address in the output
```

### 6. SSH into the VM

```bash
ssh -o PreferredAuthentications=password azureuser@<PUBLIC_IP>
# Password: P@ssw0rd1234!
```

### 7. Set up the server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Git and Nginx
sudo apt install -y git nginx
sudo systemctl start nginx && sudo systemctl enable nginx
```

### 8. Deploy the React app

```bash
cd ~
git clone https://github.com/pravinmishraaws/my-react-app.git
cd my-react-app
npm install
npm run build

# Copy to Nginx web root
sudo cp -r ~/my-react-app/build/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

### 9. Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/default
```

Replace the file content with:

```nginx
server {
    listen 80;
    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
```

### 10. Verify

Open your browser and visit: `http://<PUBLIC_IP>`

---

## 🔑 Important Notes

> **Security:** The password authentication used here is for lab/assignment purposes only. In production, always use SSH key authentication.

> **Cost:** Remember to run `terraform destroy` after the assignment to avoid Azure charges.

```bash
# Clean up all resources
terraform destroy
# Type 'yes' when prompted
```

---

## 🗂️ Project Structure

```
terraform-react-azure/
├── main.tf                 # Complete Terraform configuration
├── .terraform/             # Provider plugins (auto-generated)
├── .terraform.lock.hcl     # Provider version lock file
├── terraform.tfstate       # Infrastructure state (do not edit)
├── screenshots/            # Deployment screenshots
│   ├── 01-azure-cli-login.png
│   ├── 02-terraform-init.png
│   ├── 03-terraform-plan.png
│   ├── 04-terraform-apply.png
│   ├── 05-ssh-connection.png
│   ├── 06-node-npm-versions.png
│   ├── 07-nginx-running.png
│   ├── 08-git-clone.png
│   ├── 09-npm-build.png
│   ├── 10-nginx-test.png
│   ├── 11-browser-app.png
│   ├── 12-browser-nav.png
│   └── 13-azure-portal-vm.png
└── README.md               # This file
```

---

## 📝 .gitignore

> Make sure your `.gitignore` contains the following to avoid committing sensitive state files:

```gitignore
# Terraform state (contains sensitive data)
terraform.tfstate
terraform.tfstate.backup
.terraform/

# Environment files
*.env
.env
```

---

## 👤 Author

**Greg Odi**
- Medium: [@greg.ethel](https://medium.com/@greg.ethel)
- GitHub: [@gregodprogrammer](https://github.com/gregodprogrammer)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

*This project is part of the FREE DevOps for Beginners Cohort by Pravin Mishra.*
