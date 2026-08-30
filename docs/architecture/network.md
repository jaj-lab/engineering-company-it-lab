# Engineering Lab Network Architecture

## PURPOSE

This document describes the current network architecture of the Engineering
Company IT Lab.

It defines the implemented network topology, IP addressing model, DHCP
architecture, routing, NAT, DNS behavior, and connectivity between
laboratory systems.

The document represents the current verified laboratory state.

Future networking functionality is documented only when it has been
implemented or explicitly identified as a planned dependency of a later
phase.

## NETWORK OVERVIEW

The laboratory uses a dedicated libvirt virtual network named:

```
engineering-lab
```

The network provides Layer 2 connectivity between the laboratory virtual
machines and provides outbound Internet access through libvirt NAT.

The laboratory uses a single IPv4 subnet:

```
Network:    192.168.100.0/24
Netmask:    255.255.255.0
Broadcast:  192.168.100.255
```

The libvirt network continues to provide the default gateway and NAT
functionality.

DHCP and internal DNS responsibilities have been migrated to DC01 as part
of the Windows / Active Directory phase.

The current topology is:

```
                        Internet
                           |
                           |
                   Host external network
                           |
                           |
                 +---------------------+
                 |  libvirt NAT        |
                 |  gateway            |
                 |  192.168.100.1      |
                 +----------+----------+
                            |
                            |
                 engineering-lab
                  192.168.100.0/24
                            |
          +-----------------+-----------------+
          |                 |                 |
          |                 |                 |
       MINT01             DC01              WIN01
       .10 static         .20 static         .30 DHCP
                          |
                   +------+------+
                   |             |
                  DNS           DHCP
                   |             |
                   +-------------+
                          |
                   engineering.local
```

All three laboratory VMs are connected to the same Layer 2 virtual network.

The network is currently flat. No VLANs or additional network segments are
implemented inside the lab.

## LIBVIRT NETWORK

The network is managed by libvirt.

Network name:

```
engineering-lab
```

Forwarding mode:

```
NAT
```

Virtual bridge:

```
engineering-lab
```

Gateway:

```
192.168.100.1/24
```

The libvirt network remains responsible for:

```
- Layer 2 virtual networking
- Default gateway functionality
- Outbound NAT
- External connectivity
```

The libvirt network is no longer responsible for DHCP.

The libvirt DHCP service was removed after DHCP responsibility was migrated
to DC01.

The network therefore has no competing DHCP server.

## IP ADDRESSING

The laboratory uses:

```
192.168.100.0/24
```

The addressing model separates static infrastructure addresses, DHCP
reservations, and the dynamic DHCP pool.

Static infrastructure:

```
192.168.100.1      libvirt NAT gateway
192.168.100.10     MINT01
192.168.100.20     DC01
```

DHCP reservation:

```
192.168.100.30     WIN01
```

Dynamic DHCP pool:

```
192.168.100.50 - 192.168.100.100
```

Future / infrastructure address space:

```
192.168.100.101 - 192.168.100.254
```

DC01 is configured with a static address because it provides critical
infrastructure services including Active Directory, DNS, and DHCP.

MINT01 uses static addressing.

WIN01 uses DHCP and receives its stable address through a DHCP reservation
configured on DC01.

## CURRENT VM NETWORK IDENTITIES

MINT01

```
Hostname:   MINT01
Address:    192.168.100.10/24
MAC:        52:54:00:c1:bb:a8
Addressing: Static
Role:       Linux workstation / administration host
```

DC01

```
Hostname:   DC01
Address:    192.168.100.20/24
MAC:        52:54:00:17:7d:e5
Addressing: Static
Role:       Windows Server / Domain Controller / DNS / DHCP
```

WIN01

```
Hostname:   WIN01
Address:    192.168.100.30/24
MAC:        52:54:00:cd:78:97
Addressing: DHCP reservation
Role:       Windows domain-joined client
```

## DHCP

DHCP is provided by the Windows DHCP Server service running on DC01.

DHCP server:

```
DC01.engineering.local
192.168.100.20
```

The DHCP server is authorized in Active Directory.

DHCP scope:

```
Scope name:       Engineering Lab
Network:          192.168.100.0/24
Dynamic range:    192.168.100.50 - 192.168.100.100
Scope state:      Active
Lease duration:   8 days
```

DHCP options:

```
Default gateway:  192.168.100.1
DNS server:       192.168.100.20
DNS domain:       engineering.local
```

DHCP reservation:

```
MAC:
    52:54:00:cd:78:97

Host:
    WIN01

Reserved address:
    192.168.100.30

Reservation type:
    Both
```

WIN01 therefore receives its stable address dynamically from DC01 DHCP:

```
WIN01
   |
   | DHCP
   v
DC01
   |
   v
192.168.100.30
```

The dynamic pool remains separated from infrastructure and reserved
addresses.

The DHCP pool:

```
192.168.100.50 - 192.168.100.100
```

is available for additional laboratory clients.

The previous libvirt DHCP service and static host reservations have been
removed.

## DHCP RESPONSIBILITY MIGRATION

DHCP responsibility was migrated from libvirt to DC01.

Previous architecture:

```
VM
 |
 v
libvirt DHCP
 |
 v
IP configuration
```

Current architecture:

```
VM
 |
 v
DC01 DHCP
 |
 +-- IP address
 +-- Default gateway
 +-- DNS server
 +-- DNS domain
```

The migration included:

```
- DHCP server installation on DC01
- DHCP authorization in Active Directory
- Engineering Lab scope creation
- DHCP options configuration
- WIN01 DHCP reservation
- Removal of libvirt DHCP
- Removal of libvirt DHCP reservations
- Verification of WIN01 DHCP configuration
```

No competing DHCP servers remain on the laboratory network.

## ROUTING

The laboratory VMs use:

```
Default gateway:
    192.168.100.1
```

The gateway is provided by the libvirt network.

DC01 DHCP distributes the gateway address to DHCP clients:

```
DHCP option 003:
    192.168.100.1
```

Traffic destined for the local:

```
192.168.100.0/24
```

network remains on the laboratory network.

Traffic destined for external networks is forwarded through the libvirt
gateway and NATed to the host's external network.

## NAT AND EXTERNAL CONNECTIVITY

The engineering-lab network uses libvirt NAT.

The laboratory VMs therefore do not require directly routable addresses on
the external network.

The traffic path is:

```
VM
 |
 v
192.168.100.1
 |
 v
libvirt NAT
 |
 v
Host external network
 |
 v
Internet
```

The libvirt gateway remains the boundary between the laboratory network and
the external network.

DC01 does not perform Internet NAT.

Outbound Internet connectivity remains provided by libvirt.

## DNS

DNS is provided by DC01.

DC01 hosts the DNS service used by the Active Directory domain:

```
engineering.local
```

DC01:

```
Hostname:
    DC01

Address:
    192.168.100.20

DNS role:
    Active Directory-integrated DNS
```

Laboratory clients use DC01 as their DNS server.

DHCP distributes the following DNS configuration to DHCP clients:

```
DNS server:
    192.168.100.20

DNS domain:
    engineering.local
```

The intended client DNS architecture is therefore:

```
WIN01
   |
   | DNS
   v
DC01
192.168.100.20
   |
   +-- engineering.local
   |
   +-- Active Directory DNS records
   |
   +-- external DNS resolution / forwarding
```

## ACTIVE DIRECTORY DNS

Active Directory depends on DNS for service discovery.

The laboratory therefore uses DC01 as the authoritative DNS server for the
internal Active Directory namespace.

Important records include:

```
DC01.engineering.local
```

and Active Directory service records such as:

```
_ldap._tcp.dc._msdcs.engineering.local
```

These records allow domain clients to discover the Domain Controller and
required Active Directory services.

The client DNS path is:

```
Client
   |
   v
DC01
   |
   +-- Internal AD DNS
   |
   +-- External DNS resolution
```

## DNS AND DHCP RELATIONSHIP

DHCP and DNS are both centralized on DC01.

The current relationship is:

```
DC01
  |
  +-- Active Directory
  |
  +-- DNS
  |
  +-- DHCP
         |
         +-- IP address
         +-- Gateway
         +-- DNS server
         +-- DNS domain
```

For WIN01, the resulting configuration is:

```
IPv4 address:
    192.168.100.30

Subnet mask:
    255.255.255.0

Default gateway:
    192.168.100.1

DHCP server:
    192.168.100.20

DNS server:
    192.168.100.20

DNS suffix:
    engineering.local
```

## INTERNAL CONNECTIVITY

All three laboratory VMs remain members of the same IPv4 subnet:

```
192.168.100.0/24
```

The network therefore provides direct Layer 2 / Layer 3 connectivity
between the laboratory hosts.

Verified infrastructure relationships include:

```
MINT01 -> DC01
MINT01 -> WIN01

DC01 -> MINT01
DC01 -> WIN01

WIN01 -> MINT01
WIN01 -> DC01
```

Domain-specific connectivity additionally depends on services provided by
DC01, including DNS and Active Directory.

## NETWORK SEGMENTATION

No internal network segmentation is currently implemented.

Current state:

```
One virtual network
One IPv4 subnet
One libvirt gateway
One NAT boundary
```

There are currently no:

```
VLANs
Separate server/client subnets
Dedicated management network
Dedicated DMZ
Inter-VLAN routing
```

This remains intentional for the current laboratory architecture.

Additional segmentation may be introduced in future phases if required by
the laboratory design.

## FIREWALL

No dedicated network firewall appliance is deployed inside the laboratory
network.

The libvirt gateway provides NAT and network forwarding but is not treated
as an internal security segmentation boundary.

Host and operating-system firewall controls are outside the primary scope of
this network architecture document.

Windows Firewall behavior may affect individual host connectivity and is
addressed through Windows infrastructure and troubleshooting procedures
where applicable.

## LIBVIRT DHCP MIGRATION

The migration from libvirt DHCP to DC01 DHCP is complete.

Previous state:

```
libvirt
   |
   +-- DHCP
   +-- DHCP reservations
   +-- NAT
   +-- Gateway
```

Current state:

```
libvirt
   |
   +-- NAT
   +-- Gateway

DC01
   |
   +-- DHCP
   +-- DHCP reservations
   +-- DNS
   +-- Active Directory
```

This separation reflects the current Windows / Active Directory
architecture.

libvirt continues to provide the network transport and external NAT
boundary, while DC01 provides the laboratory's domain infrastructure
services.

## CURRENT NETWORK STATE

The verified network state is:

```
Network:
    engineering-lab

Subnet:
    192.168.100.0/24

Netmask:
    255.255.255.0

Gateway:
    192.168.100.1

NAT:
    Enabled through libvirt

DHCP server:
    DC01
    192.168.100.20

DHCP pool:
    192.168.100.50 - 192.168.100.100

DHCP reservation:
    WIN01 -> 192.168.100.30

DNS server:
    DC01
    192.168.100.20

DNS domain:
    engineering.local

Hosts:

    MINT01    192.168.100.10    Static
    DC01      192.168.100.20    Static
    WIN01     192.168.100.30    DHCP reservation

VM-to-VM connectivity:
    Verified

External connectivity:
    Verified

Internal AD DNS:
    Implemented

DHCP:
    Implemented on DC01

libvirt DHCP:
    Removed

VLAN segmentation:
    Not implemented
```

## ARCHITECTURAL STATUS

The original Phase 1 networking architecture has been extended during the
Windows / Active Directory phase.

The underlying network remains:

```
192.168.100.0/24
    |
    +-- libvirt gateway / NAT
    |
    +-- MINT01
    +-- DC01
    +-- WIN01
```

However, network infrastructure responsibilities have changed.

Current responsibility model:

```
libvirt
    |
    +-- Virtual network
    +-- Gateway
    +-- NAT

DC01
    |
    +-- Active Directory
    +-- DNS
    +-- DHCP
```

The current network therefore provides:

```
- Dedicated virtual laboratory network
- Stable infrastructure addressing
- DC01-based DHCP
- DHCP reservation for WIN01
- Active Directory-integrated DNS
- Default routing
- NAT
- External connectivity
- VM-to-VM connectivity
- Domain-oriented DNS service discovery
```

The network architecture is considered current and verified for the
implemented laboratory environment.

## END
