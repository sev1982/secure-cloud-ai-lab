# ADR 0002: Cloud-first on Azure, everything in Terraform

Status: Accepted

## Context
The local machine has limited free disk space, and the target roles involve cloud security. Infrastructure must be reproducible and reviewable.

## Decision
Host the platform in Azure and define all resources with Terraform. Use local virtual machines only for lightweight tools (for example an attacker machine).

## Consequences
- Environment can be destroyed and rebuilt in minutes, which also controls cost.
- Changes are versioned and reviewable in Git.
- Requires cost monitoring and strict handling of credentials.
