
# SMB File Services

## 1. Overview

The Engineering Company laboratory provides domain-based SMB file
shares from:

```text
DC01
```

The file services are used to demonstrate:

* SMB share administration
* Active Directory group-based access control
* NTFS permissions
* Share permissions
* User and group access testing
* Windows file-service troubleshooting

The implemented file-service structure is:

```text
DC01
└── C:\CompanyData
    ├── Engineering
    ├── IT
    └── Management
```

The corresponding network shares are:

```text
\\DC01\Engineering
\\DC01\IT
\\DC01\Management
```

---

## 2. SMB Shares

The laboratory currently provides three company shares.

| Share       | Local Path                   | UNC Path             |
| ----------- | ---------------------------- | -------------------- |
| Engineering | `C:\CompanyData\Engineering` | `\\DC01\Engineering` |
| IT          | `C:\CompanyData\IT`          | `\\DC01\IT`          |
| Management  | `C:\CompanyData\Management`  | `\\DC01\Management`  |

The shares are hosted directly on DC01.

---

## 3. Engineering Share

The Engineering share is located at:

```text
C:\CompanyData\Engineering
```

and is available through:

```text
\\DC01\Engineering
```

The intended NTFS access model is:

```text
GG-Engineering
    |
    +-- Modify

GG-IT
    |
    +-- Full Control
```

This allows members of the Engineering group to modify engineering
documents while IT administrators retain full administrative access.

---

## 4. IT Share

The IT share is located at:

```text
C:\CompanyData\IT
```

and is available through:

```text
\\DC01\IT
```

The intended NTFS access model is:

```text
GG-IT
    |
    +-- Full Control
```

The IT share is therefore restricted to the IT administrative group
at the NTFS level.

---

## 5. Management Share

The Management share is located at:

```text
C:\CompanyData\Management
```

and is available through:

```text
\\DC01\Management
```

The intended NTFS access model is:

```text
GG-IT
    |
    +-- Full Control

GG-Management
    |
    +-- Modify
```

This allows Management users to work with management resources while
IT retains administrative access.

---

## 6. Permission Model

Access is managed through Active Directory security groups rather than
assigning permissions directly to individual users.

The implemented model is:

```text
User
  |
  v
Active Directory Security Group
  |
  +----------------------+
  |                      |
  v                      v
SMB Share Permission    NTFS Permission
  |                      |
  +----------+-----------+
             |
             v
       Resource Access
```

The relevant groups are:

```text
GG-Engineering
GG-IT
GG-Management
```

Users receive access through their group membership.

This follows a group-based access-control model and avoids unnecessary
direct user ACL assignments.

---

## 7. Share Permissions

The SMB shares are configured to permit authenticated domain access
while the effective resource permissions are enforced through the
combination of SMB share permissions and NTFS ACLs.

During the initial implementation, share permissions were configured
too restrictively for the intended access model.

The resulting access problem was investigated and documented as:

```text
INC-004-smb-limited-access-permissions.md
```

The issue was resolved by correcting the SMB share permissions.

The final configuration allows the intended domain users to reach the
shares while NTFS permissions provide the resource-level access
control.

---

## 8. NTFS Permissions

The final NTFS permission model is:

| Share       | Group            | Access       |
| ----------- | ---------------- | ------------ |
| Engineering | `GG-Engineering` | Modify       |
| Engineering | `GG-IT`          | Full Control |
| IT          | `GG-IT`          | Full Control |
| Management  | `GG-IT`          | Full Control |
| Management  | `GG-Management`  | Modify       |

The NTFS permissions are the primary resource-level authorization
mechanism.

Permissions should be evaluated together with the SMB share
permissions when determining effective access.

---

## 9. Administrative Access

The `GG-IT` group provides administrative access to the company file
shares.

The implemented model is:

```text
GG-IT
 |
 +-- Engineering → Full Control
 |
 +-- IT          → Full Control
 |
 └-- Management  → Full Control
```

This provides IT administrators with the access required to manage
the file-service environment.

---

## 10. Implementation

The SMB configuration is intended to be reproducible through:

```text
setup-smb.ps1
```

The implementation should:

1. Create the required company data directories.
2. Create the Engineering SMB share.
3. Create the IT SMB share.
4. Create the Management SMB share.
5. Configure the required SMB share permissions.
6. Configure the required NTFS ACLs.
7. Preserve administrative access for `GG-IT`.
8. Avoid unnecessary direct permissions for individual users.
9. Verify the resulting share configuration.

The script should represent the final verified configuration rather
than the original configuration that caused INC-004.

---

## 11. Verification

The following file-service behavior was verified:

```text
[x] Engineering share exists
[x] IT share exists
[x] Management share exists

[x] \\DC01\Engineering is accessible
[x] \\DC01\IT is accessible
[x] \\DC01\Management is accessible

[x] Engineering permissions verified
[x] IT permissions verified
[x] Management permissions verified

[x] NTFS permissions verified
[x] SMB share permissions investigated
[x] Group-based access verified
[x] SMB write access verified
[x] SMB delete access verified

[x] Initial permission issue identified
[x] Root cause investigated
[x] SMB permissions corrected
[x] Access re-tested successfully
```

The final SMB configuration is considered verified against the current
laboratory state.

---

## 12. Relationship to Active Directory

The file-service permissions depend on the Active Directory groups
defined in:

```text
../ad/groups.md
```

The relationship is:

```text
Active Directory
      |
      +-- GG-Engineering
      |       |
      |       v
      |   Engineering
      |
      +-- GG-IT
      |       |
      |       +----> Engineering
      |       +----> IT
      |       └----> Management
      |
      └-- GG-Management
              |
              v
          Management
```

Changes to the implemented security groups or group membership model
must be reviewed against the SMB permission configuration.

---

## 13. Troubleshooting Reference

The initial SMB permission problem is documented in:

```text
docs/incidents/INC-004-smb-limited-access-permissions.md
```

The incident demonstrates the difference between:

```text
SMB Share Permissions
        +
NTFS Permissions
        =
Effective File Access
```

When troubleshooting SMB access, both permission layers should be
examined rather than assuming that successful share creation implies
correct resource authorization.

---

## 14. Current State

The current verified file-service architecture is:

```text
engineering.local
       |
       v
     DC01
       |
       +-- Active Directory
       |
       +-- SMB
       |
       +-- C:\CompanyData
              |
              +-- Engineering
              |      |
              |      +-- GG-Engineering → Modify
              |      └-- GG-IT         → Full Control
              |
              +-- IT
              |      |
              |      └-- GG-IT         → Full Control
              |
              └-- Management
                     |
                     +-- GG-Management → Modify
                     └-- GG-IT         → Full Control
```

The SMB configuration is implemented and verified.

The repository configuration is intended to reproduce the final
laboratory state.
