# Infrastructure Services

## Overview

The Engineering Company laboratory provides a centralized set of infrastructure services for domain identity, name resolution, network configuration, file access, and remote administration.

The primary infrastructure services are hosted on `DC01`.

```text
                         Internet
                            |
                     libvirt NAT
                      192.168.100.1
                            |
                  engineering-lab
                  192.168.100.0/24
                            |
                         DC01
                   192.168.100.20
                            |
        +-------------------+-------------------+
        |                   |                   |
       AD DS               DNS                DHCP
        |                   |                   |
        +-------------------+-------------------+
                            |
                         SMB
                            |
                         WIN01
                   192.168.100.30
```

Current infrastructure services:

```text
DC01
 |
 +-- Active Directory Domain Services
 +-- DNS Server
 +-- DHCP Server
 +-- SMB / File Services
 +-- Group Policy
 +-- WinRM
 +-- Global Catalog
```

---

## Service Inventory

| Service                          | Host                  | Address / Endpoint  | Purpose                                               | Status      |
| -------------------------------- | --------------------- | ------------------- | ----------------------------------------------------- | ----------- |
| Active Directory Domain Services | DC01                  | `192.168.100.20`    | Identity, authentication, directory services          | Operational |
| DNS Server                       | DC01                  | `192.168.100.20:53` | Internal DNS and AD service discovery                 | Operational |
| DHCP Server                      | DC01                  | `192.168.100.20`    | Client IP configuration                               | Operational |
| SMB                              | DC01                  | TCP/445             | Network file shares                                   | Operational |
| Global Catalog                   | DC01                  | TCP/3268            | Forest-wide directory searches/authentication support | Operational |
| WinRM                            | DC01                  | TCP/5985            | Remote Windows administration                         | Operational |
| Group Policy                     | DC01 + domain clients | SYSVOL / LDAP / SMB | Centralized configuration management                  | Operational |

---

# Active Directory Domain Services

## Purpose

Active Directory Domain Services provides the centralized identity and directory infrastructure for the laboratory.

AD DS is responsible for:

* user accounts
* computer accounts
* security groups
* domain membership
* authentication
* directory object management
* domain-controller discovery
* Group Policy infrastructure

The Active Directory domain is:

```text
engineering.local
```

The Domain Controller is:

```text
DC01.engineering.local
192.168.100.20
```

---

## Service

```text
Service:
    Active Directory Domain Services

Windows service:
    NTDS

Host:
    DC01

Status:
    Running

Startup:
    Automatic
```

DC01 is a writable Domain Controller and currently holds all FSMO roles.

The Global Catalog is enabled.

---

## Dependencies

AD DS depends heavily on DNS for service discovery.

```text
AD DS
 |
 +-- DNS
 |
 +-- Network connectivity
 |
 +-- Windows Time
```

Correct DNS configuration is therefore a prerequisite for reliable domain operation.

---

## Verification

The service was verified with:

```powershell
Get-Service NTDS
```

Domain functionality was verified with:

```powershell
Get-ADDomain
Get-ADDomainController
```

Domain-controller discovery was verified using:

```powershell
nltest /dsgetdc:engineering.local
```

---

# DNS Server

## Purpose

DNS provides name resolution for both the internal Active Directory namespace and external DNS queries.

DC01 acts as the DNS server for domain clients.

```text
DNS server:
    DC01
    192.168.100.20
```

Domain clients are configured to use DC01 rather than the external gateway directly.

---

## Internal DNS

The following AD-integrated zones are present:

```text
engineering.local
_msdcs.engineering.local
DomainDnsZones.engineering.local
ForestDnsZones.engineering.local
```

DNS contains records required for Active Directory service discovery.

Example:

```text
_ldap._tcp.dc._msdcs.engineering.local
        |
        v
dc01.engineering.local
        |
        v
192.168.100.20
```

---

## External DNS Forwarding

Queries for external names are forwarded through the laboratory gateway:

```text
Client
  |
  v
DC01 DNS
  |
  v
192.168.100.1
  |
  v
External DNS / Internet
```

The configured forwarder is:

```text
192.168.100.1
```

This allows clients to use DC01 as their single DNS resolver while still resolving external names.

---

## Ports

```text
UDP/53
TCP/53
```

Both protocols are relevant to normal DNS operation.

---

## Verification

DNS zones:

```powershell
Get-DnsServerZone
```

DNS forwarders:

```powershell
Get-DnsServerForwarder
```

DC01 DNS configuration:

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

Internal resolution:

```powershell
Resolve-DnsName DC01.engineering.local
Resolve-DnsName engineering.local
```

AD service discovery:

```powershell
Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV
```

External resolution through DC01:

```powershell
Resolve-DnsName google.com -Server 192.168.100.20
```

---

# DHCP Server

## Purpose

DC01 provides DHCP services for domain clients on the laboratory network.

The DHCP service assigns:

* IPv4 addresses
* default gateway
* DNS server
* DNS search/domain information

---

## Service

```text
Service:
    DHCP Server

Windows service:
    DHCPServer

Host:
    DC01

Address:
    192.168.100.20

Status:
    Running

Startup:
    Automatic
```

The DHCP server is authorized in Active Directory.

---

## Scope

```text
Scope:
    Engineering Lab

Network:
    192.168.100.0/24

Dynamic range:
    192.168.100.50 - 192.168.100.100

Lease duration:
    8 days
```

Reserved addresses:

```text
192.168.100.30
    WIN01
```

Infrastructure addresses remain static:

```text
192.168.100.1
    libvirt gateway

192.168.100.20
    DC01

MINT01
    static
```

---

## DHCP Options

Clients receive:

```text
Default gateway:
    192.168.100.1

DNS server:
    192.168.100.20

DNS domain:
    engineering.local
```

This ensures that domain clients automatically use the correct AD DNS server.

---

## DHCP Architecture

```text
                    DC01
               192.168.100.20
                      |
                 DHCP Server
                      |
             +--------+--------+
             |                 |
          WIN01            Future clients
        reserved .30       dynamic .50-.100
```

The previous libvirt DHCP service was removed from the laboratory network.

Libvirt continues to provide NAT and gateway functionality but does not provide client DHCP leases.

This prevents competing DHCP servers from operating on the same network.

---

## Verification

DHCP authorization:

```powershell
Get-DhcpServerInDC
```

DHCP scope:

```powershell
Get-DhcpServerv4Scope
```

Scope options:

```powershell
Get-DhcpServerv4OptionValue `
    -ScopeId 192.168.100.0
```

Reservations:

```powershell
Get-DhcpServerv4Reservation `
    -ScopeId 192.168.100.0
```

Client-side DHCP configuration was verified on WIN01.

Expected result:

```text
IPv4:
    192.168.100.30

DHCP server:
    192.168.100.20

DNS:
    192.168.100.20

Gateway:
    192.168.100.1
```

---

# SMB / File Services

## Purpose

SMB provides centralized network file access for company resources.

The shares are hosted directly on DC01 for this laboratory environment.

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

---

## Company Shares

| Share       | Local Path                   | Primary Access Group |
| ----------- | ---------------------------- | -------------------- |
| Engineering | `C:\CompanyData\Engineering` | `GG-Engineering`     |
| IT          | `C:\CompanyData\IT`          | `GG-IT`              |
| Management  | `C:\CompanyData\Management`  | `GG-Management`      |

IT administrators have elevated access to all three company resources.

---

## Access Model

SMB access is controlled through the combination of:

```text
SMB Share Permissions
        +
NTFS Permissions
```

The intended access model is:

```text
Resource                  GG-Engineering    GG-IT          GG-Management
---------------------------------------------------------------------------
Engineering               Modify            Full Control   No Access
IT                        No Access         Full Control   No Access
Management                No Access         Full Control   Modify
```

Users do not receive direct resource ACL entries.

Instead:

```text
User
 |
 v
AD Security Group
 |
 v
Resource permissions
```

This keeps authorization centralized in Active Directory security groups.

---

## SMB Port

```text
TCP/445
```

---

## Verification

Shares:

```powershell
Get-SmbShare
```

Connectivity:

```powershell
Test-Path "\\DC01\IT"
Test-Path "\\DC01\Engineering"
Test-Path "\\DC01\Management"
```

User identity:

```powershell
whoami
```

Group membership:

```powershell
whoami /groups
```

Write access was also tested by creating and removing temporary files on each share.

---

# Global Catalog

## Purpose

DC01 operates as a Global Catalog server.

The Global Catalog provides a partial replica of objects across the forest and supports forest-wide directory searches and authentication-related operations.

Current configuration:

```text
Global Catalog:
    Enabled

Server:
    DC01.engineering.local
```

Because the laboratory contains only one domain and one Domain Controller, there is currently only one Global Catalog.

---

## Ports

```text
TCP/3268
TCP/3269
```

The laboratory does not currently implement a dedicated secure Global Catalog deployment.

---

# Group Policy

## Purpose

Group Policy provides centralized configuration for domain users and computers.

The current environment contains:

```text
Default Domain Policy
Default Domain Controllers Policy
Engineering Domain Baseline
Engineering Workstation Baseline
Engineering User Baseline
```

---

## Policy Targets

```text
engineering.local
    |
    +-- Engineering Domain Baseline
    |      |
    |      +-- Password policy
    |      +-- Account lockout policy
    |
    +-- OU=Engineering Company
           |
           +-- Users
           |      |
           |      +-- Engineering User Baseline
           |
           +-- Workstations
                  |
                  +-- Engineering Workstation Baseline
```

The workstation baseline enables Windows Defender Firewall.

The user baseline applies the initial user-interface restrictions defined for the laboratory.

---

## GPO Dependencies

Group Policy processing depends on several infrastructure services:

```text
Group Policy
 |
 +-- Active Directory
 |
 +-- DNS
 |
 +-- LDAP
 |
 +-- SMB / SYSVOL
 |
 +-- NETLOGON
```

A domain client must be able to locate the appropriate Domain Controller and access the required policy files.

---

## Verification

GPO inventory:

```powershell
Get-GPO -All |
    Select-Object DisplayName, Id, GpoStatus
```

Domain inheritance:

```powershell
Get-GPInheritance `
    -Target "DC=engineering,DC=local"
```

Workstation inheritance:

```powershell
Get-GPInheritance `
    -Target "OU=Workstations,OU=Engineering Company,DC=engineering,DC=local"
```

User inheritance:

```powershell
Get-GPInheritance `
    -Target "OU=Users,OU=Engineering Company,DC=engineering,DC=local"
```

GPO reports were exported to XML and inspected during Phase 3 verification.

---

# WinRM

## Purpose

Windows Remote Management provides remote administration of Windows systems.

DC01 has WinRM enabled and configured.

```text
Host:
    DC01

Protocol:
    WS-Man

Port:
    TCP/5985

Transport:
    HTTP
```

The listener is bound to:

```text
192.168.100.20
```

---

## Service

```text
Service:
    WinRM

Status:
    Running

Startup:
    Automatic
```

WinRM is intended for administrative access rather than application traffic.

---

## Verification

Service status:

```powershell
Get-Service WinRM
```

Configuration:

```powershell
winrm quickconfig
```

Listener:

```powershell
winrm enumerate winrm/config/listener
```

WS-Man connectivity:

```powershell
Test-WSMan localhost
```

The local WS-Man test completed successfully.

---

# Windows Time

## Purpose

Windows Time is an important supporting service for the Active Directory environment.

Kerberos authentication is sensitive to clock differences between domain members and Domain Controllers.

DC01 uses the Active Directory domain time hierarchy.

Current laboratory state:

```text
W32Time:
    Running

Startup:
    Automatic

Domain configuration:
    NT5DS

Lab time source:
    Local CMOS Clock
```

The laboratory does not currently implement a dedicated external time hierarchy.

This is acceptable for the isolated learning environment but is not intended to represent a production time architecture.

---

## Verification

Service:

```powershell
Get-Service W32Time
```

Synchronization status:

```powershell
w32tm /query /status
```

Configuration:

```powershell
w32tm /query /configuration
```

Current system time:

```powershell
Get-Date
```

---

# Service Dependencies

The infrastructure services form several important dependency chains.

## Domain Authentication

```text
WIN01
 |
 v
DNS
 |
 v
DC01
 |
 +-- AD DS
 |
 +-- Kerberos
 |
 +-- LDAP
 |
 v
User authentication
```

---

## Domain Client Configuration

```text
WIN01
 |
 v
DHCP
 |
 +-- IP address
 +-- Gateway
 +-- DNS server
 +-- DNS domain
 |
 v
DC01 DNS
 |
 v
AD domain discovery
```

---

## Group Policy

```text
WIN01
 |
 v
DNS
 |
 v
Domain Controller discovery
 |
 v
DC01
 |
 +-- LDAP
 +-- SMB / SYSVOL
 +-- NETLOGON
 |
 v
Group Policy processing
```

---

## SMB Authorization

```text
WIN01
 |
 v
Domain authentication
 |
 v
Active Directory
 |
 v
User group membership
 |
 v
SMB share
 |
 v
NTFS + Share permissions
 |
 v
Resource access
```

---

# Network Service Summary

```text
Service / Protocol          Port
--------------------------------
DNS                         UDP/53
DNS                         TCP/53
LDAP                        TCP/389
Kerberos                    TCP/UDP/88
SMB                         TCP/445
Global Catalog              TCP/3268
Secure Global Catalog       TCP/3269
WinRM                       TCP/5985
```

These ports represent the primary services relevant to the current laboratory architecture.

Additional dynamic RPC and related Windows ports may be required for certain Active Directory operations, replication, management, or remote administration scenarios.

---

# Operational Verification

The Phase 3 service baseline verified the following:

```text
Active Directory Services
    [OK] NTDS running
    [OK] Domain operational
    [OK] Domain Controller recognized
    [OK] Global Catalog enabled

DNS
    [OK] DNS service running
    [OK] Internal zones available
    [OK] AD SRV records available
    [OK] External forwarding operational

DHCP
    [OK] DHCP service running
    [OK] Server authorized
    [OK] Scope active
    [OK] WIN01 reservation operational

SMB
    [OK] Company shares available
    [OK] Share permissions configured
    [OK] NTFS permissions configured
    [OK] Read access verified
    [OK] Write access verified

Group Policy
    [OK] Domain baseline
    [OK] Workstation baseline
    [OK] User baseline
    [OK] GPO inheritance verified

WinRM
    [OK] Service running
    [OK] Listener active
    [OK] WS-Man verified

Windows Time
    [OK] Service running
    [OK] Domain time configuration present
    [OK] Current time verified
```

---

# Service Architecture Summary

```text
                         Internet
                            |
                     libvirt NAT
                     192.168.100.1
                            |
                 engineering-lab
                  192.168.100.0/24
                            |
             +--------------+--------------+
             |              |              |
           MINT01          DC01           WIN01
           static          .20             .30
                           |
                +----------+----------+
                |          |          |
               AD DS      DNS        DHCP
                |          |          |
                +----------+----------+
                           |
                          SMB
                           |
                    Company resources

DC01 additionally provides:

    +-- Global Catalog
    +-- Group Policy infrastructure
    +-- WinRM
    +-- Windows Time
```

The current architecture centralizes the core Windows infrastructure services on `DC01`, which keeps the laboratory simple while demonstrating the relationships between Active Directory, DNS, DHCP, Group Policy, authentication, and SMB resource access.

For production use, these services would typically be evaluated separately for redundancy, security, scalability, and failure-domain isolation.
