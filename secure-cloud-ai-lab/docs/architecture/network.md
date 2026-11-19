# Network architecture (v1)

Region: Canada Central
Virtual network: 10.10.0.0/16

## Subnets

| Subnet | CIDR | Purpose |
|---|---|---|
| snet-mgmt | 10.10.1.0/24 | Administration only |
| snet-security | 10.10.2.0/24 | Wazuh server (manager, indexer, dashboard) |
| snet-workloads | 10.10.3.0/24 | Internal servers (Linux, Windows) |
| snet-dmz | 10.10.4.0/24 | Public web app used for the future security challenge |

## Design principles

1. Default deny: every NSG ends with an explicit deny rule.
2. Least exposure: only the DMZ is reachable from the Internet, on port 443 only.
3. Segmentation: DMZ and workloads cannot talk to each other (limits lateral movement).
4. Central visibility: every zone sends logs to Wazuh.
5. Administration only from a trusted source (my public IP), with SSH key authentication.

## Allowed flows

| From | To | Port | Reason |
|---|---|---|---|
| Internet | DMZ | 443/TCP | Public web app |
| DMZ, Workloads, Management | Security | 1514/TCP | Wazuh agent events |
| DMZ, Workloads, Management | Security | 1515/TCP | Wazuh agent enrollment |
| Management | Security | 443/TCP | Wazuh dashboard |
| Management | All zones | 22/TCP, 3389/TCP | Administration |
| Admin public IP | Management | 22/TCP | Entry point (Bastion in production) |
| Everything else | Everything else | any | Denied |

## Decisions and trade-offs

- Azure Bastion is the production answer for admin access but is costly for a lab. For now, NSG restricted to one IP plus key authentication. Revisit when scaling.
- Address space is large (/16) on purpose so new subnets (for example a second environment or a database tier) can be added without redesign.

## Evolution path

- Add a hub-and-spoke topology when a second environment (prod) appears.
- Add Azure Firewall or a WAF in front of the DMZ.
- Move Wazuh to a multi-node cluster as log volume grows.
