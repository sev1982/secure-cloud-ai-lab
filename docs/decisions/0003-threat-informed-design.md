# ADR 0003: Threat-informed design with a lessons learned register

Status: Accepted

## Context
The platform will eventually be opened to security researchers who will try to breach it. Real attackers mostly reuse known techniques: stolen or weak credentials, exposed legacy services, unpatched software and missing detection.

## Decision
Maintain `docs/threat-model/lessons-learned.md`. Each phase starts by reviewing it and ends by updating it. Controls are linked to real incidents and mapped to MITRE ATT&CK when detection rules are written.

## Consequences
- Design choices are justified by evidence, which also makes them easy to explain in interviews.
- Extra documentation effort in every phase.
- "Done" means evidenced by a test or an alert, not by intention.
- The project never claims to be unbreakable; residual risks are documented.
