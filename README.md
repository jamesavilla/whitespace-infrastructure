# Whitespace Infrastructure with Terraform

This repository contains the Terraform configuration for provisioning all Whitespace infrastructure. It supports multiple environments using Terraform workspaces and leverages Terraform Cloud to securely manage secrets (instead of keeping them in a local `terraform.tfvars` file).

> **Important:**
> - Do not commit your local `terraform.tfvars` file if it contains sensitive data.
> - Follow the instructions below to move your secrets to Terraform Cloud.

---

## Prerequisites

- [Terraform](https://www.terraform.io/) v1.0+ installed.
- AWS credentials configured (via environment variables, AWS CLI, or IAM roles).

---

### For Development (default)
To select the default workspace, run the following command:
```bash
terraform workspace select default
```

---

### For Production
To select the production workspace, run the following command:
```bash
terraform workspace select production
```

---

### Plan
To run the plan before applying, run the following command:
```bash
terraform plan
```

---

### Apply
To apply the changes, run the following command:
```bash
terraform apply
```