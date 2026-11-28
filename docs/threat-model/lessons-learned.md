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
| 2 | Weak, default or shared passwords | Collins Aerospace FTP server, Sept 2025 | No default accounts, password policy, MFA on every interactive login, SSH keys only | 2, 3 | Done for SSH on the Ubuntu VM (2026-11-25): password policy verified (pwscore, PAM), SSH key-only login (ed25519 + passphrase), PasswordAuthentication off, root login off, AllowUsers, ufw SSH restricted to the lab network. Pending: MFA is not applicable in the local lab, to address in the cloud (Azure Entra ID MFA) |
| 3 | Legacy or unnecessary service exposed to the Internet | Collins Aerospace FTP server | Only 443 exposed (DMZ), default-deny NSGs, regular exposure scans | 2 | In design |
| 4 | Single point of failure at a shared supplier, no tested fallback | Collins Aerospace MUSE ransomware, Sept 2025 (check-in down at several European airports) | Documented manual fallback, immutable backups, restore test, recovery time objective | 3, 6 | Planned |
| 5 | Compromised account with no MFA on a forgotten entry point | Colonial Pipeline, 2021 (legacy VPN account) | MFA everywhere, inventory and removal of unused accounts, alert on login by disabled or dormant accounts | 2, 4 | Planned |
| 6 | MFA fatigue (push bombing) | Uber, 2022 | Phishing-resistant MFA where possible, number matching, conditional access, alert on repeated MFA failures | 2, 4 | Planned |
| 7 | Cloud credentials stolen through a misconfigured web app | Capital One, 2019 | Managed identities, least-privilege roles, protected metadata service, WAF review | 2, 3 | Planned |
| 8 | Unpatched vulnerable component | Log4Shell, 2021 | Patch policy, dependency and image scanning, software bill of materials | 3 | In progress (2026-11-27): Ubuntu VM fully patched with apt (Lynis: no vulnerable or upgradeable packages), unattended-upgrades present, weekly debsums integrity check enabled. Dependency and image scanning, SBOM and patch deadlines still planned |
| 9 | Flat network and third-party access | Target, 2013 (stolen vendor credentials) | Segmentation (done in design), no standing vendor access, monitoring between zones | 2, 4 | In design |
| 10 | Attack goes undetected | All of the above | Wazuh agents everywhere, alerts mapped to MITRE ATT&CK, log retention | 4 | In progress (2026-11-27): auditd active with rules on identity files, sudoers, sshd config and audit config (events keep the original login identity, auid); SSH logging at VERBOSE; NTP polling capped at 17 min for reliable timestamps. Wazuh agent, remote log collection and alerts still planned |
| 11 | End-of-life or short-support operating systems | General pattern: systems past their support date keep known flaws that are never patched | LTS releases only, check the support end date before building, keep an inventory with end-of-life dates | 3 | Done for the Ubuntu VM: rebuilt on 24.04 LTS on 2026-11-22 after spotting a 9-month interim release |

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
| No GRUB password (BOOT-5122) | Local VM lab: console access is outside the lab's threat model. A boot-parameter edit bypassed login during a lockout recovery on the Kali VM, so in the cloud console and serial access must be controlled through IAM | Before cloud deployment |
| No separate /home, /tmp, /var partitions (FILE-6310) | Only limits the impact of a full filesystem; the lab disk is small and disposable | When a production profile is defined |
| No forced password expiry (AUTH-9282, AUTH-9286) | NIST SP 800-63B advises against periodic forced rotation of user passwords; passwords are rotated on compromise. Service accounts and secrets get rotation in the cloud phase | Cloud phase |
| SSH stays on port 22 (SSH-7408) | Changing the port is obscurity, not a control. Real controls: key-only login, AllowUsers, firewall limited to the lab network | Before public challenge |
| Three sysctl values differ from the Lynis profile (KRNL-6000) | kernel.modules_disabled left at 0 (setting 1 blocks module loading until reboot and would hinder a changing lab). kernel.unprivileged_bpf_disabled is 2: unprivileged BPF is already disabled, but root can re-enable it at runtime, while 1 locks it until reboot. net.ipv4.conf.all.rp_filter left in loose mode (Ubuntu default), because strict mode can break asymmetric routing in cloud networks | Before cloud deployment |
| No process accounting or sysstat (ACCT-9622, ACCT-9626) | auditd already records the security events chosen; sysstat is performance data, not security data | Not planned |
| No malware scanner, file integrity tool or external log host (HRDN-7230, FINT-4350, LOGG-2154) | Planned through the Wazuh agent (rootcheck, syscheck, central log collection) | At Wazuh deployment |
| Clock can drift when a VM is paused or the host sleeps (TIME-3185 raised once) | Virtualization limit. NTP polling capped at 17 min; Wazuh can alert on agent time skew | At Wazuh deployment |
| Low-value Lynis suggestions: systemd service exposure scores (BOOT-5264), password hashing rounds (AUTH-9230), DNS domain name (NAME-4028), unused iptables rules created by ufw (FIRE-4513), automation tools (TOOL-5002) | Little security value in the local lab; ufw manages its own iptables chains; automation arrives with Terraform | Before cloud deployment |
