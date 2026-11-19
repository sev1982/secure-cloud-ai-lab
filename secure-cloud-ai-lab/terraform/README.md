# Terraform

- `modules/`: reusable building blocks (network, identity, compute, monitoring).
- `environments/dev/`: the dev environment that calls the modules.

Rules:
- Never commit `*.tfstate` or real `*.tfvars` files (see `.gitignore`).
- State is stored remotely in Azure Storage with locking.
- Run `terraform fmt` and `terraform validate` before every commit.
