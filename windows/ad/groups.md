
# Active Directory Security Groups

## 1. Domain

The laboratory Active Directory domain is:

```text
engineering.local
```

Security groups are located in:

```text
OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

---

## 2. Group Structure

The current security groups are:

```text
engineering.local
└── Engineering Company
    └── Groups
        ├── GG-Engineering
        ├── GG-IT
        └── GG-Management
```

All three groups are security groups used for access control within
the simulated company environment.

---

## 3. GG-Engineering

```text
Name:
    GG-Engineering

Type:
    Security group

Scope:
    Global

Location:
    OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

Purpose:

Represents employees belonging to the Engineering department.

The group is used to provide department-level access without assigning
permissions directly to individual users.

Primary resource relationship:

```text
GG-Engineering
        |
        v
Engineering department resources
```

---

## 4. GG-IT

```text
Name:
    GG-IT

Type:
    Security group

Scope:
    Global

Location:
    OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

Purpose:

Represents members of the IT department.

The group is used for administrative and IT-specific resource access
within the laboratory.

Primary resource relationship:

```text
GG-IT
   |
   v
IT resources / administrative access
```

---

## 5. GG-Management

```text
Name:
    GG-Management

Type:
    Security group

Scope:
    Global

Location:
    OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

Purpose:

Represents members of company management.

The group is used to provide management-specific access to resources
without assigning permissions directly to individual accounts.

Primary resource relationship:

```text
GG-Management
       |
       v
Management resources
```

---

## 6. User Membership

The current laboratory users are:

```text
alice
john
sarah
```

Their group memberships are used as the basis for resource access.

The implemented membership model is:

| User  | Group          |
| ----- | -------------- |
| Alice | GG-Engineering |
| John  | GG-IT          |
| Sarah | GG-Management  |

Expected membership structure:

```text
Alice
  |
  +----> GG-Engineering

John
  |
  +----> GG-IT

Sarah
  |
  +----> GG-Management
```

This provides three distinct user roles for testing group-based
authorization.

---

## 7. Permission Model

Resource permissions should be assigned to security groups rather
than directly to individual users wherever practical.

The intended model is:

```text
User
  |
  v
Security Group
  |
  v
Resource Permission
  |
  v
Resource
```

For example:

```text
Alice
  |
  v
GG-Engineering
  |
  v
Engineering resources
```

This approach simplifies access management and allows users to gain
or lose access by changing group membership rather than modifying
permissions on every resource.

---

## 8. SMB Integration

The security groups are used by the Windows file-service
configuration.

The implemented departmental resource structure is:

```text
Engineering
IT
Management
```

Access to these resources is controlled through the corresponding
security groups.

The detailed share and NTFS configuration is defined separately in:

```text
windows/file-services/smb.md
```

The corresponding implementation is provided by:

```text
windows/file-services/setup-smb.ps1
```

---

## 9. Group Configuration

The groups should use the following baseline configuration:

```text
Group type:
    Security

Group scope:
    Global

Location:
    OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

Group names follow the `GG-<Department>` convention.

This convention makes the purpose of the groups immediately
identifiable and leaves room for additional groups if future
infrastructure requires them.

---

## 10. Implementation

Group creation and membership configuration are intended to be
reproducible through:

```text
setup-ad.ps1
```

The implementation should:

1. Ensure the `Groups` OU exists.
2. Create the required security groups if they do not already exist.
3. Place the groups in the correct OU.
4. Configure the appropriate group scope and type.
5. Add users to their required groups.
6. Avoid unnecessarily recreating existing groups or memberships.

---

## 11. Verification

The following group configuration should be verified:

```text
[x] GG-Engineering exists
[x] GG-IT exists
[x] GG-Management exists

[x] All groups are security groups
[x] All groups are Global scope
[x] All groups are located in the Groups OU

[x] Alice is a member of GG-Engineering
[x] John is a member of GG-IT
[x] Sarah is a member of GG-Management

[x] Group-based resource access works
[x] SMB permissions are enforced through group membership
```

Membership and access behavior should be verified from WIN01 using
the appropriate domain user accounts.

---

## 12. Design

The laboratory intentionally uses a simple group model:

```text
                    Engineering Company
                            |
                         Groups
                            |
          +-----------------+-----------------+
          |                 |                 |
          v                 v                 v
   GG-Engineering        GG-IT         GG-Management
          |                 |                 |
          v                 v                 v
    Engineering           IT             Management
      users             users              users
```

The design demonstrates group-based authorization while remaining
small enough to understand and administer.

Additional groups should be introduced only when a real permission,
administrative, or policy boundary requires them.

The actual Active Directory state is the source of truth.
