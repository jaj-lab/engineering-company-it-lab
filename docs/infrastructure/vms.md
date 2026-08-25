# Virtual Machines

## 1. Overview

The laboratory runs on:

- Arch Linux host
- QEMU/KVM
- libvirt
- virt-manager

The simulated company infrastructure runs inside virtual machines.

The host itself is not part of the simulated company environment.

## 2. Current Virtual Machines

| VM | OS | Role | IP | Status |
|---|---|---|---|---|
| MINT01 | Linux Mint | IT Administration Workstation | `192.168.100.10` | Ready |
| DC01 | Windows Server 2025 Standard | Domain Controller | `192.168.100.20` | Baseline |
| WIN01 | Windows 10/11 | Employee Workstation | `192.168.100.30` | Planned |

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
- Documentation

### Network

```text
Network: engineering-lab
IP:      192.168.100.10
Method:  DHCP reservation
```

The address is assigned by libvirt/dnsmasq based on
the VM's MAC address.

## 4. DC01

### Role

Future Domain Controller.

### Operating System

`Windows Server 2025 Standard`

### Current State

The VM has been installed and prepared as a clean Windows
Server baseline.

Current hostname:

`DC01`

Network:

```text
Network:  engineering-lab
IP:       192.168.100.20
Gateway:  192.168.100.1
DNS:      192.168.100.1
Method:   DHCP reservation
```

### Current Services

No Active Directory services have been installed yet.

Planned services:

- Active Directory Domain Services
- DNS
- DHCP

### Baseline Snapshot

A clean baseline snapshot was created before
installing server roles.

Purpose:

- rollback
- experimentation
- troubleshooting
- safe role installation

## 5. WIN01

### Role

Domain-joined employee workstation.

### Planned Network

```text
Network: engineering-lab
IP:      192.168.100.30
```

WIN01 will be introduced after the basic server
infrastructure is prepared.

## 6. VM Networking

All core VMs connect to:

`engineering-lab`

The network uses libvirt NAT networking.

Current topology:

```text
                    engineering-lab
                    192.168.100.0/24
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
       MINT01            DC01            WIN01
      .100.10           .100.20          .100.30
```

The network is designed to allow additional VMs
to be added without redesigning the base network.
