# Terraform VM + Nginx Demo

This repository demonstrates provisioning an Azure Linux VM using Terraform, then configuring it to serve a custom `index.html` page via **Nginx**.

## 📁 Repository Contents

- `main.tf` - Terraform configuration that creates:
  - Resource Group
  - Virtual Network + Subnet
  - Network Security Group (SSH + HTTP allowed)
  - Public IP + Network Interface
  - Ubuntu Linux VM
  - Output containing an SSH connection string

- `index.html` - A simple Nginx landing page that can be copied onto the VM (e.g., `/var/www/html/index.html`).

## ✅ Prerequisites

- [Terraform](https://www.terraform.io/downloads) installed and on your PATH.
- An Azure subscription and valid credentials configured (e.g., via `az login`).
- SSH client (included on macOS/Linux; Windows can use PowerShell SSH or WSL).

### Notes

- This is a demo configuration. For production usage, **do not** hardcode passwords. Use SSH keys, Azure Key Vault, or managed identities.
- Terraform provider versions change over time. Check the [AzureRM provider registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest) for the latest version and update `main.tf` accordingly.
- Adjust the VM size, region, and network CIDR ranges as needed.


## 🚀 Deploying the VM with Terraform

1. Open a terminal in this repo directory.

2. Initialize Terraform:

```bash
terraform init
```

3. Preview the planned changes:

```bash
terraform plan
```

4. Create the infrastructure:

```bash
terraform apply -auto-approve
```

After creation, Terraform will output an `ssh_command` value.

## 🔐 SSH into the VM

Copy the output from Terraform (it looks like `ssh azureuser@<public-ip>`), then run it:

```bash
ssh azureuser@<public-ip>
```

> **Note:** This config uses a password (`Password@123`) for the `azureuser` account (as defined in `main.tf`). If desired, update the Terraform configuration to use SSH keys instead.

## 🛠️ Installing Nginx & Deploying `index.html`

Once logged in via SSH, run:

```bash
sudo apt update
sudo apt install -y nginx
```

Replace the default Nginx landing page:

```bash
sudo cd /var/www/html/
sudo rm index.html
sudo nano index.html //paste the content here or you can also customize it by your way 
cat index.html
EOF
```

Then restart Nginx:

```bash
sudo systemctl restart nginx
```

## 🌐 Verify

Open a browser and navigate to:

```
http://<public-ip>
```

You should see the animated landing page defined in `index.html`.

## 🧹 Cleanup

When you’re done, destroy the resources to avoid charges:

```bash
terraform destroy -auto-approve
```

---

Author: Siddhesh Khanorkar
Created: March 2026
Status: Completed