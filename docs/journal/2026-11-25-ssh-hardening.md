# Journal entry: 2026-11-25 - SSH key-only access and restricted firewall

## What I did

Set up SSH key authentication from the Kali VM (user redops) to the Ubuntu VM (user labops), then disabled password logins, then restricted the host firewall so SSH is only reachable from the lab network. Applied pending security updates and took a VM snapshot.

## Why (the security reasoning)

- Password guessing and credential stuffing against exposed SSH is one of the most common attacks (lesson 2 of the register, Collins Aerospace weak credentials). With key-only login, the attacker needs the private key and its passphrase.
- Hardening file loaded first: sshd uses the first value it reads, so `/etc/ssh/sshd_config.d/00-hardening.conf` takes priority over system files such as cloud-init ones that may re-enable passwords.
- Settings: PasswordAuthentication no, KbdInteractiveAuthentication no, PermitRootLogin no, AllowUsers labops, MaxAuthTries 3, LoginGraceTime 30, X11Forwarding no, ClientAlive timeouts.
- Least exposure: ufw rule for port 22 limited to 10.20.0.0/24 instead of Anywhere, and the unused IPv6 rule removed.
- Known unpatched vulnerabilities are a major cause of compromise (Log4Shell, Capital One), so updates were applied before the snapshot.

## Results

- `sshd -t` returned no error before reloading the service.
- Test A (normal login with key and passphrase): success.
- Test B (`ssh -o PubkeyAuthentication=no`): `Permission denied (publickey)`, no password prompt. Passwords are really refused.
- `ufw status numbered` ends with one rule: 22/tcp ALLOW IN 10.20.0.0/24.

## What went wrong and how I fixed it

1. The first key login fell back to the password after three passphrase failures, so it looked like success when it was not. Fix: test with `-o PreferredAuthentications=publickey` to force the key method, and only then disable passwords.
2. Deleting ufw rules by number: numbers are positions and are recalculated after every deletion. After deleting rule 1, `delete 3` failed with "Could not find rule". Fix: reread `ufw status numbered` between deletions, or delete from the highest number to the lowest.
3. Always add the restrictive rule and test it before deleting the broad one, and keep one session open while changing SSH or firewall settings.

## What I learned

- A test that passes for the wrong reason is dangerous: force the exact method you want to verify.
- Test the "refused" case too (test B), not only the "allowed" case.
- Do not forget IPv6 when restricting the firewall.
- Access recovery matters: keep a second session open and a snapshot before risky changes.

## How I would explain this in an interview

"I replaced password SSH access with key-only authentication, validated the config with `sshd -t`, tested both the allowed and the refused path from a second session, and restricted the firewall to the management network. I kept a rollback path with an open session and a VM snapshot."

## Addendum: audit logging with auditd

- Installed `auditd` (active and enabled). By default it runs with no rules, so it records almost nothing useful.
- Rules in `/etc/audit/rules.d/seclab.rules`: watch writes and attribute changes on `/etc/passwd`, `/etc/shadow`, `/etc/group` (key `identity`), `/etc/sudoers` and `/etc/sudoers.d` (key `sudoers`), `/etc/ssh/sshd_config` and `sshd_config.d` (key `sshd_config`), and `/etc/audit` (key `audit_config`).
- Loaded with `augenrules --load`, checked with `auditctl -l` (8 rules).
- Test: `sudo touch /etc/ssh/sshd_config.d/00-hardening.conf`, then `ausearch -k sshd_config -i` shows the event with `auid=labops` and `uid=root`.

What I learned:
- `auid` is the identity from the original login and does not change after `sudo`, while `uid` is the current identity. This allows tracing who did what, even as root.
- The loading of the rules is itself logged (`op=add_rule`).
- A service that is running is not a service that is useful: auditd needed rules before it recorded anything meaningful.
- Next: rules may be locked with `-e 2` (needs a reboot to change), and the events will be collected by Wazuh.
