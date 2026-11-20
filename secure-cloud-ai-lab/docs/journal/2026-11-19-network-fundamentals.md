# Journal entry: 2026-11-19 - Network fundamentals and zone design

## What I did

Designed the first version of the Azure network (4 zones: DMZ, workloads, management, security) and documented it in `docs/architecture/network.md`. Learned the difference between public and private addressing before writing any Terraform.

## Key concepts (in my own words)

- **Public IP**: the address given by my ISP. It identifies my Internet connection (my router), and it is what Azure sees when I connect.
- **Private IP**: the address of a device inside a local network (my computer and every device connected at home). Private ranges are `10.x.x.x`, `172.16-31.x.x` and `192.168.x.x`. They are not routed on the Internet.
- **NAT (Network Address Translation)**: the process, done by the router, that translates private addresses into the public address when traffic leaves the network, and translates the replies back to the right device.
- **Bastion**: a server intentionally exposed to the Internet, hardened and monitored, that is the single entry point to administer private servers. The private servers are not directly reachable from the Internet.

## Why (the security reasoning)

- Segmentation limits lateral movement: a compromised DMZ must not give access to internal workloads.
- Only the DMZ is reachable from the Internet, on port 443 only.
- Every zone sends its logs to Wazuh, because what is not logged cannot be detected.
- Administration comes from a single trusted source. Azure Bastion is the professional option but costs too much for a lab, so the lab uses a restricted NSG rule plus SSH keys. This trade-off is recorded in `network.md`.

## What went wrong and how I fixed it

Initial wording of the bastion definition said it prevents private servers from communicating on the Internet. Corrected: a bastion controls how administrators reach private servers. Outbound access of private servers to the Internet is a separate topic (handled by NAT gateways or firewalls).

## What I learned

- My public IP is shared by every device at home and can change (dynamic IP), so it must live in a variable, never hard-coded and never committed.
- Azure private networks follow the same logic as my home network.

## How I would explain this in an interview

"I segmented the network into four zones with default-deny rules, exposed only the DMZ on port 443, centralized logs in Wazuh, and documented the trade-off of not using Azure Bastion in a lab environment."
