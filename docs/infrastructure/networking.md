# Engineering Lab Networking — Infrastructure State

================================================================================
PURPOSE
================================================================================

This document describes the currently implemented and verified operational
state of the Engineering Company IT Lab network.

Unlike the network architecture document, this document focuses on the
actual configuration, observed state, verification commands, and operational
behavior of the laboratory network.

The implementation described here reflects the verified Phase 1 state.


================================================================================
LIBVIRT NETWORK
================================================================================

Network name:

    engineering-lab

Status:

    Active:       yes
    Persistent:   yes
    Autostart:    no

Bridge:

    engineering-lab

Forward mode:

    NAT

Network address:

    192.168.100.0/24

Netmask:

    255.255.255.0

Gateway:

    192.168.100.1


Verified with:

    sudo virsh net-info engineering-lab

    sudo virsh net-dumpxml engineering-lab


================================================================================
NETWORK CONFIGURATION
================================================================================

The libvirt network provides:

    IPv4 subnet:
        192.168.100.0/24

    Gateway:
        192.168.100.1

    DHCP:
        Enabled

    NAT:
        Enabled

    DHCP dynamic range:
        192.168.100.50 - 192.168.100.100

The current network configuration is defined by the libvirt network XML.


Verified configuration:

    sudo virsh net-dumpxml engineering-lab


================================================================================
DHCP CONFIGURATION
================================================================================

The network uses libvirt's built-in DHCP service.

Dynamic DHCP range:

    192.168.100.50 - 192.168.100.100

The following DHCP reservations are configured:

    MINT01
        MAC: 52:54:00:c1:bb:a8
        IP:  192.168.100.10

    DC01
        MAC: 52:54:00:17:7d:e5
        IP:  192.168.100.20

    WIN01
        MAC: 52:54:00:cd:78:97
        IP:  192.168.100.30

The reserved addresses are outside the dynamic DHCP range.


Verified with:

    sudo virsh net-dhcp-leases engineering-lab

Example verified leases:

    dc01   -> 192.168.100.20/24
    mint01 -> 192.168.100.10/24
    win01  -> 192.168.100.30/24


================================================================================
DHCP VERIFICATION
================================================================================

DHCP behavior was verified directly from MINT01.

Initial state:

    enp1s0
        192.168.100.10/24
        default gateway: 192.168.100.1

NetworkManager was confirmed to be active:

    systemctl is-active NetworkManager

Result:

    active

The interface was then disconnected:

    sudo nmcli device disconnect enp1s0

The IPv4 address disappeared from the interface.

The interface was reconnected:

    sudo nmcli device connect enp1s0

The interface subsequently received:

    192.168.100.10/24

The DHCP lease was also visible from the libvirt host:

    sudo virsh net-dhcp-leases engineering-lab

The MINT01 reservation therefore behaves as expected.


================================================================================
VM NETWORK INTERFACES
================================================================================

MINT01

    Interface:
        enp1s0

    MAC:
        52:54:00:c1:bb:a8

    IPv4:
        192.168.100.10/24

    Gateway:
        192.168.100.1

    NetworkManager:
        Active


DC01

    Interface:
        Ethernet 2

    MAC:
        52:54:00:17:7d:e5

    IPv4:
        192.168.100.20/24


WIN01

    Interface:
        Ethernet 2

    MAC:
        52:54:00:cd:78:97

    IPv4:
        192.168.100.30/24


VM addresses were additionally verified from the libvirt host using:

    sudo virsh domifaddr IT-LAB_MINT01
    sudo virsh domifaddr IT-LAB_DC01
    sudo virsh domifaddr IT-LAB_WIN01


================================================================================
MINT01 ROUTING
================================================================================

MINT01 uses the libvirt gateway as its default route.

Verified routing table:

    default via 192.168.100.1 dev enp1s0 proto dhcp
        src 192.168.100.10
        metric 100

The directly connected laboratory network is:

    192.168.100.0/24
        dev enp1s0
        src 192.168.100.10


Verified with:

    ip route


================================================================================
DNS
================================================================================

DNS configuration on MINT01 is provided through the libvirt gateway.

Current DNS server:

    192.168.100.1

Verified with:

    resolvectl status

Relevant result:

    Link 2 (enp1s0)
        Current Scopes: DNS
        Current DNS Server: 192.168.100.1
        DNS Servers: 192.168.100.1


DNS resolution was verified using:

    resolvectl query google.com

The query successfully returned IPv4 and IPv6 addresses for google.com.

The gateway itself is also resolvable:

    resolvectl query 192.168.100.1

Current DNS behavior is therefore:

    MINT01
       |
       v
    192.168.100.1
       |
       v
    External DNS resolution


A dedicated internal DNS server is not currently implemented.

DC01 is not yet configured as an Active Directory Domain Controller and is
therefore not currently providing internal Active Directory DNS.

This will change during the Windows Infrastructure / Active Directory phase.


================================================================================
NETWORKMANAGER
================================================================================

MINT01 uses NetworkManager for network configuration.

Verified with:

    systemctl is-active NetworkManager

Result:

    active

The interface can be administratively disconnected and reconnected using:

    sudo nmcli device disconnect enp1s0
    sudo nmcli device connect enp1s0

After reconnection, NetworkManager successfully restores the DHCP
configuration and MINT01 receives its reserved address:

    192.168.100.10/24


Note:

    systemd-networkd is not running on MINT01.

The interface is therefore managed by NetworkManager rather than
systemd-networkd.


================================================================================
EXTERNAL CONNECTIVITY VERIFICATION
================================================================================

External IP connectivity was verified from MINT01.

Test:

    ping -c 3 1.1.1.1

Result:

    3 packets transmitted
    3 packets received
    0% packet loss

External DNS and connectivity were also verified with:

    ping -c 3 google.com

Result:

    3 packets transmitted
    3 packets received
    0% packet loss


Therefore the complete outbound path is operational:

    MINT01
       |
       v
    192.168.100.1
       |
       v
    libvirt NAT
       |
       v
    External Network
       |
       v
    Internet


================================================================================
VM-TO-VM CONNECTIVITY
================================================================================

Connectivity between all three laboratory VMs was verified.

MINT01:

    ping -c 3 192.168.100.20
    ping -c 3 192.168.100.30

Both tests:

    3 packets transmitted
    3 packets received
    0% packet loss


DC01:

    Test-Connection 192.168.100.10 -Count 3
    Test-Connection 192.168.100.30 -Count 3

Both tests completed successfully.


WIN01:

    Test-Connection 192.168.100.10 -Count 3
    Test-Connection 192.168.100.20 -Count 3

Both tests completed successfully.


Verified connectivity matrix:

                    MINT01      DC01       WIN01
    MINT01             -         OK          OK
    DC01              OK          -          OK
    WIN01             OK         OK           -


All three VMs can currently communicate with each other over the
192.168.100.0/24 laboratory network.


================================================================================
CURRENT NETWORK STATE
================================================================================

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

    DHCP:
        Enabled

    DHCP pool:
        192.168.100.50 - 192.168.100.100

    DNS:
        192.168.100.1

    MINT01:
        192.168.100.10/24
        enp1s0
        DHCP reservation

    DC01:
        192.168.100.20/24
        Ethernet 2
        DHCP reservation

    WIN01:
        192.168.100.30/24
        Ethernet 2
        DHCP reservation


================================================================================
VERIFICATION SUMMARY
================================================================================

The following areas have been verified:

    [x] Libvirt network is active
    [x] Libvirt network is persistent
    [x] Correct bridge is configured
    [x] Correct subnet is configured
    [x] DHCP pool is configured
    [x] DHCP reservations are configured
    [x] MINT01 receives its reserved DHCP address
    [x] DHCP renewal/reconnection verified
    [x] Default gateway is correct
    [x] NAT is operational
    [x] MINT01 external IP connectivity verified
    [x] MINT01 external DNS resolution verified
    [x] MINT01 -> DC01 connectivity verified
    [x] MINT01 -> WIN01 connectivity verified
    [x] DC01 -> MINT01 connectivity verified
    [x] DC01 -> WIN01 connectivity verified
    [x] WIN01 -> MINT01 connectivity verified
    [x] WIN01 -> DC01 connectivity verified


================================================================================
OPERATIONAL STATUS
================================================================================

Phase 1 networking is implemented and verified.

The current laboratory network provides stable VM addressing, DHCP, routing,
NAT, DNS resolution, external connectivity, and VM-to-VM connectivity.

No dedicated internal DNS service, Active Directory DNS, VLAN segmentation,
or additional network segments are currently implemented.

These are outside the current Phase 1 operational state and will be addressed
only when introduced by later phases.


================================================================================
END
================================================================================
