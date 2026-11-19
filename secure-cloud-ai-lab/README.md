# Secure Cloud AI Lab

A cloud-first security platform built on Azure with Terraform, monitored by Wazuh, and extended with AI-assisted threat detection. The goal is a reference architecture that is reproducible, documented, and designed to scale from a lab to a real organization.

## Goals

1. **Secure by design**: network segmentation, least privilege, strong identity, encryption.
2. **Everything as code**: the whole environment is deployed and destroyed with Terraform.
3. **Detect and respond**: centralized logging and alerting with Wazuh, mapped to MITRE ATT&CK.
4. **AI-assisted security**: anomaly detection and alert triage on top of the SIEM data.
5. **Prove it**: attack the platform, fix the findings, document everything, then open a controlled public challenge.

## Status

| Phase | Description | Status |
|---|---|---|
| 1 | Foundations (repo, Azure account, budget, tooling) | In progress |
| 2 | Network and identity in Terraform | Planned |
| 3 | Hardening and vulnerability scanning | Planned |
| 4 | Wazuh detection and dashboards | Planned |
| 5 | AI layer | Planned |
| 6 | Attack, remediation, public challenge | Planned |

## Repository layout

```
terraform/      Infrastructure as code (modules + environments)
wazuh/          Wazuh configuration, rules, decoders
ai/             Anomaly detection and alert triage
docs/           Architecture, decisions (ADRs), roadmap, learning journal
```

## Design principles (built to scale)

- Modular Terraform, one environment per folder (dev first, prod-ready later).
- Remote state with locking, no secrets in the repository.
- CI/CD with GitHub Actions using OIDC, no long-lived credentials.
- Policy as code and consistent tagging and naming.
- Every important choice is recorded as an Architecture Decision Record in `docs/decisions`.
- Aligned with CIS Benchmarks, NIST CSF and MITRE ATT&CK.

## Disclaimer

This is a learning and portfolio project. No system is unbreakable; the aim is to reduce risk, detect attacks and respond quickly. Nothing here contains real personal data.
