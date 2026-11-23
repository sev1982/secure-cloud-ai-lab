# Journal entry: 2026-11-22 - Ubuntu VM, first Lynis baseline and first fixes

## What I did

Built a local Ubuntu Server VM in VirtualBox, ran a Lynis audit as a baseline, then applied and tested the first two controls (host firewall and password quality).

## Why (the security reasoning)

- A measured baseline lets me prove the improvement later (before/after score, and per-test comparison).
- Host firewall (default deny incoming) adds a second layer behind the Azure network rules.
- Password quality enforced by the system itself, not left to user goodwill (lesson 2 of the register).

## Results

- Baseline on Ubuntu 24.04 LTS: hardening index 65, 266 tests, no intrusion software, no malware scanner, firewall installed but inactive (warning FIRE-4512: iptables module loaded, no rules active).
- Fix 1: ufw enabled, default deny incoming, allow outgoing, SSH allowed. Verified with `ufw status verbose`.
- Fix 2: libpam-pwquality configured (minimum 14 characters, dictionary check, username check, repetition limit). Verified with `pwscore` (rejects a short password) and with the PAM configuration (`pam_pwquality.so` active).

## What went wrong and how I fixed it

1. The first VM was Ubuntu 26.10, an interim release supported for only 9 months. Spotted through the package source name in an install log. Rebuilt on 24.04 LTS. Lesson added to the register (row 11).
2. A first test showed a password change was accepted; checked safely with `pwscore` and the PAM line instead of repeating the test on the real account.
3. Typing errors (`shown` instead of `chown`, `common-passwoord`) caught from the error messages. Tab completion helps.
4. Lynis did not report any SSH suggestion. SSH on Ubuntu 24.04 starts on demand (socket activation), so the service was not running during the scan and its tests were skipped. To compare fairly, the baseline must be measured once with SSH running, from the snapshot.

## What I learned

- Verify a control by testing that it blocks what it should block, not only that it is configured.
- A baseline has to be complete and honest about its limits.
- Check the exact operating system version and its support date before building anything.

## How I would explain this in an interview

"I measured a baseline with Lynis, fixed the findings in order of risk, and verified each control with a test. I also caught that my first VM was on a short-support release and rebuilt it on an LTS version."
