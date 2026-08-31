# DHCP Scope — Engineering Lab

## 1. PURPOSE

This document defines the DHCP configuration implemented on DC01 for the
Engineering Company IT Lab.

The DHCP service provides dynamic IPv4 addressing for laboratory clients while
reserving fixed addresses for infrastructure systems that require predictable
network identities.

The DHCP server is provided by DC01 after Active Directory infrastructure was
implemented.

Domain:

    engineering.local


## 2. DHCP SERVER

Server:

    DC01

Hostname:

    DC01

IP address:

    192.168.100.20

Role:

    DHCP Server

The DHCP service runs on DC01 and serves the laboratory network:

    engineering-lab

DHCP is integrated with the Active Directory / DNS environment.


## 3. SCOPE

Scope name:

    Engineering Lab

Network:

    192.168.100.0/24

Subnet mask:

    255.255.255.0

Network address:

    192.168.100.0

Broadcast address:

    192.168.100.255


Dynamic address range:

    192.168.100.50
        -
    192.168.100.100


The dynamic range is intentionally separated from the reserved infrastructure
addresses.

Reserved infrastructure addresses:

    Gateway:
        192.168.100.1

    MINT01:
        192.168.100.10

    DC01:
        192.168.100.20

    WIN01:
        192.168.100.30


## 4. DHCP OPTIONS

Option 003 — Router

    192.168.100.1

The laboratory libvirt gateway is provided as the default gateway for DHCP
clients.


Option 006 — DNS Servers

    192.168.100.20

DC01 provides DNS for the Active Directory domain.

Clients should therefore use DC01 as their primary DNS server rather than
the libvirt gateway.


Option 015 — DNS Domain Name

    engineering.local

The domain suffix allows DHCP clients to participate correctly in the
engineering.local DNS namespace.


## 5. RESERVATIONS

WIN01 has a DHCP reservation to ensure that the employee workstation always
receives its expected address.

Reservation:

    Hostname:
        WIN01

    MAC address:
        52-54-00-CD-78-97

    Reserved IP:
        192.168.100.30

    Description:
        Employee workstation


The reserved address is outside the dynamic DHCP range.


MINT01 and DC01 use addresses that are also outside the DHCP dynamic range.

Their addresses are:

    MINT01
        192.168.100.10

    DC01
        192.168.100.20


## 6. ADDRESSING MODEL

The laboratory uses the following addressing model:

    192.168.100.1
        |
        +-- Gateway / libvirt NAT

    192.168.100.10
        |
        +-- MINT01
        |   IT administration workstation

    192.168.100.20
        |
        +-- DC01
            Active Directory
            DNS
            DHCP

    192.168.100.30
        |
        +-- WIN01
            Employee workstation
            DHCP reservation

    192.168.100.50 - 192.168.100.100
        |
        +-- Dynamic DHCP clients


## 7. CLIENT CONFIGURATION

A DHCP client on the Engineering Lab network should receive:

    IPv4 address:
        From 192.168.100.50 - 192.168.100.100
        unless a reservation exists

    Subnet mask:
        255.255.255.0

    Default gateway:
        192.168.100.1

    DNS server:
        192.168.100.20

    DNS domain:
        engineering.local


Expected configuration for WIN01:

    IPv4 address:
        192.168.100.30

    Subnet mask:
        255.255.255.0

    Default gateway:
        192.168.100.1

    DNS server:
        192.168.100.20

    DNS domain:
        engineering.local


## 8. DHCP / DNS / ACTIVE DIRECTORY RELATIONSHIP

The Windows infrastructure uses the following relationship:

                    engineering.local
                           |
                           v
                          DC01
                           |
              +------------+------------+
              |            |            |
             AD DS        DNS          DHCP
                           |
                           v
                  192.168.100.20
                           |
                           v
                     Windows clients


DHCP provides the network configuration required by Windows clients.

DNS on DC01 provides name resolution for the Active Directory domain.

Active Directory provides the domain identity and authentication layer.


## 9. VERIFICATION

The DHCP configuration should be verified from DC01 using PowerShell.

Examples:

    Get-DhcpServerv4Scope

    Get-DhcpServerv4OptionValue

    Get-DhcpServerv4Reservation

    Get-DhcpServerv4Lease


For WIN01, verify the received configuration with:

    ipconfig /all


Expected WIN01 values:

    IPv4 Address:
        192.168.100.30

    Default Gateway:
        192.168.100.1

    DNS Server:
        192.168.100.20

    DNS Suffix:
        engineering.local


## 10. IMPLEMENTATION SOURCE

The reproducible DHCP configuration is implemented by:

    windows/dhcp/setup-dhcp.ps1


This document defines the expected configuration.

The PowerShell script is the executable representation of that configuration.


## CURRENT STATUS

    DHCP Server
        IMPLEMENTED

    DHCP Scope
        IMPLEMENTED

    Dynamic range
        192.168.100.50 - 192.168.100.100

    Router option
        192.168.100.1

    DNS option
        192.168.100.20

    DNS domain
        engineering.local

    WIN01 reservation
        192.168.100.30

    DHCP client configuration
        VERIFIED

    Active Directory integration
        VERIFIED
