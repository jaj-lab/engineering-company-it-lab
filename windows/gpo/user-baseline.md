
# User Baseline GPO

## 1. GPO

The user baseline policy is:

```text
User Baseline
```

The policy provides baseline configuration for domain users in the
`engineering.local` environment.

The policy applies to user accounts rather than computer objects.

---

## 2. Scope

The policy is intended for standard domain users.

Current laboratory user accounts include:

```text
alice
john
sarah
```

The users are located in:

```text
OU=Users,OU=Engineering Company,DC=engineering,DC=local
```

The policy is applied through Active Directory Group Policy to the
appropriate user scope.

---

## 3. Purpose

The User Baseline GPO provides a consistent configuration baseline
for employees using the Windows environment.

Its purpose is to demonstrate:

* Centralized user configuration
* User-level Group Policy
* Domain user management
* User restrictions
* Policy inheritance
* Group Policy verification
* Separation of user and computer configuration

The policy is intentionally limited to settings relevant to the
current laboratory environment.

---

## 4. Policy Configuration

The implemented User Baseline GPO contains the user-level settings
configured during Phase 3.

These settings are maintained through the Windows Group Policy
infrastructure.

The actual GPO configuration is the authoritative source for the
implemented user settings.

A reproducible PowerShell implementation is provided by:

```text
setup-gpo.ps1
```

---

## 5. Application

The User Baseline policy is processed when a domain user signs in to
a domain-joined workstation.

The current laboratory flow is:

```text
Domain User
     |
     v
engineering.local
     |
     v
User Baseline
     |
     v
WIN01
     |
     v
User Session
```

The policy therefore follows the user account rather than the
physical or virtual workstation itself.

---

## 6. User Restrictions

The User Baseline GPO includes the user restrictions configured during
the Phase 3 implementation.

These restrictions are intended to demonstrate centralized control
over the employee user environment.

The resulting behavior was verified using domain user accounts on
WIN01.

The exact configured settings should be maintained in the actual GPO
and reproduced by `setup-gpo.ps1` rather than duplicated manually in
this document.

---

## 7. Relationship to Other GPOs

The laboratory separates configuration according to its scope:

```text
Domain Baseline
        |
        +----> Domain-wide configuration

Workstation Baseline
        |
        +----> Computer / workstation configuration

User Baseline
        |
        +----> User configuration
```

The other baseline policies are documented in:

```text
domain-baseline.md
workstation-baseline.md
```

This separation makes it possible to distinguish domain-wide,
computer-level, and user-level policy behavior.

---

## 8. Verification

The User Baseline GPO was verified using domain users on WIN01.

Verified:

```text
[x] GPO exists
[x] GPO is linked to the intended user scope
[x] User baseline settings are configured
[x] Domain users can authenticate on WIN01
[x] Group Policy processing succeeds
[x] User baseline was applied
[x] User restrictions were verified
```

The resulting user environment was checked as part of the Phase 3
Group Policy verification.

---

## 9. Implementation

The intended implementation is reproducible through:

```text
setup-gpo.ps1
```

The script should:

1. Ensure the required GPO exists.
2. Configure the intended user baseline settings.
3. Link the GPO to the appropriate user scope.
4. Avoid creating duplicate policies.
5. Allow the resulting configuration to be verified from a domain
   user session.

The script must not contain credentials or other authentication
secrets.

---

## 10. Current State

The User Baseline GPO is:

```text
Status:
    IMPLEMENTED AND VERIFIED

Domain:
    engineering.local

GPO:
    User Baseline

Target:
    Domain users

Current test workstation:
    WIN01
    192.168.100.30

Verification:
    COMPLETE
```

The actual Group Policy configuration in Active Directory remains the
source of truth.

If the policy settings, scope, links, or user architecture change,
this document and `setup-gpo.ps1` should be reviewed and updated
together.
