
# Domain Baseline GPO

## 1. GPO

The domain baseline policy is:

```text
Domain Baseline
```

The policy provides baseline configuration for the
`engineering.local` Active Directory domain.

It is applied at the domain level and establishes common settings
for the simulated company environment.

---

## 2. Scope

The policy is associated with:

```text
engineering.local
```

The intended scope is the domain and its applicable domain objects.

The policy provides settings that should apply consistently across
the laboratory domain rather than only to individual workstations or
users.

---

## 3. Purpose

The Domain Baseline GPO provides a basic security and administration
baseline for the laboratory domain.

Its purpose is to demonstrate:

* Centralized configuration management
* Group Policy administration
* Domain-wide policy application
* Security baseline configuration
* Policy inheritance
* GPO verification

The policy is intentionally limited to settings that are meaningful
for the current laboratory environment.

---

## 4. Policy Configuration

The implemented Domain Baseline GPO contains the domain-level
settings configured during Phase 3.

The policy configuration is maintained through the Windows Group
Policy infrastructure rather than duplicated as independent settings
in this document.

The current policy should be treated as the authoritative Windows
configuration.

A reproducible PowerShell implementation is provided by:

```text
setup-gpo.ps1
```

---

## 5. Policy Application

The policy is applied through Active Directory Group Policy.

The configuration flow is:

```text
engineering.local
        |
        v
Domain Baseline
        |
        v
Domain Objects
        |
        +------------------+
        |                  |
        v                  v
   Workstations          Users
```

The Domain Baseline policy works together with the more specific
workstation and user baseline policies.

---

## 6. Relationship to Other GPOs

The laboratory uses separate policies for different configuration
scopes:

```text
Domain Baseline
        |
        +----> Domain-wide configuration
        |
        +----> Workstation Baseline
        |
        +----> User Baseline
```

The other baseline policies are documented in:

```text
workstation-baseline.md
user-baseline.md
```

This separation keeps domain-wide, workstation-specific, and
user-specific configuration logically distinct.

---

## 7. Verification

The Domain Baseline GPO was verified as part of the Phase 3
implementation.

Verified:

```text
[x] GPO exists
[x] GPO is linked to the intended domain scope
[x] Domain Baseline settings are configured
[x] Group Policy processing succeeds
[x] Policy application was verified from WIN01
[x] No unexpected policy failure was observed
```

Policy application can be inspected from a domain-joined workstation
using standard Windows Group Policy tools.

---

## 8. Implementation

The intended implementation is reproducible through:

```text
setup-gpo.ps1
```

The script should:

1. Ensure the required GPO exists.
2. Configure the intended domain baseline settings.
3. Link the GPO to the appropriate Active Directory scope.
4. Avoid creating duplicate policies.
5. Allow the resulting configuration to be verified from a domain
   member workstation.

The script should not contain credentials or other authentication
secrets.

---

## 9. Current State

The Domain Baseline GPO is:

```text
Status:
    IMPLEMENTED AND VERIFIED

Domain:
    engineering.local

GPO:
    Domain Baseline

Scope:
    Domain

Verification:
    WIN01
```

The actual Group Policy configuration in Active Directory remains the
source of truth.

If the policy settings, scope, links, or implementation change, this
document and `setup-gpo.ps1` should be reviewed and updated together.
