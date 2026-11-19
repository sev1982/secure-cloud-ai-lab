# ADR 0001: Use Wazuh as the SIEM and XDR platform

Status: Accepted

## Context
The project needs centralized logging, intrusion detection, file integrity monitoring and alerting. Cost must stay predictable during the lab phase, and the solution should be realistic for real organizations.

## Decision
Use Wazuh, self-hosted on Azure and deployed with Terraform.

## Consequences
- No licensing cost, full control over rules and data.
- Widely used in SOC teams, so the skills transfer to real jobs.
- Starts as a single node; the architecture allows moving to a multi-node cluster as volume grows.
- We operate and patch it ourselves.
- Microsoft Sentinel can be added later for comparison or integration.
