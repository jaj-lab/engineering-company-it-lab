# Active Directory Architecture

## Overview

The Engineering Company laboratory uses Microsoft Active Directory Domain Services (AD DS) as the central identity and domain-management platform.

The environment is intentionally small and represents a single-domain engineering company infrastructure:

```text
Forest: engineering.local
Domain: engineering.local
NetBIOS: ENGINEERING

                    engineering.local
                           |
                    +------+------+
                    |             |
                  DC01          Domain Clients
                    |             |
              AD DS / DNS      WIN01 / future clients
                    |
              DHCP / SMB
```

The Active Directory environment provides:

* centralized user authentication
* centralized computer/domain membership
* organizational structure through OUs
* role-based access through security groups
* Group Policy management
* AD-integrated DNS
* domain service discovery
* centralized access control for SMB resources

The laboratory currently operates with a **single writable Domain Controller**.

---

## Domain and Forest

| Property          | Value                    |
| ----------------- | ------------------------ |
| Forest            | `engineering.local`      |
| Domain            | `engineering.local`      |
| NetBIOS name      | `ENGINEERING`            |
| Domain Controller | `DC01.engineering.local` |
| DC address        | `192.168.100.20`         |
| Global Catalog    | Enabled                  |
| RODC              | No                       |
| FSMO roles        | Held by DC01             |

The forest and domain were created during the initial promotion of `DC01`.

The laboratory uses a single-domain forest because the environment represents a small company and does not require multiple domains or administrative boundaries.

The `.local` namespace is intentional for this isolated laboratory environment and is not intended to represent a production public DNS namespace.

---

## Domain Controller

### DC01

```text
Hostname:
    DC01

FQDN:
    DC01.engineering.local

IPv4:
    192.168.100.20/24

Gateway:
    192.168.100.1

Domain:
    engineering.local
```

`DC01` is the primary infrastructure server for the laboratory and currently provides:

```text
DC01
 |
 +-- Active Directory Domain Services
 |
 +-- AD-integrated DNS
 |
 +-- DHCP
 |
 +-- SMB file shares
 |
 +-- Group Policy management
 |
 +-- Global Catalog
 |
 +-- FSMO roles
```

The term "primary domain controller" is avoided here as a technical role designation. In modern Active Directory, `DC01` is a writable Domain Controller that currently holds all FSMO roles, including the **PDC Emulator** role.

The laboratory intentionally uses one Domain Controller. This is suitable for the learning environment but does not provide production-level domain-controller redundancy.

---

## Active Directory Logical Structure

The directory is organized around an `Engineering Company` OU hierarchy.

```text
engineering.local
|
+-- OU=Domain Controllers
|      |
|      +-- DC01
|
+-- OU=Engineering Company
       |
       +-- OU=Users
       |
       +-- OU=Workstations
       |
       +-- OU=Servers
       |
       +-- OU=Groups
       |
       +-- OU=Service Accounts
```

Default Active Directory containers remain unchanged:

```text
CN=Users
CN=Computers
CN=Builtin
CN=ForeignSecurityPrincipals
CN=Managed Service Accounts
```

Company-specific objects are placed under `OU=Engineering Company`.

This separates laboratory-specific administration from the default AD containers and provides appropriate targets for future Group Policy and administrative operations.

---

## Organizational Units

### Users

```text
OU=Users,OU=Engineering Company,DC=engineering,DC=local
```

The laboratory currently keeps all normal user accounts in a single Users OU.

Current users:

```text
Alice Miller
    alice.miller

John Smith
    john.smith

Sarah Wilson
    sarah.wilson
```

Department-specific OUs were deliberately not created because the current laboratory is small.

Departmental or functional separation is represented through security groups instead.

---

### Workstations

```text
OU=Workstations,OU=Engineering Company,DC=engineering,DC=local
```

Domain-joined employee workstations are intended to be placed here.

The OU provides a dedicated target for workstation-specific Group Policy.

Current workstation:

```text
WIN01
```

The workstation baseline GPO is linked to this OU.

---

### Servers

```text
OU=Servers,OU=Engineering Company,DC=engineering,DC=local
```

The OU provides a dedicated location for member servers and future server infrastructure.

Domain Controllers remain in the default:

```text
OU=Domain Controllers
```

They are not moved into the company Servers OU because Domain Controllers have specialized security and Group Policy requirements.

---

### Groups

```text
OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

Security groups used for resource access are stored here.

Current groups:

```text
GG-Engineering
GG-IT
GG-Management
```

All three are:

```text
Scope:
    Global

Category:
    Security
```

---

### Service Accounts

```text
OU=Service Accounts,OU=Engineering Company,DC=engineering,DC=local
```

This OU provides a dedicated location for service identities.

No service-account workload is currently implemented, but the OU is part of the intended directory architecture.

---

## Identity and Access Model

The laboratory uses a group-based access model rather than assigning resource permissions directly to individual users.

```text
User
 |
 v
Security Group
 |
 v
Resource ACL
```

Current membership:

```text
Alice Miller
    |
    +--> GG-Engineering

John Smith
    |
    +--> GG-IT

Sarah Wilson
    |
    +--> GG-Management
```

The resulting resource model is:

```text
Resource                  GG-Engineering    GG-IT          GG-Management
---------------------------------------------------------------------------
Engineering               Modify            Full Control   No Access
IT                        No Access         Full Control   No Access
Management                No Access         Full Control   Modify
```

This provides a simple role-based access model suitable for the laboratory.

Permissions are assigned to groups, while users receive access through group membership.

This makes access management easier to maintain than assigning ACL entries directly to individual accounts.

---

## Group Policy Architecture

Group Policy is used to establish basic domain, workstation, and user configuration.

Current GPO structure:

```text
engineering.local
|
+-- Default Domain Policy
|
+-- Engineering Domain Baseline
|      |
|      +-- Password policy
|      +-- Account lockout policy
|
+-- Engineering Company
       |
       +-- Users
       |      |
       |      +-- Engineering User Baseline
       |
       +-- Workstations
              |
              +-- Engineering Workstation Baseline
```

### Engineering Domain Baseline

Linked at:

```text
engineering.local
```

The baseline contains the laboratory's initial domain security configuration.

Configured password/account settings include:

```text
Minimum password length:
    6 characters

Password history:
    5 passwords

Password complexity:
    Enabled

Minimum password age:
    0 days

Maximum password age:
    0 days

Account lockout threshold:
    5 invalid attempts

Account lockout duration:
    1 minute

Lockout observation window:
    1 minute
```

These settings are intentionally suitable for the training environment and should not automatically be considered an appropriate production security baseline.

---

### Engineering Workstation Baseline

Linked at:

```text
OU=Workstations,OU=Engineering Company,DC=engineering,DC=local
```

The workstation baseline enables Windows Defender Firewall for:

```text
Domain profile
Private profile
Public profile
```

This provides a dedicated policy target for workstation security configuration.

---

### Engineering User Baseline

Linked at:

```text
OU=Users,OU=Engineering Company,DC=engineering,DC=local
```

The initial user baseline restricts selected administrative/user-interface functions:

```text
Control Panel / PC Settings
Task Manager
Change Password
Logoff
```

This GPO exists primarily to demonstrate user-side Group Policy processing and OU-based policy targeting.

---

## DNS Integration

Active Directory relies on DNS for domain-controller discovery and service location.

`DC01` provides the authoritative internal DNS service for the laboratory domain.

```text
                    DC01
              192.168.100.20
                     |
              AD-integrated DNS
                     |
          +----------+----------+
          |                     |
 engineering.local       external DNS names
          |                     |
          |                forwarder
          |                     |
          |                192.168.100.1
          |
     AD service records
```

The following AD-integrated zones exist:

```text
engineering.local
_msdcs.engineering.local
DomainDnsZones.engineering.local
ForestDnsZones.engineering.local
```

Active Directory service discovery records allow clients to locate domain controllers and services.

For example:

```text
_ldap._tcp.dc._msdcs.engineering.local
```

resolves to:

```text
dc01.engineering.local
```

which resolves to:

```text
192.168.100.20
```

This DNS dependency is critical to domain operations.

Domain clients therefore use `DC01` as their DNS server rather than directly querying an external resolver.

---

## DHCP Integration

DHCP is provided by `DC01`.

```text
Network:
    192.168.100.0/24

Gateway:
    192.168.100.1

DHCP server:
    192.168.100.20
```

The DHCP scope is:

```text
192.168.100.50 - 192.168.100.100
```

DHCP options provide:

```text
Default gateway:
    192.168.100.1

DNS server:
    192.168.100.20

DNS domain:
    engineering.local
```

`WIN01` uses a DHCP reservation:

```text
WIN01
    MAC: 52-54-00-CD-78-97
    IP: 192.168.100.30
```

The previous libvirt DHCP service was removed from the laboratory network so that DC01 is the sole DHCP provider.

Libvirt continues to provide the network gateway/NAT function:

```text
Internet
    |
libvirt NAT
    |
192.168.100.1
    |
engineering-lab
    |
DC01 DHCP
```

---

## Domain Client Architecture

Domain clients use `DC01` for Active Directory-related services.

Example:

```text
WIN01
 |
 +-- IPv4: 192.168.100.30
 |
 +-- Gateway: 192.168.100.1
 |
 +-- DNS: 192.168.100.20
 |
 +-- Domain: engineering.local
 |
 +-- Domain Controller:
       DC01.engineering.local
```

Before domain joining, the workstation must be able to:

1. resolve the domain name
2. resolve the Domain Controller
3. resolve AD service-location records
4. communicate with the Domain Controller
5. authenticate against Active Directory

The laboratory verified DNS and LDAP connectivity before joining `WIN01` to the domain.

---

## SMB and Active Directory

The laboratory uses Active Directory security groups to control access to SMB resources hosted on `DC01`.

```text
DC01
 |
 +-- \\DC01\Engineering
 |
 +-- \\DC01\IT
 |
 +-- \\DC01\Management
 |
 +-- \\DC01\SYSVOL
 |
 +-- \\DC01\NETLOGON
```

The company shares use the AD security groups defined in the Groups OU.

For example:

```text
GG-Engineering
    |
    +--> \\DC01\Engineering
          Modify
```

and:

```text
GG-IT
    |
    +--> \\DC01\IT
          Full Control

    +--> \\DC01\Engineering
          Full Control

    +--> \\DC01\Management
          Full Control
```

The laboratory also retains the standard domain shares:

```text
SYSVOL
NETLOGON
```

These are required for normal domain-controller and Group Policy functionality.

---

## Authentication Flow

A simplified domain authentication flow is:

```text
User
 |
 | 1. Log on using domain credentials
 v
WIN01
 |
 | 2. DNS lookup / DC discovery
 v
DC01
 |
 | 3. Kerberos / AD authentication
 v
Active Directory
 |
 | 4. User identity + group membership
 v
WIN01
 |
 | 5. Access resource
 v
SMB / other domain resources
```

The user's effective access is determined by their Active Directory identity and security-group membership.

For SMB resources, the resulting authorization is enforced through the combination of:

```text
SMB share permissions
        +
NTFS permissions
```

The laboratory verified this behavior during `INC-004`, where read access succeeded but write access initially failed because the SMB share permissions were more restrictive than the intended NTFS permissions.

---

## Current Directory State

```text
FOREST
    engineering.local
        |
        +-- DOMAIN
        |     engineering.local
        |
        +-- DOMAIN CONTROLLER
        |     DC01
        |     192.168.100.20
        |
        +-- USERS
        |     |
        |     +-- alice.miller
        |     +-- john.smith
        |     └-- sarah.wilson
        |
        +-- SECURITY GROUPS
        |     |
        |     +-- GG-Engineering
        |     +-- GG-IT
        |     └-- GG-Management
        |
        +-- DOMAIN CLIENT
        |     |
        |     └-- WIN01
        |
        +-- DNS
        |     |
        |     +-- engineering.local
        |     +-- _msdcs.engineering.local
        |     +-- DomainDnsZones
        |     └-- ForestDnsZones
        |
        +-- DHCP
        |     |
        |     └-- 192.168.100.50-100
        |
        +-- GPO
        |     |
        |     +-- Engineering Domain Baseline
        |     +-- Engineering Workstation Baseline
        |     └-- Engineering User Baseline
        |
        └-- SMB
              |
              +-- Engineering
              +-- IT
              └-- Management
```

---

## Design Decisions

### Single-domain architecture

A single domain is sufficient for the laboratory because the environment represents one small organization.

There is currently no requirement for:

* multiple domains
* multiple forests
* cross-domain trusts
* separate administrative domains

### Company-specific OU hierarchy

Company objects are grouped beneath:

```text
OU=Engineering Company
```

This provides a clean administrative boundary for the laboratory without modifying the default AD containers.

### Groups instead of department-specific user OUs

Users are kept in one OU because the current environment is intentionally small.

Functional separation is provided through:

```text
GG-Engineering
GG-IT
GG-Management
```

This keeps authorization independent from the physical location of the user object.

### Dedicated OUs for policy targets

Workstations, servers, groups, and service accounts have dedicated OUs so that future policies and administrative operations can target appropriate object classes.

### Single Domain Controller

The laboratory intentionally operates with one DC.

This simplifies the environment while allowing the core AD concepts to be demonstrated.

The trade-off is that the environment has:

```text
No Domain Controller redundancy
No AD replication between DCs
No automatic DC failover
```

A production environment would normally require additional Domain Controllers and appropriate redundancy planning.

---

## Verification

The Active Directory architecture was verified through:

```text
Get-ADDomain
Get-ADDomainController
Get-ADOrganizationalUnit
Get-ADUser
Get-ADGroup
Get-ADGroupMember
```

Domain-controller discovery was verified using:

```text
nltest /dsgetdc:engineering.local
```

DNS service discovery was verified using:

```text
Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV
```

Domain authentication and resource access were subsequently verified from `WIN01`.

The final Phase 3 troubleshooting pass confirmed:

```text
Domain authentication       OK
DNS / DHCP                   OK
GPO application              OK
User / group membership     OK
SMB access                   OK
SMB write access             OK
Outstanding failures        NONE
```

---

## Operational Considerations

The current architecture is intentionally designed as a learning laboratory rather than a production-ready Active Directory deployment.

Important limitations include:

* single Domain Controller
* single AD forest/domain
* `.local` internal namespace
* simplified password policy
* no secondary DNS/DC
* no dedicated management tier
* no production PKI
* no AD-integrated monitoring solution
* no production backup/restore strategy for AD DS

These limitations are deliberate and should be considered when extending the laboratory.

Future phases can build on this architecture by introducing additional domain clients, server workloads, stronger security policies, monitoring, automation, and recovery procedures.
