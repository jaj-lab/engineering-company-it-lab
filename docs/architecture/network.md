# Engineering Lab Network Architecture

## PURPOSE

This document describes the network architecture of the Engineering Company
IT Lab.

It defines the implemented network topology, addressing model, DHCP strategy,
routing, NAT, and DNS behavior.

The document represents the current verified laboratory state.

Future networking functionality is documented only when it has been
implemented or when explicitly identified as a planned dependency of a later
phase.


## NETWORK OVERVIEW

The laboratory uses a dedicated libvirt virtual network named:

    engineering-lab

The network provides connectivity between the laboratory virtual machines
and provides outbound Internet access through libvirt NAT.

The current network is a single IPv4 subnet:

    Network:    192.168.100.0/24
    Gateway:    192.168.100.1
    Netmask:    255.255.255.0
    Broadcast:  192.168.100.255

The current topology is:

                            External Network
                                  |
                                  |
                                NAT
                                  |
                                  |
                        +-------------------+
                        |  libvirt gateway  |
                        |   192.168.100.1   |
                        +---------+---------+
                                  |
                                  |
                        engineering-lab
                         192.168.100.0/24
                                  |
             +--------------------+--------------------+
             |                    |                    |
             |                    |                    |
          MINT01                DC01                 WIN01
       192.168.100.10       192.168.100.20       192.168.100.30
             |                    |                    |
          Linux                Windows              Windows


All three laboratory VMs are connected to the same Layer 2 virtual network.

The network is currently flat. No VLANs or additional network segments are
implemented inside the lab.


## LIBVIRT NETWORK

The network is managed by libvirt.

Network name:

    engineering-lab

Forwarding mode:

    NAT

Virtual bridge:

    engineering-lab

Gateway:

    192.168.100.1/24

The libvirt network is:

    Active:       yes
    Persistent:   yes
    Autostart:    no

The network uses libvirt's integrated DHCP and NAT functionality.


## IP ADDRESSING

The laboratory uses the following addressing model:

    192.168.100.0/24

Address allocation is divided into two logical areas.

Reserved addresses:

    192.168.100.10    MINT01
    192.168.100.20    DC01
    192.168.100.30    WIN01

Dynamic DHCP pool:

    192.168.100.50 - 192.168.100.100

The reserved addresses are assigned through DHCP reservations based on the
VM network interface MAC addresses.

This provides stable addresses while retaining DHCP-based configuration.


## CURRENT VM NETWORK IDENTITIES

MINT01

    Hostname:   MINT01
    Address:    192.168.100.10/24
    MAC:        52:54:00:c1:bb:a8
    Role:       Linux workstation / administration host


DC01

    Hostname:   DC01
    Address:    192.168.100.20/24
    MAC:        52:54:00:17:7d:e5
    Role:       Windows Server laboratory host


WIN01

    Hostname:   WIN01
    Address:    192.168.100.30/24
    MAC:        52:54:00:cd:78:97
    Role:       Windows client laboratory host


## DHCP

DHCP is currently provided by the libvirt engineering-lab network.

Dynamic allocation:

    192.168.100.50 - 192.168.100.100

Static DHCP reservations:

    52:54:00:c1:bb:a8 -> 192.168.100.10 -> MINT01
    52:54:00:17:7d:e5 -> 192.168.100.20 -> DC01
    52:54:00:cd:78:97 -> 192.168.100.30 -> WIN01

The reserved addresses are outside the dynamic DHCP pool.

This allows additional laboratory machines to receive addresses dynamically
from the .50-.100 range without conflicting with the existing VM addresses.

DHCP assignment has been verified from MINT01 by disconnecting and
reconnecting the network interface and confirming that the reserved address
192.168.100.10 was reissued.


## ROUTING

The laboratory VMs use:

    Default gateway:
        192.168.100.1

The gateway is provided by the libvirt network.

For example, MINT01 currently uses:

    default via 192.168.100.1 dev enp1s0

Traffic destined for the local 192.168.100.0/24 network remains on the
laboratory network.

Traffic destined for external networks is forwarded through the libvirt
gateway and NATed to the host's external network.


## NAT AND EXTERNAL CONNECTIVITY

The engineering-lab network uses libvirt NAT.

The laboratory VMs therefore do not require directly routable addresses on
the external network.

The traffic path is:

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

Outbound connectivity has been verified from MINT01.

Examples of verified connectivity include:

    1.1.1.1

and:

    google.com

Therefore both IP connectivity and external DNS resolution are currently
working.


## DNS

DNS is currently provided to the laboratory VMs through the libvirt gateway:

    192.168.100.1

MINT01 currently reports:

    DNS Server: 192.168.100.1

DNS resolution has been verified using:

    resolvectl query google.com

The current DNS architecture is intentionally temporary.

A dedicated internal DNS service has NOT yet been implemented.

In particular:

    DC01 is not yet an Active Directory Domain Controller.
    DC01 is not yet providing the laboratory's internal DNS service.

Internal Active Directory DNS will be introduced during the Windows
Infrastructure / Active Directory phase.

At that point, the DNS architecture will be reviewed and this document
updated to reflect the new authoritative internal DNS design.


##INTERNAL CONNECTIVITY

All three laboratory VMs are currently members of the same IPv4 subnet:

    192.168.100.0/24

Connectivity between the VMs has been verified.

Verified paths include:

    MINT01 -> DC01
    MINT01 -> WIN01

    DC01 -> MINT01
    DC01 -> WIN01

    WIN01 -> MINT01
    WIN01 -> DC01

The current network therefore provides full basic Layer 3 connectivity
between the laboratory hosts.


## NETWORK SEGMENTATION

No internal network segmentation is currently implemented.

Current state:

    One virtual network
    One IPv4 subnet
    One libvirt gateway
    One NAT boundary

There are currently no:

    VLANs
    Separate server/client subnets
    Dedicated management network
    Dedicated DMZ
    Inter-VLAN routing

This is intentional for the current laboratory stage.

Additional segmentation may be introduced in future phases if required by
the laboratory architecture.


## FIREWALL

No dedicated network firewall appliance is currently deployed inside the
laboratory network.

Host and operating-system firewall controls are outside the scope of this
network architecture document.

Windows firewall behavior may affect individual host connectivity and will be
addressed as part of Windows infrastructure and troubleshooting work where
applicable.


## CURRENT NETWORK STATE

The verified network state is:

    Network:
        engineering-lab

    Subnet:
        192.168.100.0/24

    Gateway:
        192.168.100.1

    DHCP pool:
        192.168.100.50 - 192.168.100.100

    NAT:
        Enabled

    DNS:
        192.168.100.1

    Hosts:

        MINT01    192.168.100.10
        DC01      192.168.100.20
        WIN01     192.168.100.30

    VM-to-VM connectivity:
        Verified

    External connectivity:
        Verified

    External DNS resolution:
        Verified

    Internal AD DNS:
        Not implemented

    VLAN segmentation:
        Not implemented


## ARCHITECTURAL STATUS

The Phase 1 networking architecture is considered complete.

The current network provides:

    - Dedicated virtual laboratory network
    - Stable VM addressing
    - DHCP
    - Default routing
    - NAT
    - External connectivity
    - DNS resolution
    - VM-to-VM connectivity

The next major architectural change is expected during the Windows
Infrastructure / Active Directory phase, when DC01 will provide internal
Active Directory DNS and the network's DNS architecture will be updated.


## END
