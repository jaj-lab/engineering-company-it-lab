# Engineering Company IT Lab

## 1. Purpose

The Engineering Company IT Lab is a hands-on infrastructure
laboratory representing a small international engineering company.

The lab is designed to practice:

- IT administration
- virtualization
- networking
- Windows administration
- Active Directory
- ITSM
- cloud infrastructure
- Infrastructure as Code
- automation
- monitoring
- security
- troubleshooting
- documentation

The environment is intentionally modular.

New components are introduced only when they provide a real
learning or architectural purpose.


## 2. High-Level Architecture

The laboratory consists of several logical areas:

    ENGINEERING COMPANY IT LAB
    |
    +-- On-Premises Infrastructure
    |   +-- Virtualization
    |   +-- Networking
    |   +-- Windows Server
    |   +-- Active Directory
    |   +-- Windows Clients
    |   +-- File Services
    |
    +-- ITSM
    |   +-- Tickets
    |   +-- Incidents
    |   +-- Assets
    |   +-- Software
    |   +-- Licenses
    |
    +-- Cloud
    |   +-- Floci
    |
    +-- Infrastructure as Code
    |   +-- Terraform
    |
    +-- Automation
    |   +-- PowerShell
    |   +-- Bash
    |   +-- Python
    |
    +-- CI/CD
    |   +-- GitHub Actions
    |
    +-- Monitoring
    |
    +-- Security


## 3. Host and Virtualization

The laboratory is hosted on a physical machine running
Arch Linux.

    HOST
    |
    +-- Arch Linux
        |
        +-- QEMU/KVM
            |
            +-- libvirt
                |
                +-- virt-manager
                    |
                    +-- Virtual Machines

The host provides the virtualization and management
environment.

The simulated company infrastructure exists inside
the virtual machines.

The host itself is not part of the simulated company
infrastructure.

Current host resources:

    Operating System:  Arch Linux
    RAM:              16 GB
    Swap:             16 GB
    Virtualization:   QEMU/KVM
    VM Management:    libvirt / virt-manager
    libvirt URI:      qemu:///system


## 4. Laboratory Network

The primary laboratory network is:

    engineering-lab
    192.168.100.0/24

The network is implemented as a libvirt NAT network.

    engineering-lab
    192.168.100.0/24
            |
            +-----------------+-----------------+
            |                 |                 |
            v                 v                 v
         MINT01             DC01              WIN01
      192.168.100.10    192.168.100.20    192.168.100.30

Network parameters:

    Network:        engineering-lab
    Type:           NAT
    Subnet:         192.168.100.0/24
    Gateway:        192.168.100.1

    DHCP range:
        192.168.100.50 - 192.168.100.100

The core machines use DHCP reservations:

    MINT01    192.168.100.10
    DC01      192.168.100.20
    WIN01     192.168.100.30

The network configuration is maintained in:

    networking/configs/engineering-lab.xml

The network is designed as a reusable internal laboratory
network.

Additional virtual machines can be connected to the same
network without redesigning the base topology.


## 5. Virtual Machines

The initial architecture contains three core virtual machines:

    MINT01
        Linux Mint
        IT Administration Workstation

    DC01
        Windows Server 2025 Standard
        Future Domain Controller

    WIN01
        Windows 10/11
        Employee Workstation

Their roles are intentionally separated.


### MINT01

MINT01 represents the IT administrator's workstation.

It is used for:

- infrastructure administration
- SSH
- PowerShell
- Bash
- Git
- Terraform
- network troubleshooting
- documentation
- repository management

Current state:

    Status:       Ready
    IP:           192.168.100.10
    Networking:   DHCP reservation


### DC01

DC01 represents the core Windows infrastructure.

Current state:

    Status:       Baseline ready
    IP:           192.168.100.20
    Hostname:     DC01
    OS:           Windows Server 2025 Standard

DC01 is currently a Windows Server installation.

It is NOT yet a Domain Controller.

Planned services:

- Active Directory Domain Services
- DNS
- DHCP

A clean baseline snapshot has been created before
role-specific configuration.


### WIN01

WIN01 represents an employee workstation.

Current state:

    Status:       Baseline ready
    IP:           192.168.100.30
    Hostname:     WIN01

WIN01 is currently a normal Windows client.

It has not been domain-joined.

Domain joining will happen only after Active Directory
has been configured on DC01.

Planned uses:

- domain login
- Group Policy testing
- software installation
- permissions testing
- remote support
- Windows troubleshooting
- incident simulation

A baseline snapshot has been created:

    win01-baseline


## 6. Core Infrastructure Relationships

The current Phase 0 infrastructure is:

    ARCH LINUX HOST
            |
        QEMU / KVM
            |
         libvirt
            |
     engineering-lab
    192.168.100.0/24
            |
    +-------+-------+-------+
    |               |       |
    v               v       v
 MINT01           DC01    WIN01
 .100.10          .100.20 .100.30
    |               |       |
    |          Windows      |
    |          Server       |
    |               |       |
    +---------------+-------+
                    |
                    v
          Future Windows Infrastructure
               AD / DNS / DHCP

The current architectural state:

    Virtualization       DONE
    Base networking      DONE
    MINT01               READY
    DC01                 BASELINE READY
    WIN01                BASELINE READY

    Active Directory     NOT IMPLEMENTED
    DNS                  NOT IMPLEMENTED
    DHCP Server          NOT IMPLEMENTED
    Domain               NOT IMPLEMENTED
    Group Policy         NOT IMPLEMENTED
    ITSM                 NOT IMPLEMENTED
    Cloud                NOT IMPLEMENTED
    Terraform            NOT IMPLEMENTED
    Automation           NOT IMPLEMENTED
    CI/CD                NOT IMPLEMENTED
    Monitoring           NOT IMPLEMENTED

The infrastructure is built incrementally.

Services are introduced only after their underlying
infrastructure and concepts have been understood.


## 7. Cloud

The project uses Floci as the primary local cloud laboratory.

The cloud architecture is based on AWS-style concepts.

The planned cloud environment includes, where supported
and justified:

    IAM
    S3
    SQS
    Lambda
    RDS
    Secrets

The cloud environment is intentionally scenario-driven.

The primary example is an engineering document workflow:

    Application
        |
        v
       S3
        |
        v
       SQS
        |
        v
      Lambda
        |
        +----> RDS
        |
        +----> Logging

Cloud implementation is outside the scope of Phase 0.


## 8. Infrastructure as Code and Automation

Terraform provides the Infrastructure as Code layer.

    Terraform
        |
        +-- Cloud Infrastructure

Automation is provided by:

    PowerShell
    Bash
    Python

GitHub Actions provides CI/CD automation for repository
and infrastructure workflows.

These components are planned for later phases.

Phase 0 focuses on establishing the infrastructure
foundation required by them.


## 9. Security and Troubleshooting

Security is treated as a cross-cutting concern rather than
a standalone final component.

The architecture applies principles such as:

- least privilege
- authentication
- authorization
- secure secrets management
- access control
- auditing
- patch management

Troubleshooting is also a core part of the laboratory.

Infrastructure should not only be implemented and operated
in a working state.

Controlled failures and real implementation problems are
documented as troubleshooting cases.

    Incident / Failure
            |
            v
      Investigation
            |
            v
         Root Cause
            |
            v
            Fix
            |
            v
       Verification
            |
            v
       Documentation

Troubleshooting cases are stored under:

    docs/incidents/troubleshooting/

Phase 0 troubleshooting cases include:

    TRB-001
        libvirt / engineering-lab network definition issue

    TRB-002
        DHCP reservation / MINT01 static address issue

    TRB-003
        Windows ICMP firewall configuration

TRB-003 demonstrated that Windows machines could communicate
with the Linux workstation and gateway but initially could not
exchange ICMP traffic with each other because inbound ICMP
traffic was blocked by the Windows firewall.

After allowing ICMP traffic on both Windows machines,
bidirectional connectivity was verified.


## 10. Documentation

Documentation is a first-class component of the laboratory.

The documentation should describe:

- architecture
- infrastructure
- procedures
- troubleshooting
- incidents
- cloud services
- security
- disaster recovery
- future extensions

The documentation structure is designed to evolve together
with the infrastructure.

Documentation follows this principle:

    Architecture
        =
    what the system is and why it is designed this way

    Infrastructure
        =
    what is actually deployed

    Procedures
        =
    how to perform administrative tasks

    Incidents / Troubleshooting
        =
    failures, investigation and root cause


## 11. Phase 0 Completion State

Phase 0 establishes the foundation of the laboratory.

The completed foundation is:

    Repository
        |
        +-- Documentation structure
        |
        +-- Architecture documentation
        |
        +-- Git workflow
        |
        +-- Virtualization
        |
        +-- libvirt system management
        |
        +-- engineering-lab network
        |
        +-- MINT01
        |
        +-- DC01
        |
        +-- WIN01
        |
        +-- DHCP reservations
        |
        +-- VM networking verification
        |
        +-- Baseline snapshots
        |
        +-- Troubleshooting documentation

Phase 0 does NOT implement the Windows infrastructure
services yet.

The next phase will begin the Windows infrastructure
configuration on DC01.


## 12. Design Principles

The laboratory follows several core principles:

    REALISM OVER COMPLEXITY

    UNDERSTANDING OVER COMMAND MEMORIZATION

    SCENARIOS OVER ISOLATED TECHNOLOGIES

    TROUBLESHOOTING AS A FIRST-CLASS SKILL

    SECURITY FROM THE BEGINNING

    DOCUMENT IMPORTANT DECISIONS

    AUTOMATE AFTER UNDERSTANDING

    KEEP THE LAB REPRODUCIBLE

    AVOID UNNECESSARY COST

    DO NOT OVERBUILD THE ENVIRONMENT

Every major component should have a reason to exist.

The goal is not to build the largest possible infrastructure.

The goal is to build a coherent environment that can be
understood, administered, troubleshot and documented.
