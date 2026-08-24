# TRB-002 — libvirt Network Runtime Configuration Not Updated

## Status

    RESOLVED


## Environment

    Host:
        Arch Linux

    Virtualization:
        QEMU/KVM

    Network:
        engineering-lab

    Network subnet:
        192.168.100.0/24

    VM:
        MINT01


## Problem

A DHCP reservation was added to the persistent libvirt network
configuration for MINT01.

Expected:

    MINT01
        MAC: 52:54:00:c1:bb:a8
        IP: 192.168.100.10


However, after restarting the VM, MINT01 continued to receive:

    192.168.100.86


## Expected Configuration

The Git-managed network configuration contained:

```xml
<dhcp>
    <range start='192.168.100.50' end='192.168.100.100'/>

    <host
        mac='52:54:00:c1:bb:a8'
        name='MINT01'
        ip='192.168.100.10'/>
</dhcp>
