# Roadmap

## Phase 1: Foundations
- [ ] GitHub repository created
- [ ] Azure subscription dedicated to the project, MFA enabled
- [ ] Budget alert configured
- [ ] Tools installed: Git, VS Code, Azure CLI, Terraform
- [ ] Remote Terraform state (Azure Storage) created

## Phase 2: Network and identity
- [ ] Virtual network with segmented subnets
- [ ] Network security groups (deny by default)
- [ ] Key Vault for secrets
- [ ] Least privilege roles, MFA and conditional access

## Phase 3: Hardening
- [ ] Baseline vulnerability scan
- [ ] CIS hardening on Linux and Windows
- [ ] Second scan and before/after comparison

## Phase 4: Detection
- [ ] Wazuh server deployed with Terraform
- [ ] Agents on all machines
- [ ] Custom rules mapped to MITRE ATT&CK
- [ ] Dashboards and alerting

## Phase 5: AI layer
- [ ] Export alerts and logs as a dataset
- [ ] Anomaly detection model
- [ ] LLM-assisted alert triage

## Phase 6: Prove it
- [ ] Internal attack simulations and incident reports
- [ ] Remediation and retest
- [ ] SECURITY.md completed
- [ ] Controlled public challenge
