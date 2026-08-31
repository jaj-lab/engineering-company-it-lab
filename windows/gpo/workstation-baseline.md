
# Workstation Baseline GPO

## 1. GPO

The workstation baseline policy is:

```text
Workstation Baseline
```

The policy provides baseline configuration for domain-joined
Windows workstations in the `engineering.local` environment.

The current laboratory workstation is:

```text
WIN01
192.168.100.30
```

---

## 2. Scope

The policy is intended for domain-joined workstation computers.

Current laboratory scope:

```text
engineering.local
└── Engineering Company
    └── Workstations
        └── WIN01
```

The policy is applied to workstation computer objects through Active
Directory Group Policy.

---

## 3. Purpose

The Workstation Baseline GPO provides a consistent configuration
baseline for employee Windows workstations.

Its purpose is to demonstrate:

* Centralized workstation configuration
* Computer-level Group Policy
* Workstation security configuration
* Policy inheritance
* Domain-joined workstation management
* Group Policy verification

The policy is intentionally limited to settings relevant to the
current laboratory environment.

---

## 4. Policy Configuration

The implemented Workstation Baseline GPO contains the workstation
settings configured during Phase 3.

These settings are maintained by the Windows Group Policy
infrastructure.

The actual GPO configuration is the authoritative source for the
implemented workstation settings.

A reproducible PowerShell implementation is provided by:

```text
setup-gpo.ps1
```

---

## 5. Application

The Workstation Baseline policy is processed by domain-joined
workstation computers.

The configuration flow is:

```text
engineering.local
        |
        v
Workstation Baseline
        |
        v
Workstations OU
        |
        v
WIN01
```

The policy is processed as part of the normal Group Policy cycle for
the domain-joined workstation.

---

## 6. Relationship to Other GPOs

The laboratory separates workstation configuration from domain-wide
and user-specific configuration.

```text
Domain Baseline
        |
        +----> Domain-wide settings
        |
        v
Workstation Baseline
        |
        +----> Computer / workstation settings
        |
        v
WIN01

User Baseline
        |
        +----> User-specific settings
```

The other baseline policies are documented in:

```text
domain-baseline.md
user-baseline.md
```

This separation allows computer-level and user-level configuration to
be tested independently.

---

## 7. Verification

The Workstation Baseline GPO was verified on the domain-joined
workstation.

Verified:

```text
[x] GPO exists
[x] GPO is linked to the intended workstation scope
[x] Workstation baseline settings are configured
[x] WIN01 is domain joined
[x] Group Policy processing succeeds
[x] Workstation baseline was applied to WIN01
[x] Policy behavior was verified
```

The resulting workstation configuration was checked as part of the
Phase 3 verification process.

---

## 8. Implementation

The intended implementation is reproducible through:

```text
setup-gpo.ps1
```

The script should:

1. Ensure the required GPO exists.
2. Configure the intended workstation baseline settings.
3. Link the GPO to the appropriate workstation scope.
4. Avoid creating duplicate policies.
5. Allow the resulting configuration to be verified from WIN01.

The script must not contain credentials or other authentication
secrets.

---

## 9. Current State

The Workstation Baseline GPO is:

```text
Status:
    IMPLEMENTED AND VERIFIED

Domain:
    engineering.local

GPO:
    Workstation Baseline

Target:
    Domain-joined workstations

Current workstation:
    WIN01
    192.168.100.30

Verification:
    COMPLETE
```

The actual Group Policy configuration in Active Directory remains the
source of truth.

If the policy settings, scope, links, or workstation architecture
change, this document and `setup-gpo.ps1` should be reviewed and
updated together.
