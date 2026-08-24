# TRB-001 — libvirt Network Bridge Creation Failure

## Status

    RESOLVED

## Environment

    Host:
        Arch Linux

    Virtualization:
        QEMU/KVM

    Virtualization management:
        libvirt

    Network:
        engineering-lab

    libvirt network type:
        NAT

    Subnet:
        192.168.100.0/24


## Problem

The `engineering-lab` libvirt network was successfully defined,
but failed to start.

Command:

```bash
sudo virsh net-start engineering-lab
