# Virtual Machines

## 1. Overview

The Engineering Company IT Lab runs on:

- Arch Linux host
- QEMU/KVM
- libvirt
- virt-manager

The simulated company infrastructure runs inside virtual machines.

The physical host and virtualization management layer are considered
supporting infrastructure and are not part of the simulated company
environment.

The current VM environment represents the verified Phase 3 state,
including Active Directory, internal DNS, DHCP, and domain-joined
Windows infrastructure.


## 2. Current Virtual Machines

| VM | OS | Role | IP | Addressing | Status |
|---|---|---|---|---|---|
| MINT01 | Linux Mint | IT Administration Workstation | `192.168.100.10` | Static | Operational |
| DC01 | Windows Server 2025 Standard | Domain Controller / DNS / DHCP | `192.168.100.20` | Static | Operational |
| WIN01 | Windows 10/11 | Domain-Joined Employee Workstation | `192.168.100.30` | DHCP reservation | Operational |


## 3. MINT01

### Role

IT Administration Workstation.

### Responsibilities

- Infrastructure administration
- SSH
- Bash
- PowerShell
- Git
- GitHub CLI
- Terraform
- Network troubleshooting
- Windows infrastructure administration
- Active Directory administration
- Documentation

### Network

```text
Network:   engineering-lab
IP:        192.168.100.10/24
Gateway:   192.168.100.1
Method:    Static
````

MINT01 uses static addressing as part of the laboratory
infrastructure addressing model.

MINT01 remains connected to the same Layer 2 laboratory network
as DC01 and WIN01.

### DNS

MINT01 uses DC01 as its internal DNS server:

```text
DNS:       192.168.100.20
Domain:    engineering.local
```

This allows MINT01 to resolve internal Active Directory DNS records
as well as external domains through the DNS service running on DC01.

## 4. DC01

### Role

Primary Windows infrastructure server and Active Directory
Domain Controller.

### Operating System

`Windows Server 2025 Standard`

### Hostname

`DC01`

### Domain

```text
engineering.local
```

### Network

```text
Network:   engineering-lab
IP:        192.168.100.20/24
Gateway:   192.168.100.1
Method:    Static
```

DC01 uses a static IP address because it provides infrastructure
services required by other hosts.

### Implemented Services

DC01 currently provides:

* Active Directory Domain Services
* Active Directory-integrated DNS
* DHCP Server

The server is authorized as a DHCP server in Active Directory.

### Active Directory

The Active Directory domain is:

```text
engineering.local
```

The domain structure includes the organizational units required
by the laboratory environment, including:

```text
OU=Engineering Company
    |
    +-- Users
    |
    +-- Workstations
    |
    +-- Servers
```

DC01 provides domain authentication and directory services for
the laboratory environment.

### DNS

DC01 provides authoritative internal DNS for:

```text
engineering.local
```

Active Directory service discovery records are also provided
through the AD-integrated DNS service.

Examples include:

```text
engineering.local
DC01.engineering.local
_ldap._tcp.dc._msdcs.engineering.local
```

DC01 also performs external DNS resolution for clients using
its configured forwarding/resolution path.

### DHCP

DC01 provides DHCP for the laboratory network.

Scope:

```text
Scope name:       Engineering Lab
Network:          192.168.100.0/24
Dynamic range:    192.168.100.50 - 192.168.100.100
Lease duration:   8 days
```

DHCP options include:

```text
Default gateway:  192.168.100.1
DNS server:       192.168.100.20
DNS domain:       engineering.local
```

WIN01 receives its reserved address through the DC01 DHCP server:

```text
WIN01
    MAC: 52-54-00-CD-78-97
    IP:  192.168.100.30
```

### DHCP / Libvirt Boundary

DHCP responsibility was migrated from libvirt to DC01.

The libvirt `engineering-lab` network no longer provides:

* DHCP service
* DHCP reservations
* DHCP address ranges

libvirt continues to provide:

* virtual Layer 2 connectivity
* `192.168.100.1` gateway
* NAT for outbound Internet connectivity

There is therefore a single DHCP server on the laboratory network:

```text
DC01
192.168.100.20
```

This prevents competing DHCP services from operating on the
same network.

## 5. WIN01

### Role

Domain-joined employee workstation.

### Operating System

`Windows 10/11`

### Hostname

`WIN01`

### Network

```text
Network:   engineering-lab
IP:        192.168.100.30/24
Method:    DHCP reservation
Gateway:   192.168.100.1
DHCP:      192.168.100.20
DNS:       192.168.100.20
Domain:    engineering.local
```

WIN01 receives its IP configuration from the DHCP service running
on DC01.

The reservation is based on the VM network interface MAC address:

```text
MAC: 52-54-00-CD-78-97
IP:  192.168.100.30
```

### Domain Membership

WIN01 is joined to:

```text
engineering.local
```

The computer object is maintained under:

```text
OU=Workstations,OU=Engineering Company
```

This placement allows workstation-specific Group Policy and
administrative controls to be targeted through the corresponding
organizational unit.

### DNS Dependency

WIN01 must use DC01 for DNS:

```text
WIN01
   |
   +-- DNS -> 192.168.100.20
   |
   v
  DC01
```

Using an external DNS server directly would bypass the
Active Directory DNS namespace and can prevent correct domain
controller discovery.

## 6. VM Networking

All three core VMs connect to the libvirt network:

```text
engineering-lab
192.168.100.0/24
```

The network remains a single Layer 2 / IPv4 segment.

Current topology:

```text
                           Internet
                              |
                              v
                    +-------------------+
                    | libvirt NAT       |
                    | gateway           |
                    | 192.168.100.1     |
                    +---------+---------+
                              |
                              |
                    engineering-lab
                    192.168.100.0/24
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
          MINT01            DC01             WIN01
        .100.10            .100.20           .100.30
          static             static          DHCP reservation
                              |
                    +---------+---------+
                    |                   |
                    v                   v
                   DNS                 DHCP
                    |                   |
                    +---------+---------+
                              |
                    engineering.local
```

The important service boundary is:

```text
libvirt
    |
    +-- Layer 2 connectivity
    +-- Gateway 192.168.100.1
    +-- NAT
    |
    X-- DHCP
    X-- Active Directory DNS


DC01
    |
    +-- Active Directory
    +-- DNS
    +-- DHCP
```

This separation allows the virtualization layer to provide basic
network transport while Windows infrastructure provides the
company network services.

## 7. Addressing Model

The current laboratory addressing model is:

```text
192.168.100.0/24
```

Infrastructure addresses:

```text
192.168.100.1     libvirt NAT gateway
192.168.100.10    MINT01
192.168.100.20    DC01
192.168.100.30    WIN01 DHCP reservation
```

DHCP dynamic pool:

```text
192.168.100.50 - 192.168.100.100
```

The `.30` address is reserved for WIN01 but is not part of the
dynamic pool.

This provides predictable addressing for core infrastructure
while retaining a dedicated dynamic range for future domain
clients.

## 8. Current VM Service Dependencies

The main service dependencies are:

```text
WIN01
   |
   +-- DHCP --------> DC01
   |
   +-- DNS ---------> DC01
   |
   +-- AD ----------> DC01
   |
   +-- Gateway ------> 192.168.100.1


MINT01
   |
   +-- DNS ---------> DC01
   |
   +-- Gateway ------> 192.168.100.1


DC01
   |
   +-- Gateway ------> 192.168.100.1
   |
   +-- NAT ----------> External Network
```

DC01 therefore represents the central Windows infrastructure
dependency for the laboratory.

The libvirt gateway remains the network path for external
connectivity but is not an Active Directory infrastructure service.

## 9. Current State

The current VM environment provides:

```text
MINT01
    |
    +-- Administration workstation
    +-- Static IP
    +-- Internal DNS via DC01


DC01
    |
    +-- Active Directory Domain Services
    +-- Internal DNS
    +-- DHCP
    +-- Static IP


WIN01
    |
    +-- Domain-joined workstation
    +-- DHCP reservation
    +-- Internal DNS via DC01
    +-- Workstations OU placement
```

The virtual machine infrastructure is currently aligned with the
Phase 3 Windows / Active Directory architecture.

The network remains based on the original `engineering-lab`
libvirt network and `192.168.100.0/24` subnet, while DHCP and internal DNS responsibilities have been migrated to DC01.
