# Local Kubernetes Terraform

This Terraform project manages a small piece of local Kubernetes infrastructure.

It currently creates two environment namespaces:

```text
platform-dev
platform-staging
```

It also applies:

- A `ResourceQuota` establishing namespace-wide resource boundaries.
- A `LimitRange` assigning default requests and limits to containers.

These resources are grouped in the reusable
`modules/platform-namespace` Terraform module. The root configuration calls
the module once per environment and passes different policy values to each
instance.

The root module contains `moved` blocks that preserve resources created before
the module refactor. Terraform updates their state addresses without replacing
the live Kubernetes objects.

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
kubectl get namespace platform-dev platform-staging
kubectl get resourcequota -n platform-dev
kubectl describe resourcequota platform-dev-quota -n platform-dev
kubectl get limitrange -n platform-dev
kubectl describe limitrange platform-dev-limits -n platform-dev
kubectl describe resourcequota platform-staging-quota -n platform-staging
kubectl describe limitrange platform-staging-limits -n platform-staging
```

Confirm that the live infrastructure still matches the configuration:

```bash
terraform plan
```

Destroy the namespace when practicing cleanup:

```bash
terraform destroy
```

## Terraform state

The root configuration explicitly uses Terraform's `local` backend. Its state
is stored in `terraform.tfstate` in this directory and must not be committed.

Useful read-only state commands:

```bash
terraform state list
terraform state show module.platform_namespace.kubernetes_namespace.this
terraform show
```

State maps Terraform resource addresses to real Kubernetes objects. Losing it
does not immediately delete infrastructure, but Terraform will no longer know
that it manages those objects. State may also contain sensitive values, even
when configuration files do not.

Local state is appropriate for this single-user learning environment. A shared
environment should use a remote backend that provides:

- Centralized, durable storage.
- Encryption and access control.
- State locking to prevent concurrent writes.
- Versioning or another recovery mechanism.

Backend settings cannot use normal Terraform input variables because Terraform
must initialize the backend before evaluating the rest of the configuration.
When a remote backend is introduced, initialize it with:

```bash
terraform init -migrate-state -backend-config=backend.tfbackend
```

Keep the real `backend.tfbackend` file out of Git if it contains credentials or
environment-specific settings. Always review and back up state before a backend
migration.

## Continuous integration

GitHub Actions checks the Terraform configuration on pushes and pull requests:

```bash
terraform fmt -check -recursive
terraform init -backend=false -input=false
terraform validate
```

CI disables backend initialization because validation needs provider schemas
and modules, not access to local state. It intentionally does not run
`terraform plan`: the hosted runner cannot access the local Docker Desktop
Kubernetes cluster or its kubeconfig. Plans and applies remain local until the
project has a remotely accessible cluster, protected credentials, and a shared
state backend.

## Files committed to Git

Commit the Terraform configuration and `.terraform.lock.hcl`. The lock file
records the selected provider versions and checksums.

Do not commit `.terraform/`, `terraform.tfstate`, state backups, or `.tfvars`
files. State can contain infrastructure details or sensitive values, while
`.tfvars` files commonly contain environment-specific configuration or
secrets.
