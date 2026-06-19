# Local Kubernetes Terraform

This Terraform project manages a small piece of local Kubernetes infrastructure.

It currently creates one namespace:

```text
platform-dev
```

## Commands

Initialize Terraform and download the Kubernetes provider:

```bash
terraform init
```

Preview the change:

```bash
terraform plan
```

Apply the change:

```bash
terraform apply
```

Verify with Kubernetes:

```bash
kubectl get namespace platform-dev
```

Confirm that the live infrastructure still matches the configuration:

```bash
terraform plan
```

Destroy the namespace when practicing cleanup:

```bash
terraform destroy
```

## Files committed to Git

Commit the Terraform configuration and `.terraform.lock.hcl`. The lock file
records the selected provider versions and checksums.

Do not commit `.terraform/`, `terraform.tfstate`, state backups, or `.tfvars`
files. State can contain infrastructure details or sensitive values, while
`.tfvars` files commonly contain environment-specific configuration or
secrets.
