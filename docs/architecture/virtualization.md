# Virtualization

## 1. Overview

The Engineering Company IT Lab runs on a local virtualization
environment hosted on Arch Linux.

The virtualization stack is:

    Arch Linux
        |
        v
    QEMU/KVM
        |
        v
    libvirt
        |
        v
    virt-manager
        |
        v
    Virtual Machines

The host provides the virtualization platform.

The simulated company infrastructure exists inside the
virtual machines.

The host itself is not considered part of the simulated
company infrastructure.


## 2. Host

Operating System:

    Arch Linux

Current host resources:

    RAM:    16 GB
    Swap:   16 GB

The host is responsible for:

- running virtual machines
- providing hardware virtualization
- managing VM resources
- providing libvirt networking
- managing VM storage
- creating snapshots
- administering the laboratory

The host is intentionally kept separate from the simulated
company infrastructure.


## 3. QEMU/KVM

QEMU provides the virtual machine hardware and device
emulation.

KVM provides hardware-assisted virtualization.

The host supports KVM hardware virtualization.

The current virtualization environment uses KVM rather than
full software CPU emulation.

This allows the laboratory to run multiple guest operating
systems while keeping virtualization overhead relatively low.


## 4. libvirt

libvirt provides the management layer above QEMU/KVM.

It is responsible for:

- VM definitions
- virtual hardware configuration
- virtual networks
- DHCP
- NAT
- storage definitions
- VM lifecycle management
- snapshots

The laboratory uses the system libvirt instance.

Management URI:

    qemu:///system

The system instance is intentionally used because the
laboratory VMs and virtual networking are treated as
system-level infrastructure.


## 5. virt-manager

virt-manager provides a graphical management interface
for libvirt.

It is used for tasks such as:

- creating VMs
- installing operating systems
- configuring virtual hardware
- attaching ISO images
- managing virtual disks
- connecting virtual NICs
- viewing VM consoles
- creating and managing snapshots

CLI-based administration remains important because the
project is intended to develop infrastructure administration
skills rather than depend exclusively on a GUI.

Common management operations should be understood both
through virt-manager and through libvirt commands where
practical.


## 6. Current Virtualization Resources

Installed virtualization software:

    QEMU:
        qemu-desktop

    libvirt:
        libvirt

    Management:
        virt-manager

The host has:

    16 GB RAM
    16 GB swap

VM resources are allocated according to the role of each
guest.

The laboratory intentionally avoids assigning all available
host memory to virtual machines.

This leaves resources available for:

- the Arch Linux host
- virt-manager
- QEMU/KVM overhead
- storage operations
- host applications
- temporary workloads

Swap is treated as additional safety margin rather than
as a substitute for physical RAM.


## 7. Current Virtual Machines

The Phase 0 environment contains three core virtual machines:

    MINT01
        Linux Mint
        IT Administration Workstation
        192.168.100.10

    DC01
        Windows Server 2025 Standard
        Future Domain Controller
        192.168.100.20

    WIN01
        Windows 10/11
        Future Domain Client
        192.168.100.30

All three VMs are connected to:

    engineering-lab
    192.168.100.0/24

Their addresses are provided through libvirt DHCP
reservations.


## 8. VM Roles and Current State

### MINT01

Role:

    IT Administration Workstation

Operating System:

    Linux Mint

Current state:

    Ready

Primary uses:

- infrastructure administration
- Git
- Bash
- PowerShell
- Terraform
- network troubleshooting
- documentation
- repository management

Network address:

    192.168.100.10


### DC01

Role:

    Future Domain Controller

Operating System:

    Windows Server 2025 Standard

Current state:

    Baseline ready

Hostname:

    DC01

Network address:

    192.168.100.20

DC01 is currently a Windows Server installation.

It is NOT yet a Domain Controller.

The following services are planned for a later phase:

- Active Directory Domain Services
- DNS
- DHCP
- domain services
- Group Policy


### WIN01

Role:

    Future Domain Client

Operating System:

    Windows 10/11

Current state:

    Baseline ready

Hostname:

    WIN01

Network address:

    192.168.100.30

WIN01 is currently a normal Windows client.

It has NOT been domain-joined.

Domain joining will occur only after Active Directory
has been configured on DC01.


## 9. VM Networking

All Phase 0 VMs connect to:

    engineering-lab

Network:

    192.168.100.0/24

Gateway:

    192.168.100.1

DHCP range:

    192.168.100.50 - 192.168.100.100

DHCP reservations:

    MINT01    192.168.100.10
    DC01      192.168.100.20
    WIN01     192.168.100.30

Topology:

    engineering-lab
    192.168.100.0/24
            |
            +-----------------+-----------------+
            |                 |                 |
            v                 v                 v
         MINT01             DC01              WIN01
      192.168.100.10    192.168.100.20    192.168.100.30

The detailed network configuration is documented separately
in:

    docs/architecture/network.md

The libvirt network definition is stored in:

    networking/configs/engineering-lab.xml


## 10. VM Lifecycle

The general VM lifecycle is:

    Create
      |
      v
    Install OS
      |
      v
    Install required drivers
      |
      v
    Configure hardware
      |
      v
    Connect to engineering-lab
      |
      v
    Configure guest OS
      |
      v
    Verify networking
      |
      v
    Create baseline snapshot
      |
      v
    Begin role-specific configuration

The baseline represents a known-good state before
role-specific configuration begins.


## 11. Baseline Snapshots

Snapshots are used as a rollback mechanism during
laboratory exercises.

Baseline snapshots have been created for the Windows
virtual machines before major role-specific configuration.

Current baseline snapshots include:

    DC01
        Baseline snapshot

    WIN01
        win01-baseline

Snapshots provide a convenient rollback mechanism for
experimentation and troubleshooting.

They are not considered a complete backup strategy.

Backups and disaster recovery are separate topics.


## 12. Resource Planning

VM resources are allocated according to workload rather
than maximized by default.

The laboratory runs on a host with:

    16 GB RAM
    16 GB swap

The primary resource considerations are:

    CPU
    RAM
    Storage
    Network

Windows Server and Windows Client workloads generally
require more memory than the Linux administration
workstation.

Resources may therefore be adjusted as the laboratory
progresses.

The objective is to maintain a usable host while providing
enough resources for the current learning scenario.

Resource allocation should be reviewed whenever a new VM
or significant service is introduced.


## 13. Virtual Machine Naming

The laboratory uses role-oriented VM names:

    MINT01
    DC01
    WIN01

The names describe the logical role of the machines inside
the laboratory.

The underlying libvirt VM name may differ from the simulated
guest hostname when necessary.

Architecture and infrastructure documentation use the
logical laboratory names.


## 14. Virtualization Troubleshooting

Virtualization problems should be investigated from the
bottom of the stack upward.

    Guest OS
        |
        v
    Virtual Hardware
        |
        v
    QEMU
        |
        v
    KVM
        |
        v
    libvirt
        |
        v
    Host OS
        |
        v
    Physical Hardware

Useful diagnostic areas include:

    VM state
    libvirt state
    QEMU process
    KVM availability
    virtual NIC
    virtual disk
    libvirt network
    host resources

The troubleshooting approach should identify which
layer is actually failing before applying a fix.


## 15. Management Commands

Common system-level commands:

    sudo virsh list --all
    sudo virsh dominfo <VM>
    sudo virsh start <VM>
    sudo virsh shutdown <VM>
    sudo virsh destroy <VM>
    sudo virsh domiflist <VM>
    sudo virsh dumpxml <VM>

Snapshot-related commands:

    sudo virsh snapshot-list <VM>
    sudo virsh snapshot-info <VM> <snapshot>

Network-related commands are documented separately.


## 16. Phase 0 State

The virtualization foundation is complete.

Current state:

    QEMU/KVM              READY
    libvirt               READY
    virt-manager          READY
    engineering-lab       ACTIVE
    MINT01                READY
    DC01                  BASELINE READY
    WIN01                 BASELINE READY

Verified during Phase 0:

- VMs can connect to the laboratory network
- DHCP reservations provide the intended addresses
- MINT01 can communicate with the Windows VMs
- DC01 and WIN01 can communicate with each other
- baseline snapshots exist
- the VMs can be managed through system libvirt

The next phase will begin role-specific configuration
of DC01.


## 17. Design Principles

The virtualization environment follows these principles:

### Simplicity

Use the minimum virtualization complexity required
for the current learning objective.

### Reproducibility

Important VM configuration should be documented.

### Isolation

The simulated company infrastructure should remain
inside the laboratory environment.

### Rollback

Major changes should be protected by snapshots when
appropriate.

### Resource Awareness

VM resources should be intentionally allocated rather
than maximized by default.

### CLI + GUI

Use both command-line and graphical administration
to understand what the management tools actually do.

### Incremental Growth

New virtual machines should be added only when they
provide a clear architectural or learning purpose.

The laboratory should not grow simply because additional
virtual machines are available.
