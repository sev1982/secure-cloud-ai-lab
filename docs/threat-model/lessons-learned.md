# Lessons learned register (threat-informed design)

This is a living document. Every design decision in this project should trace back to a real attack or a known weakness class. Before each phase we review this register; after each phase we update it.

Rules:
1. Each row names a real incident, the weakness it exposed, and the control we implement.
2. A row is only "Done" when there is evidence: a test, a scan result, or a detection alert.
3. Before the public challenge, every row must be Done or have an accepted, documented residual risk.

## Register

| # | Weakness class | Real incident | Control in this project | Phase | Status |
|---|---|---|---|---|---|
| 1 | Old or leaked credentials never rotated or revoked | Collins Aerospace, Sept 2025 (data theft with credentials from a 2022 infostealer infection) | Joiner/mover/leaver process, access reviews, short-lived credentials, secrets in Key Vault, secret scanning before every commit | 2, 3 | Planned |
| 2 | Weak, default or shared passwords | Collins Aerospace FTP server, Sept 2025 | No default accounts, password policy, MFA on every interactive login, SSH keys only | 2, 3 | Planned |
| 3 | Legacy or unnecessary service exposed to the Internet | Collins Aerospace FTP server | Only 443 exposed (DMZ), default-deny NSGs, regular exposure scans | 2 | In design |
| 4 | Single point of failure at a shared supplier, no tested fallback | Collins Aerospace MUSE ransomware, Sept 2025 (check-in down at several European airports) | Documented manual fallback, immutable backups, restore test, recovery time objective | 3, 6 | Planned |
| 5 | Compromised account with no MFA on a forgotten entry point | Colonial Pipeline, 2021 (legacy VPN account) | MFA everywhere, inventory and removal of unused accounts, alert on login by disabled or dormant accounts | 2, 4 | Planned |
| 6 | MFA fatigue (push bombing) | Uber, 2022 | Phishing-resistant MFA where possible, number matching, conditional access, alert on repeated MFA failures | 2, 4 | Planned |
| 7 | Cloud credentials stolen through a misconfigured web app | Capital One, 2019 | Managed identities, least-privilege roles, protected metadata service, WAF review | 2, 3 | Planned |
| 8 | Unpatched vulnerable component | Log4Shell, 2021 | Patch policy, dependency and image scanning, software bill of materials | 3 | Planned |
| 9 | Flat network and third-party access | Target, 2013 (stolen vendor credentials) | Segmentation (done in design), no standing vendor access, monitoring between zones | 2, 4 | In design |
| 10 | Attack goes undetected | All of the above | Wazuh agents everywhere, alerts mapped to MITRE ATT&CK, log retention | 4 | Planned |

Facts about incidents other than Collins Aerospace are recalled from public reporting and must be checked against primary sources (for example CISA advisories or the companies' own statements) when each row is worked on. Add the source link in the row when it is verified.

## Case study: Collins Aerospace, September 2025

Two separate events happened in the same week, and it is important not to mix them:

1. **Ransomware on MUSE.** On 19 September 2025, ransomware (HardBit reported) hit the MUSE passenger processing software, which airlines use for check-in, boarding and baggage. ENISA confirmed ransomware. Airports including Heathrow, Brussels and Berlin fell back to manual processes. The initial access method has not been publicly confirmed in detail.
2. **Data theft by another group.** The group Everest claims it accessed an FTP server of Collins Aerospace on 10 September using the credentials `aiscustomer` and `muse-insecure`. Security researchers traced those credentials to a 2022 infostealer infection on an employee device. They had never been rotated. This is an attacker and researcher account, not a confirmed forensic report from Collins.

What we take from it: a three-year-old stolen credential still worked, a legacy service was exposed, and the supplier concentration turned one incident into a continent-wide outage.

Sources:
- https://www.scworld.com/news/cybersecurity-incident-at-european-airports-caused-by-ransomware
- https://heise.de/-10900183
- https://www.infostealers.com/article/collins-aerospace-hit-twice-2022-infostealer-infection-enabled-a-separate-breach/
- https://assured.co.uk/2025/weekly-cyber-update-16-december-2025/

## Residual risk

No system is free of weaknesses. The goal is to remove the known, common weakness classes, detect what we miss, and document what remains. Residual risks are listed here with the reason they are accepted.

| Risk | Why accepted | Review date |
|---|---|---|
| (to be filled as we build) | | |
