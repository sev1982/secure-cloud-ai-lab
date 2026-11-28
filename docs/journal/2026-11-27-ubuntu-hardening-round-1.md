# Journal entry: 2026-11-27 - Ubuntu hardening, round 1 (Lynis 65 to 82)

## What I did

Continued hardening the local Ubuntu 24.04 LTS VM, using the Lynis suggestions as a to-do list and sorting each one: fix now, delegate to Wazuh, or accept and document.

Fixed:
- Blocked unused kernel modules (dccp, sctp, rds, tipc, usb-storage) with `install <module> /bin/true` in `/etc/modprobe.d`.
- Kernel and network settings in `/etc/sysctl.d/99-seclab.conf` (kptr_restrict, sysrq, suid_dumpable, protected_fifos, log_martians, send_redirects, bpf_jit_harden and others).
- Default umask 027 in `/etc/login.defs`, core dumps disabled through `/etc/security/limits.d`.
- Legal banner in `/etc/issue` and `/etc/issue.net`, shown by SSH before authentication.
- SSH: AllowTcpForwarding no, AllowAgentForwarding no, LogLevel VERBOSE, MaxSessions 2, TCPKeepAlive no (added to `00-hardening.conf`).
- Package integrity: debsums installed with a weekly cron check, apt updates applied.
- Permissions: crontab and sshd_config to 600, cron directories to 700, `/etc/sudoers.d` to 750.
- NTP polling capped at 1024 s (17 min) with a drop-in file.

## Why (the security reasoning)

- Fewer loadable protocols and device drivers means less kernel attack surface.
- VERBOSE SSH logging records the key fingerprint used for each login, useful for audit and for Wazuh.
- Disabling TCP and agent forwarding stops the server from being used as a pivot after a compromise.
- Trusted timestamps are required to rebuild the order of events during an incident.
- Known unpatched components are a major cause of compromise (Log4Shell, Capital One), so the only Lynis warning (vulnerable packages) was handled first.

## Results

| Scan | Hardening index | Notes |
|---|---|---|
| Baseline (24.04 LTS, SSH not running) | 65 | 266 tests |
| After SSH hardening | 70 | 274 tests |
| After round 1 fixes | 75 | 22 suggestions, 1 warning (vulnerable packages) |
| After permissions, updates, debsums | 82 | 19 suggestions, 1 warning (time sync) |

Caveat: the baseline was measured with SSH stopped, so it is not a strict like-for-like comparison. A fair comparison will be made later from a clone of the baseline snapshot with SSH running.

Remaining 19 suggestions are all in the register's residual risk table (accepted with reasons) or delegated to Wazuh.

## What went wrong and how I fixed it

1. A first Lynis run without sudo skipped 20 tests (including auditd, firewall and sudo checks) and gave misleading results. Fix: always run `sudo ./lynis audit system` and check that the "skipped tests" section is absent. Invalid report files were deleted.
2. `ulimit -c` was first tested on the Kali VM instead of Ubuntu. A test is only valid on the machine that holds the setting. Check the prompt before trusting a result.
3. The tighter umask (027) changed the permissions of every new file and directory I created. The NTP drop-in file was created as 640 and its directory as 750, so the time service, which runs as a non-root user, could not read it and silently ignored it. Fix: chmod 644 on the file and 755 on the directory. Lesson: after tightening umask, check permissions of configuration files and directories read by non-root services. Running the diagnostic command without sudo also hid the file, which delayed finding the cause.
4. The Lynis time-sync warning appeared because the laptop went to sleep during the scan. The clock itself was correct (offset under 1 ms). Prevent host sleep during long VM tasks.
5. Correction on an earlier explanation: kernel.unprivileged_bpf_disabled = 2 already disables unprivileged BPF but root can re-enable it at runtime; value 1 locks it until reboot. So 1 is the stricter setting, not 2.

## What I learned

- Some tools read the first value found (sshd), others the last (sysctl). Always check which.
- A configuration being present does not mean it is applied: verify the effective value (`sshd -T`, `sysctl`, `timedatectl timesync-status`).
- A security index is an indicator, not a goal. Sort every suggestion by real risk, and document what is accepted.
- Side effects of a hardening change can break unrelated services. Test after each change, one at a time.

## How I would explain this in an interview

"I used a Lynis baseline to drive hardening, and for each finding I decided to fix, delegate to monitoring, or accept with a written justification. I verified each control by testing the effective behaviour, and I documented a side effect I caused myself: a stricter umask silently broke a service configuration, which I traced to file and directory permissions."
