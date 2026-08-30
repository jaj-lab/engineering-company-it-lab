# Permissions and Access Control

## Overview

The Engineering Lab uses Active Directory security groups to control access to company resources.

The access-control model follows a simple role-based approach:

```text
User
  |
  v
AD Security Group
  |
  v
SMB Share
  |
  v
NTFS Permissions
  |
  v
Resource Access
```

Individual users are not assigned directly to resource ACLs. Instead, users receive permissions through membership in the appropriate security group.

The current laboratory implements three organizational access groups:

```text
OU=Groups,OU=Engineering Company,DC=engineering,DC=local
    |
    +-- GG-Engineering
    +-- GG-IT
    └-- GG-Management
```

---

## Active Directory Security Groups

All application/resource access groups are configured as **Global Security groups**.

| Group            | Scope  | Category | Members      |
| ---------------- | ------ | -------- | ------------ |
| `GG-Engineering` | Global | Security | Alice Miller |
| `GG-IT`          | Global | Security | John Smith   |
| `GG-Management`  | Global | Security | Sarah Wilson |

Current membership:

```text
Alice Miller
    |
    +-- GG-Engineering

John Smith
    |
    +-- GG-IT

Sarah Wilson
    |
    +-- GG-Management
```

Groups are stored in:

```text
OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

This separates access-control objects from user accounts and provides a dedicated location for future group administration.

---

## Resource Structure

Company resources are located on DC01 under:

```text
C:\CompanyData
    |
    +-- Engineering
    +-- IT
    └-- Management
```

The directories are exposed through SMB shares:

```text
\\DC01\Engineering
\\DC01\IT
\\DC01\Management
```

The existing Active Directory shares are also present:

```text
\\DC01\SYSVOL
\\DC01\NETLOGON
```

`SYSVOL` and `NETLOGON` are managed by Active Directory and were not modified as part of the company resource access configuration.

---

## Access Control Model

The intended resource access model is:

| Resource    | GG-Engineering |        GG-IT | GG-Management |
| ----------- | -------------: | -----------: | ------------: |
| Engineering |         Modify | Full Control |     No Access |
| IT          |      No Access | Full Control |     No Access |
| Management  |      No Access | Full Control |        Modify |

This provides the following logical roles:

### Engineering

Engineering users can modify Engineering resources.

They do not receive access to IT or Management resources.

```text
GG-Engineering
      |
      +-- Modify
           |
           v
    \\DC01\Engineering
```

### IT

IT users have administrative access to all three company resource areas.

```text
GG-IT
   |
   +-- Full Control --> \\DC01\IT
   |
   +-- Full Control --> \\DC01\Engineering
   |
   +-- Full Control --> \\DC01\Management
```

This reflects the laboratory assumption that IT personnel are responsible for administering company resources.

### Management

Management users can modify Management resources.

They do not receive access to Engineering or IT resources.

```text
GG-Management
      |
      +-- Modify
           |
           v
    \\DC01\Management
```

---

## NTFS Permissions

The primary resource permissions are implemented using NTFS ACLs.

The intended permissions are:

```text
C:\CompanyData\Engineering
    |
    +-- GG-Engineering   -> Modify
    +-- GG-IT            -> Full Control

C:\CompanyData\IT
    |
    +-- GG-IT            -> Full Control

C:\CompanyData\Management
    |
    +-- GG-Management    -> Modify
    +-- GG-IT            -> Full Control
```

Standard system-level permissions remain present where required:

```text
NT AUTHORITY\SYSTEM       -> Full Control
BUILTIN\Administrators    -> Full Control
CREATOR OWNER             -> Full Control on created objects
```

Broad `BUILTIN\Users` access was removed from the company resource directories so that ordinary domain users do not receive unintended access through a generic local group.

---

## SMB Share Permissions

The company directories are published as SMB shares:

```text
Engineering
    -> C:\CompanyData\Engineering

IT
    -> C:\CompanyData\IT

Management
    -> C:\CompanyData\Management
```

UNC paths:

```text
\\DC01\Engineering
\\DC01\IT
\\DC01\Management
```

SMB share permissions are combined with NTFS permissions when a user accesses a resource remotely.

Therefore, effective access is determined by both layers:

```text
SMB Share Permissions
        +
NTFS Permissions
        |
        v
Effective Access
```

The more restrictive effective permission applies when accessing a resource through SMB.

---

## Permission Administration Principle

Permissions should be assigned to **groups**, not directly to individual users.

Preferred model:

```text
User
  |
  v
Security Group
  |
  v
Resource ACL
```

Avoid:

```text
User
  |
  +------------------> Resource ACL
```

This makes access management easier to maintain when employees change roles.

For example, if Alice changes from Engineering to Management, access should be changed primarily through group membership rather than manually editing every resource ACL.

---

## Verification

Active Directory groups:

```powershell
Get-ADGroup `
    -Filter 'Name -like "GG-*"' |
    Select-Object Name, GroupScope, GroupCategory
```

Group membership:

```powershell
Get-ADGroupMember GG-Engineering

Get-ADGroupMember GG-IT

Get-ADGroupMember GG-Management
```

Company resource structure:

```powershell
Get-ChildItem C:\CompanyData
```

NTFS ACL inspection:

```powershell
Get-Acl "C:\CompanyData\Engineering" |
    Select-Object -ExpandProperty Access

Get-Acl "C:\CompanyData\IT" |
    Select-Object -ExpandProperty Access

Get-Acl "C:\CompanyData\Management" |
    Select-Object -ExpandProperty Access
```

The ACLs can also be inspected with:

```powershell
icacls "C:\CompanyData\Engineering"

icacls "C:\CompanyData\IT"

icacls "C:\CompanyData\Management"
```

SMB shares:

```powershell
Get-SmbShare
```

---

## Functional Access Verification

Access was tested using a domain user:

```text
engineering\john.smith
```

John Smith is a member of:

```text
ENGINEERING\GG-IT
```

The following resources were tested:

```text
\\DC01\IT
\\DC01\Engineering
\\DC01\Management
```

The IT group successfully accessed all three resources and successfully performed write operations.

Test files were created and subsequently removed to avoid leaving temporary data in the laboratory.

---

## Incident: SMB Share Permissions

During Phase 3 verification, an access-control issue was discovered.

### Initial configuration

The Engineering/IT resource had:

```text
SMB Share Permissions
    Everyone -> Read
```

while the NTFS ACL granted:

```text
ENGINEERING\GG-IT -> Full Control
```

The resulting behavior was:

```text
Read
    -> SUCCESS

Write
    -> DENIED
```

Although the NTFS permissions allowed the operation, the SMB share permissions did not.

### Investigation

Both permission layers were inspected:

```text
SMB Share ACL
      +
NTFS ACL
      |
      v
Effective Access
```

The mismatch between the two layers was identified as the cause of the failed write operation.

### Resolution

The SMB share permissions were corrected so that the intended group-based access model could operate correctly.

The resource was then retested.

Final result:

```text
IT -> IT share            WRITE SUCCESS
IT -> Engineering share   WRITE SUCCESS
IT -> Management share    WRITE SUCCESS
```

The incident was documented as:

```text
INC-004 — SMB Share Permissions Prevented Expected Write Access
```

---

## Security Considerations

The current laboratory implements the following access-control principles:

* Access is granted through AD security groups.
* Users are not directly assigned to resource ACLs.
* Company resources have dedicated NTFS ACLs.
* Broad `BUILTIN\Users` permissions were removed.
* IT access is explicitly granted through `GG-IT`.
* Resource access is separated by organizational role.
* SMB and NTFS permissions are considered together.
* Access changes should normally be performed through group membership.
* Permissions are verified through both configuration inspection and functional testing.

The current model is intentionally simple because the laboratory represents a small engineering company.

More granular groups can be introduced later if the environment grows, for example:

```text
GG-Engineering
GG-IT
GG-Management

        |
        +-- future resource-specific groups
```

The laboratory does not currently implement a large-scale AGDLP/AGUDLP hierarchy because the current environment does not require that level of complexity.

---

## Current Access-Control State

```text
Active Directory
    |
    +-- Users
    |     |
    |     +-- Alice Miller
    |     +-- John Smith
    |     └-- Sarah Wilson
    |
    +-- Security Groups
    |     |
    |     +-- GG-Engineering
    |     +-- GG-IT
    |     └-- GG-Management
    |
    +-- Company Resources
          |
          +-- Engineering
          +-- IT
          └-- Management
                 |
                 v
          SMB + NTFS ACLs
```

Current status:

```text
AD security groups       [OK]
Group membership         [OK]
NTFS permissions         [OK]
SMB shares               [OK]
Functional access        [OK]
Write access             [OK]
Permission verification  [OK]
INC-004                  [RESOLVED]
```

## Result

The Engineering Lab now uses a functional group-based access-control model for company resources.

Users receive resource permissions through Active Directory security-group membership, while NTFS and SMB permissions enforce the resulting access at the file-sharing layer.

The model has been functionally tested with domain credentials, including successful read/write operations and troubleshooting of an actual SMB permission failure.
