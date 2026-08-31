# Engineering Company IT Lab

Hands-on IT infrastructure laboratory representing a small
international engineering company.

## Purpose

This project is designed to practice:

- IT Administration
- Virtualization
- Networking
- Windows / Active Directory
- ITSM / Help Desk
- Cloud
- Infrastructure as Code
- Automation
- CI/CD
- Monitoring
- Security
- Documentation

The goal is to build, administer, troubleshoot and document
a coherent IT environment rather than isolated technology demos.

## Architecture

The laboratory runs on an Arch Linux host using:

- QEMU/KVM
- libvirt
- virt-manager

Primary laboratory network:

- `engineering-lab`
- `192.168.100.0/24`

Initial virtual machines:

- `MINT01` — Linux Mint / IT Administration Workstation
- `DC01` — Windows Server / Active Directory / DNS / DHCP
- `WIN01` — Windows 10/11 / Domain-joined Employee Workstation

Additional VMs will be introduced only when required by
a specific architecture or learning scenario.

## Repository Structure

```text
engineering-company-it-lab/
|
├── README.md                 This file
|
├── docs/                     Documentation
│   ├── architecture/
│   ├── infrastructure/
│   ├── procedures/
│   ├── incidents/
│   ├── software/
│   ├── cloud/
│   ├── security/
│   ├── disaster-recovery/
│   └── todo.md
|
├── networking/               Network configuration and documentation
│   ├── configs/
│   └── documentation/
|
├── windows/                  Windows administration
│   ├── ad/
│   ├── dhcp/
│   ├── dns/
│   ├── gpo/
│   └── file-services/
|
├── cloud/                    Cloud infratructure
│   ├── floci/
│   ├── s3/
│   ├── sqs/
│   ├── lambda/
│   ├── rds/
│   └── iam/
|
├── terraform/                Infractructure as Code
│   ├── modules/
│   ├── environments/
│   ├── variables/
│   └── providers/
|
├── automation/               Scripts
│   ├── powershell/
│   ├── bash/
│   └── python/
|
└── .github/
    └── workflows/
```
