# Engineering Company IT Lab

## 1. Purpose

The Engineering Company IT Lab is a hands-on infrastructure
laboratory representing a small international engineering company.

The lab is designed to practice:

* IT administration
* virtualization
* networking
* Windows administration
* Active Directory
* ITSM
* cloud infrastructure
* Infrastructure as Code
* automation
* monitoring
* security
* troubleshooting
* documentation

The environment is intentionally modular.

New components are introduced only when they provide a real
learning or architectural purpose.

The architecture evolves incrementally as new infrastructure
capabilities are implemented and verified.

## 2. High-Level Architecture

The laboratory consists of several logical areas:

```
ENGINEERING COMPANY IT LAB
|
+-- On-Premises Infrastructure
|   +-- Virtualization
|   +-- Networking
|   +-- Windows Server
|   +-- Active Directory
|   +-- DNS
|   +-- DHCP
|   +-- Windows Clients
|   +-- File Services
|
+-- ITSM
|   +-- Tickets
|   +-- Incidents
|   +-- Assets
|   +-- Software
|   +-- Licenses
|
+-- Cloud
|   +-- Floci
|       +-- S3
|       +-- SQS
|       +-- Lambda
|       +-- RDS
|       +-- Secrets Manager
|       +-- IAM
|
+-- Infrastructure as Code
|   +-- Terraform
|
+-- Automation
|   +-- PowerShell
|   +-- Bash
|   +-- Python
|
+-- CI/CD
|   +-- GitHub Actions
|
+-- Monitoring
|
+-- Security
```

## 3. Host and Virtualization

The laboratory is hosted on a physical machine running
Arch Linux.

```
HOST
|
+-- Arch Linux
    |
    +-- QEMU/KVM
        |
        +-- libvirt
            |
            +-- virt-manager
                |
                +-- Virtual Machines
```

The host provides the virtualization and management
environment.

The simulated company infrastructure exists inside
the virtual machines.

The host itself is not part of the simulated company
infrastructure.

Current host resources:

```
Operating System:  Arch Linux
RAM:              16 GB
Swap:             16 GB
Virtualization:   QEMU/KVM
VM Management:    libvirt / virt-manager
libvirt URI:      qemu:///system
```

## 4. Laboratory Network

The primary laboratory network is:

```
engineering-lab
192.168.100.0/24
```

The network is implemented as a libvirt NAT network.

libvirt provides the underlying virtual network, default gateway,
and outbound NAT functionality.

Windows infrastructure services are provided by DC01.

```
engineering-lab
192.168.100.0/24
        |
        +-----------------+-----------------+
        |                 |                 |
        v                 v                 v
     MINT01             DC01              WIN01
  192.168.100.10    192.168.100.20    192.168.100.30
    static             static          DHCP reservation
                          |
                +---------+---------+
                |         |         |
                v         v         v
               AD        DNS      DHCP
```

Network parameters:

```
Network:        engineering-lab
Type:           NAT
Subnet:         192.168.100.0/24
Gateway:        192.168.100.1

DHCP server:
    DC01
    192.168.100.20

DHCP range:
    192.168.100.50 - 192.168.100.100

Internal DNS:
    DC01
    192.168.100.20

Internal DNS domain:
    engineering.local
```

Core machine addressing:

```
MINT01    192.168.100.10    static
DC01      192.168.100.20    static
WIN01     192.168.100.30    DHCP reservation
```

The libvirt network no longer provides DHCP.

DHCP responsibility was migrated from libvirt to DC01 during
the Windows / Active Directory phase.

libvirt continues to provide the virtual network, gateway,
and NAT for outbound Internet connectivity.

The network configuration is maintained in:

```
networking/configs/engineering-lab.xml
```

Additional virtual machines can be connected to the same
network without redesigning the base topology.

## 5. Virtual Machines

The current architecture contains three core virtual machines:

```
MINT01
    Linux Mint
    IT Administration Workstation

DC01
    Windows Server 2025 Standard
    Active Directory Domain Controller
    DNS Server
    DHCP Server

WIN01
    Windows 10/11
    Domain-Joined Employee Workstation
```

Their roles are intentionally separated.

### MINT01

MINT01 represents the IT administrator's workstation.

It is used for:

* infrastructure administration
* SSH
* PowerShell
* Bash
* Git
* Terraform
* network troubleshooting
* documentation
* repository management
* Windows infrastructure administration
* Active Directory administration

Current state:

```
Status:       Operational
IP:           192.168.100.10
Networking:   Static addressing
```

MINT01 uses DC01 for internal DNS:

```
DNS:
    192.168.100.20
```

### DC01

DC01 represents the core Windows infrastructure.

Current state:

```
Status:       Operational
IP:           192.168.100.20
Hostname:     DC01
OS:           Windows Server 2025 Standard
Domain:       engineering.local
```

DC01 is the Active Directory Domain Controller for the
laboratory environment.

Implemented services:

* Active Directory Domain Services
* Active Directory-integrated DNS
* DHCP Server

The Active Directory domain is:

```
engineering.local
```

DC01 provides internal DNS for the Active Directory namespace
and provides DHCP configuration to domain clients.

The DHCP scope is:

```
Network:
    192.168.100.0/24

Dynamic range:
    192.168.100.50 - 192.168.100.100

Default gateway:
    192.168.100.1

DNS server:
    192.168.100.20

DNS domain:
    engineering.local
```

The Windows client WIN01 receives its reserved address
192.168.100.30 from the DC01 DHCP service.

DC01 therefore acts as the central Windows infrastructure
dependency for the laboratory.

### WIN01

WIN01 represents an employee workstation.

Current state:

```
Status:       Operational
IP:           192.168.100.30
Hostname:     WIN01
Addressing:   DHCP reservation
Domain:       engineering.local
```

WIN01 is joined to the Active Directory domain:

```
engineering.local
```

The computer object is maintained under:

```
OU=Workstations,OU=Engineering Company
```

WIN01 uses DC01 for:

* DNS
* Active Directory authentication
* domain controller discovery
* DHCP

Its network configuration is:

```
IP:
    192.168.100.30

Gateway:
    192.168.100.1

DHCP:
    192.168.100.20

DNS:
    192.168.100.20
```

The DHCP reservation is associated with:

```
MAC:
    52:54:00:CD:78:97
```

## 6. Core Infrastructure Relationships

The current Phase 3 infrastructure is:

```
ARCH LINUX HOST
        |
    QEMU / KVM
        |
     libvirt
        |
 engineering-lab
192.168.100.0/24
        |
+-------+-------+-------+
|               |       |
v               v       v
```

MINT01           DC01    WIN01
.100.10          .100.20 .100.30
static            static  DHCP reservation
|
+---------+---------+
|         |         |
v         v         v
AD        DNS      DHCP
|
v
engineering.local
|
v
Domain-joined clients

The network service responsibilities are intentionally separated:

```
libvirt
    |
    +-- Layer 2 virtual networking
    +-- Gateway 192.168.100.1
    +-- NAT
    |
    X-- DHCP
    X-- Active Directory DNS


DC01
    |
    +-- Active Directory
    +-- Internal DNS
    +-- DHCP
    +-- Domain authentication
```

This separation prevents competing DHCP services and establishes
DC01 as the central Windows infrastructure server.

Current infrastructure state:

```
Virtualization       DONE
Base networking      DONE
MINT01               OPERATIONAL
DC01                 OPERATIONAL
WIN01                OPERATIONAL

Active Directory     IMPLEMENTED
Internal DNS         IMPLEMENTED
DHCP Server          IMPLEMENTED
Domain               IMPLEMENTED
Domain Join          IMPLEMENTED
Group Policy         FOUNDATIONAL STRUCTURE IMPLEMENTED

ITSM                 NOT IMPLEMENTED
Terraform            NOT IMPLEMENTED
Automation           NOT IMPLEMENTED
CI/CD                NOT IMPLEMENTED
Monitoring           NOT IMPLEMENTED
```

## 7. Cloud

The project uses Floci as the local cloud laboratory.

The cloud architecture is based on AWS-style concepts.

The implemented cloud environment includes:

```
IAM
S3
SQS
Lambda
RDS
Secrets Manager
Logging
```

The primary implemented scenario is an engineering document
workflow:

```
Application
    |
    v
   S3
    |
    v
   SQS
    |
    v
  Lambda
    |
    +----> Secrets Manager
    |
    +----> RDS PostgreSQL
    |
    +----> Logging
```

The cloud workflow has been implemented and verified.

Cloud infrastructure is therefore part of the current
laboratory architecture rather than a future planned component.

## 8. Infrastructure as Code and Automation

Terraform provides the Infrastructure as Code layer.

```
Terraform
    |
    +-- Cloud Infrastructure
```

Automation is provided by:

```
PowerShell
Bash
Python
```

GitHub Actions provides CI/CD automation for repository
and infrastructure workflows.

These components remain planned or are under development
and are introduced after the underlying infrastructure
concepts have been understood.

## 9. Security and Troubleshooting

Security is treated as a cross-cutting concern rather than
a standalone final component.

The architecture applies principles such as:

* least privilege
* authentication
* authorization
* secure secrets management
* access control
* auditing
* patch management

Active Directory security is based on:

```
Users
    |
    v
Security Groups
    |
    v
Resource Permissions
```

Administrative access is separated from ordinary user access
where appropriate.

The laboratory also uses organizational units to provide
logical separation of users, workstations, and servers and to
support targeted Group Policy configuration.

Troubleshooting is a core part of the laboratory.

Infrastructure should not only be implemented and operated
in a working state.

Controlled failures and real implementation problems are
documented as troubleshooting cases.

```
Incident / Failure
        |
        v
  Investigation
        |
        v
     Root Cause
        |
        v
        Fix
        |
        v
   Verification
        |
        v
   Documentation
```

Troubleshooting cases are stored under:

```
docs/incidents/troubleshooting/
```

Existing troubleshooting cases include:

```
TRB-001
    libvirt / engineering-lab network definition issue

TRB-002
    libvirt network runtime / DHCP configuration issue

TRB-003
    Windows ICMP firewall configuration
```

TRB-003 demonstrated that Windows machines could communicate
with the Linux workstation and gateway but initially could not
exchange ICMP traffic with each other because inbound ICMP
traffic was blocked by the Windows firewall.

After allowing ICMP traffic on both Windows machines,
bidirectional connectivity was verified.

Phase 3 additionally introduced Active Directory and DNS
troubleshooting procedures, including verification of:

```
engineering.local
DC01.engineering.local
_ldap._tcp.dc._msdcs.engineering.local
```

and domain controller discovery through:

```
nltest /dsgetdc:engineering.local
```

## 10. Documentation

Documentation is a first-class component of the laboratory.

The documentation should describe:

* architecture
* infrastructure
* procedures
* troubleshooting
* incidents
* cloud services
* security
* disaster recovery
* future extensions

The documentation structure is designed to evolve together
with the infrastructure.

Documentation follows this principle:

```
Architecture
    =
what the system is and why it is designed this way

Infrastructure
    =
what is actually deployed

Procedures
    =
how to perform administrative tasks

Incidents / Troubleshooting
    =
failures, investigation and root cause
```

## 11. Historical Phase 0 Completion State

Phase 0 established the foundation of the laboratory.

The completed Phase 0 foundation was:

```
Repository
    |
    +-- Documentation structure
    |
    +-- Architecture documentation
    |
    +-- Git workflow
    |
    +-- Virtualization
    |
    +-- libvirt system management
    |
    +-- engineering-lab network
    |
    +-- MINT01
    |
    +-- DC01
    |
    +-- WIN01
    |
    +-- DHCP reservations
    |
    +-- VM networking verification
    |
    +-- Baseline snapshots
    |
    +-- Troubleshooting documentation
```

At the end of Phase 0:

```
Active Directory     NOT IMPLEMENTED
Internal DNS         NOT IMPLEMENTED
DHCP Server          NOT IMPLEMENTED
Domain               NOT IMPLEMENTED
Domain Join          NOT IMPLEMENTED
```

These statements describe the historical Phase 0 state only.

The current architecture is described in the sections above.

## 12. Design Principles

The laboratory follows several core principles:

```
REALISM OVER COMPLEXITY

UNDERSTANDING OVER COMMAND MEMORIZATION

SCENARIOS OVER ISOLATED TECHNOLOGIES

TROUBLESHOOTING AS A FIRST-CLASS SKILL

SECURITY FROM THE BEGINNING

DOCUMENT IMPORTANT DECISIONS

AUTOMATE AFTER UNDERSTANDING

KEEP THE LAB REPRODUCIBLE

AVOID UNNECESSARY COST

DO NOT OVERBUILD THE ENVIRONMENT
```

Every major component should have a reason to exist.

The goal is not to build the largest possible infrastructure.

The goal is to build a coherent environment that can be
understood, administered, troubleshot and documented.

The architecture should evolve through verified implementation
rather than speculative complexity.

```
```
