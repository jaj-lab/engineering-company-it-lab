
# Active Directory OU Structure

## 1. Domain

The laboratory Active Directory domain is:

```text
engineering.local
```

The AD organizational structure is designed to separate users,
groups, and computer accounts by administrative purpose.

---

## 2. OU Structure

The current OU hierarchy is:

```text
engineering.local
└── Engineering Company
    ├── Users
    ├── Groups
    └── Workstations
```

The `Engineering Company` OU serves as the main organizational
container for the simulated company infrastructure.

---

## 3. Engineering Company

```text
OU=Engineering Company,DC=engineering,DC=local
```

Purpose:

* Main organizational container for the simulated company
* Parent OU for company-specific objects
* Provides a consistent root for future organizational expansion

Company-specific OUs are created below this container rather than
placing all objects directly in the domain root.

---

## 4. Users

```text
OU=Users,OU=Engineering Company,DC=engineering,DC=local
```

Purpose:

* Contains domain user accounts
* Separates user objects from computer and group objects
* Provides an appropriate scope for user-related administration
  and Group Policy

Current users are documented separately in:

```text
users.md
```

---

## 5. Groups

```text
OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

Purpose:

* Contains security groups used to organize access and permissions
* Separates group objects from user and computer accounts
* Provides a dedicated location for company access-control groups

Current security groups are documented separately in:

```text
groups.md
```

---

## 6. Workstations

```text
OU=Workstations,OU=Engineering Company,DC=engineering,DC=local
```

Purpose:

* Contains domain-joined workstation computer accounts
* Separates workstation objects from user accounts and groups
* Provides an appropriate scope for workstation-related Group Policy

WIN01 is the current domain-joined workstation.

---

## 7. Design

The OU structure intentionally separates objects by administrative
type:

```text
                 engineering.local
                        |
               Engineering Company
                        |
          +-------------+-------------+
          |             |             |
        Users         Groups      Workstations
          |             |             |
       Users       Security Groups   WIN01
```

This structure provides a simple foundation for:

* Group Policy targeting
* Delegated administration
* User management
* Computer management
* Access-control organization
* Future expansion of the laboratory environment

The structure is intentionally small because the laboratory currently
contains only the infrastructure required for the implemented
environment.

Additional OUs should be introduced only when they provide a real
administrative or policy boundary.

---

## 8. Implementation

The OU structure is intended to be reproducible through:

```text
setup-ad.ps1
```

The script should create the required OUs only when they do not
already exist, allowing the configuration to be safely re-applied
without unnecessarily recreating existing objects.

The implementation target is:

```text
engineering.local
└── Engineering Company
    ├── Users
    ├── Groups
    └── Workstations
```

---

## 9. Verification

The implemented OU structure can be verified using Active Directory
administration tools or PowerShell.

Expected OUs:

```text
Engineering Company
├── Users
├── Groups
└── Workstations
```

The actual domain state is the source of truth.

If the implemented structure changes, this document and
`setup-ad.ps1` must be updated together.
