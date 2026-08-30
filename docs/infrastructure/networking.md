# Engineering Lab Networking — Infrastructure State

================================================================================
PURPOSE
=======

This document describes the currently implemented and verified operational
state of the Engineering Company IT Lab network.

Unlike the network architecture document, this document focuses on the actual
configuration, observed state, verification commands, and operational
behavior of the laboratory network.

The current state includes the original libvirt-based network transport and
NAT architecture, with DHCP and DNS responsibilities migrated to DC01 during
the Windows / Active Directory phase.

================================================================================
LIBVIRT NETWORK
===============

Network name:

```
engineering-lab
```

Status:

```
Active:       yes
Persistent:   yes
Autostart:    no
```

Bridge:

```
engineering-lab
```

Forward mode:

```
NAT
```

Network address:

```
192.168.100.0/24
```

Netmask:

```
255.255.255.0
```

Gateway:

```
192.168.100.1
```

Verified with:

```
sudo virsh net-info engineering-lab

sudo virsh net-dumpxml engineering-lab
```

The libvirt network remains responsible for:

```
- Virtual Layer 2 connectivity
- Default gateway
- NAT
- Outbound Internet connectivity
```

The libvirt network is no longer responsible for DHCP.

================================================================================
NETWORK CONFIGURATION
=====================

The libvirt network provides:

```
IPv4 subnet:
    192.168.100.0/24

Gateway:
    192.168.100.1

DHCP:
    Disabled in libvirt

NAT:
    Enabled
```

The libvirt network no longer contains a DHCP range or static DHCP host
reservations.

DHCP responsibility has been migrated to DC01.

Verified with:

```
sudo virsh net-dumpxml engineering-lab
```

The resulting responsibility model is:

```
libvirt
    |
    +-- Virtual network
    +-- Gateway
    +-- NAT

DC01
    |
    +-- DHCP
    +-- DNS
    +-- Active Directory
```

================================================================================
DHCP CONFIGURATION
==================

DHCP is provided by the Windows DHCP Server service running on DC01.

DHCP server:

```
DC01.engineering.local
192.168.100.20
```

DHCP authorization:

```
Authorized in Active Directory
```

DHCP scope:

```
Scope name:
    Engineering Lab

Network:
    192.168.100.0/24

Dynamic range:
    192.168.100.50 - 192.168.100.100

Scope state:
    Active

Lease duration:
    8 days
```

DHCP options:

```
Default gateway:
    192.168.100.1

DNS server:
    192.168.100.20

DNS domain:
    engineering.local
```

DHCP reservation:

```
Host:
    WIN01

MAC:
    52:54:00:cd:78:97

IP:
    192.168.100.30

Reservation type:
    Both
```

The reserved WIN01 address is outside the dynamic DHCP pool.

The dynamic pool remains available for future DHCP clients:

```
192.168.100.50 - 192.168.100.100
```

================================================================================
DHCP RESPONSIBILITY MIGRATION
=============================

DHCP responsibility was migrated from libvirt to DC01.

Previous state:

```
libvirt
   |
   +-- DHCP
   +-- DHCP reservations
   +-- Gateway
   +-- NAT
```

Current state:

```
libvirt
   |
   +-- Gateway
   +-- NAT

DC01
   |
   +-- DHCP
   +-- DHCP reservation for WIN01
   +-- DNS
   +-- Active Directory
```

The migration included:

```
[x] DHCP server configured on DC01
[x] DHCP server authorized in Active Directory
[x] Engineering Lab scope created
[x] Dynamic range configured
[x] DHCP options configured
[x] WIN01 reservation configured
[x] libvirt DHCP service removed
[x] libvirt DHCP range removed
[x] libvirt DHCP reservations removed
[x] WIN01 DHCP operation verified
[x] No competing DHCP servers remain
```

================================================================================
DHCP VERIFICATION — WIN01
=========================

WIN01 was configured to use DHCP.

The following state was verified:

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

The reserved address is supplied by DC01 DHCP based on the WIN01 MAC
address:

```
52:54:00:cd:78:97
    |
    v
DC01 DHCP
    |
    v
192.168.100.30
```

The DHCP lease was successfully obtained by WIN01.

The libvirt DHCP service is not involved in this assignment.

================================================================================
IP ADDRESSING
=============

The current laboratory addressing model is:

```
192.168.100.0/24
```

Static infrastructure:

```
192.168.100.1
    libvirt gateway

192.168.100.10
    MINT01

192.168.100.20
    DC01
```

DHCP reservation:

```
192.168.100.30
    WIN01
```

Dynamic DHCP pool:

```
192.168.100.50 - 192.168.100.100
```

Future / infrastructure address space:

```
192.168.100.101 - 192.168.100.254
```

This addressing model keeps infrastructure and reserved client addresses
outside the dynamic DHCP pool.

================================================================================
VM NETWORK INTERFACES
=====================

MINT01

```
Interface:
    enp1s0

MAC:
    52:54:00:c1:bb:a8

IPv4:
    192.168.100.10/24

Addressing:
    Static

Gateway:
    192.168.100.1

NetworkManager:
    Active
```

DC01

```
Interface:
    Ethernet 2

MAC:
    52:54:00:17:7d:e5

IPv4:
    192.168.100.20/24

Addressing:
    Static
```

WIN01

```
Interface:
    Ethernet 2

MAC:
    52:54:00:cd:78:97

IPv4:
    192.168.100.30/24

Addressing:
    DHCP reservation
```

VM addresses can be inspected from the libvirt host using:

```
sudo virsh domifaddr IT-LAB_MINT01
sudo virsh domifaddr IT-LAB_DC01
sudo virsh domifaddr IT-LAB_WIN01
```

================================================================================
MINT01 ROUTING
==============

MINT01 uses the libvirt gateway as its default route.

Expected routing model:

```
default via 192.168.100.1 dev enp1s0
```

The directly connected laboratory network is:

```
192.168.100.0/24
    dev enp1s0
```

Verified with:

```
ip route
```

The gateway remains provided by libvirt rather than DC01.

DC01 DHCP distributes the gateway address to DHCP clients.

================================================================================
DNS
===

DNS is provided by DC01.

DC01 hosts the DNS service used by the Active Directory domain:

```
engineering.local
```

DNS server:

```
192.168.100.20
```

DHCP clients receive:

```
DNS server:
    192.168.100.20

DNS domain:
    engineering.local
```

The current DNS architecture is:

```
Client
   |
   v
DC01
192.168.100.20
   |
   +-- Active Directory-integrated DNS
   |
   +-- engineering.local
   |
   +-- External DNS resolution
```

DC01 therefore provides the internal DNS service required by Active
Directory.

================================================================================
ACTIVE DIRECTORY DNS VERIFICATION
=================================

DNS resolution required for Active Directory was verified.

The following records were tested:

```
DC01.engineering.local

engineering.local

_ldap._tcp.dc._msdcs.engineering.local
```

The LDAP SRV record is particularly important because Active Directory
clients use DNS service records to locate domain controllers.

The expected lookup is:

```
Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV
```

Domain controller discovery was also verified with:

```
nltest /dsgetdc:engineering.local
```

This confirms that DNS is functioning as part of the Active Directory
infrastructure rather than merely providing external Internet resolution.

================================================================================
NETWORKMANAGER
==============

MINT01 uses NetworkManager for network configuration.

Verified with:

```
systemctl is-active NetworkManager
```

Result:

```
active
```

The interface can be administratively disconnected and reconnected using:

```
sudo nmcli device disconnect enp1s0
sudo nmcli device connect enp1s0
```

systemd-networkd is not running on MINT01.

The interface is therefore managed by NetworkManager rather than
systemd-networkd.

================================================================================
EXTERNAL CONNECTIVITY
=====================

The laboratory uses libvirt NAT for outbound connectivity.

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

External IP connectivity was verified from MINT01 using:

```
ping -c 3 1.1.1.1
```

External DNS resolution and connectivity were also previously verified
using:

```
ping -c 3 google.com
```

The migration of DHCP and DNS responsibility to DC01 does not change the
libvirt NAT boundary.

DC01 provides DNS service, while libvirt continues to provide outbound NAT.

================================================================================
VM-TO-VM CONNECTIVITY
=====================

All three laboratory VMs remain connected to the same:

```
192.168.100.0/24
```

laboratory network.

Previously verified connectivity includes:

```
MINT01 -> DC01
MINT01 -> WIN01

DC01 -> MINT01
DC01 -> WIN01

WIN01 -> MINT01
WIN01 -> DC01
```

Example verification commands:

MINT01:

```
ping -c 3 192.168.100.20
ping -c 3 192.168.100.30
```

DC01:

```
Test-Connection 192.168.100.10 -Count 3
Test-Connection 192.168.100.30 -Count 3
```

WIN01:

```
Test-Connection 192.168.100.10 -Count 3
Test-Connection 192.168.100.20 -Count 3
```

The network remains a single flat IPv4 network with direct connectivity
between the laboratory hosts.

================================================================================
NO COMPETING DHCP SERVICES
==========================

The libvirt DHCP service has been removed from the engineering-lab network.

The current DHCP responsibility is exclusively:

```
DC01
    |
    +-- DHCP
```

libvirt provides:

```
Gateway
NAT
```

but does not provide:

```
DHCP
```

This prevents multiple DHCP servers from competing to provide network
configuration to laboratory clients.

================================================================================
CURRENT NETWORK STATE
=====================

```
Network:
    engineering-lab

Status:
    Active / Persistent

Bridge:
    engineering-lab

Forward mode:
    NAT

Subnet:
    192.168.100.0/24

Gateway:
    192.168.100.1

NAT:
    Enabled through libvirt

libvirt DHCP:
    Disabled / Removed

DHCP server:
    DC01
    192.168.100.20

DHCP scope:
    Engineering Lab

DHCP pool:
    192.168.100.50 - 192.168.100.100

DHCP reservation:
    WIN01 -> 192.168.100.30

DNS server:
    DC01
    192.168.100.20

DNS domain:
    engineering.local
```

VMs:

```
MINT01
    192.168.100.10/24
    Static
    enp1s0

DC01
    192.168.100.20/24
    Static
    Ethernet 2

WIN01
    192.168.100.30/24
    DHCP reservation
    Ethernet 2
```

================================================================================
VERIFICATION SUMMARY
====================

LIBVIRT / NETWORK

```
[x] Libvirt network is active
[x] Libvirt network is persistent
[x] Correct bridge is configured
[x] Correct subnet is configured
[x] NAT is operational
[x] Default gateway is 192.168.100.1
```

DHCP

```
[x] DC01 DHCP server configured
[x] DHCP server authorized in Active Directory
[x] Engineering Lab DHCP scope configured
[x] Dynamic pool configured
[x] DHCP options configured
[x] WIN01 reservation configured
[x] WIN01 receives 192.168.100.30
[x] libvirt DHCP service removed
[x] libvirt DHCP reservations removed
[x] No competing DHCP servers remain
```

DNS / ACTIVE DIRECTORY

```
[x] DC01 provides internal DNS
[x] engineering.local resolves
[x] DC01.engineering.local resolves
[x] Active Directory LDAP SRV record resolves
[x] Domain Controller discovery succeeds
[x] DHCP distributes DC01 as DNS server
```

CONNECTIVITY

```
[x] MINT01 -> DC01 connectivity verified
[x] MINT01 -> WIN01 connectivity verified
[x] DC01 -> MINT01 connectivity verified
[x] DC01 -> WIN01 connectivity verified
[x] WIN01 -> MINT01 connectivity verified
[x] WIN01 -> DC01 connectivity verified
[x] External IP connectivity verified
[x] External DNS resolution verified
```

================================================================================
OPERATIONAL STATUS
==================

The Phase 1 network transport remains implemented and verified.

During the Windows / Active Directory phase, DHCP and DNS responsibilities
were migrated from libvirt to DC01.

The current operational architecture is therefore:

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

The laboratory network currently provides:

```
- Stable infrastructure addressing
- DC01-based DHCP
- WIN01 DHCP reservation
- Active Directory-integrated DNS
- Default routing
- NAT
- External connectivity
- VM-to-VM connectivity
- Active Directory DNS service discovery
```

The network remains a single flat IPv4 subnet with no VLAN segmentation.

================================================================================
END
===
