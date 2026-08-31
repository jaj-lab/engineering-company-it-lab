
# Active Directory Users

## 1. Domain

The laboratory Active Directory domain is:

```text
engineering.local
```

User accounts are located in:

```text
OU=Users,OU=Engineering Company,DC=engineering,DC=local
```

---

## 2. User Accounts

The current laboratory user accounts are:

| User  | Display Name | UPN                       | OU    | Status  |
| ----- | ------------ | ------------------------- | ----- | ------- |
| alice | Alice        | `alice@engineering.local` | Users | Enabled |
| john  | John         | `john@engineering.local`  | Users | Enabled |
| sarah | Sarah        | `sarah@engineering.local` | Users | Enabled |

These accounts represent employees of the simulated engineering
company and are used for testing authentication, Group Policy,
permissions, and resource access.

---

## 3. Account Placement

All standard domain users are created in:

```text
OU=Users,OU=Engineering Company,DC=engineering,DC=local
```

Expected structure:

```text
engineering.local
└── Engineering Company
    └── Users
        ├── Alice
        ├── John
        └── Sarah
```

User accounts are not created directly in the domain root.

---

## 4. Group Membership

User access is managed through security groups rather than assigning
resource permissions directly to individual users.

Current group assignments are defined in:

```text
../ad/groups.md
```

The implemented groups include:

```text
GG-Engineering
GG-IT
GG-Management
```

Users should be assigned to groups according to their simulated
company role.

The group membership configuration is the authoritative source for
resource access and permission testing.

---

## 5. Account Configuration

The user accounts should have the following baseline properties:

```text
Account type:
    Standard domain user

Location:
    OU=Users,OU=Engineering Company,DC=engineering,DC=local

Authentication:
    Active Directory domain authentication

Domain:
    engineering.local

Initial password:
    Set during account provisioning

Password storage:
    Never stored in repository

Account status:
    Enabled
```

Passwords and other authentication secrets must never be committed
to the repository.

If initial passwords are required during automated provisioning, they
must be supplied through a secure mechanism or interactively rather
than hard-coded into `users.md` or `setup-ad.ps1`.

---

## 6. Administrative Model

The laboratory separates ordinary user accounts from administrative
accounts.

The users defined in this document are standard domain users.

Administrative operations should be performed using appropriate
administrative credentials rather than granting unnecessary
privileges to standard employee accounts.

This allows the laboratory to demonstrate:

* Standard user authentication
* Group-based access control
* Least-privilege administration
* Group Policy behavior
* Permission testing
* User lifecycle operations

---

## 7. Implementation

User creation is intended to be reproducible through:

```text
setup-ad.ps1
```

The implementation should:

1. Ensure the `Users` OU exists.
2. Create the required user accounts if they do not already exist.
3. Place the accounts in the correct OU.
4. Configure the intended account properties.
5. Apply the required group memberships.
6. Avoid recreating or overwriting existing accounts unnecessarily.

The script must not contain permanent production-style passwords or
other secrets.

---

## 8. Verification

The following should be verified after provisioning:

```text
[x] Alice exists
[x] John exists
[x] Sarah exists

[x] All accounts are located in the Users OU
[x] All accounts are enabled
[x] Domain authentication works
[x] Required group memberships are present
```

User authentication should be tested from a domain-joined workstation
such as WIN01.

---

## 9. Relationship to Other Configuration

User definitions are intentionally separated from the other Active
Directory configuration:

```text
ou-structure.md
        |
        v
    AD structure
        |
        +----> users.md
        |          |
        |          v
        |       User accounts
        |
        +----> groups.md
                   |
                   v
              Group membership
```

The PowerShell implementation is provided by:

```text
setup-ad.ps1
```

If the implemented user population or account structure changes,
this document and the corresponding automation must be updated
together.

The actual Active Directory environment remains the source of truth.
