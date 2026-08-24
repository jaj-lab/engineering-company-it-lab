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

```text
ENGINEERING COMPANY IT LAB
│
├── On-Premises Infrastructure
│   ├── Virtualization
│   ├── Networking
│   ├── Windows Server
│   ├── Active Directory
│   ├── Windows Clients
│   └── File Services
│
├── ITSM
│   ├── Tickets
│   ├── Incidents
│   ├── Assets
│   ├── Software
│   └── Licenses
│
├── Cloud
│   └── Floci
│
├── Infrastructure as Code
│   └── Terraform
│
├── Automation
│   ├── PowerShell
│   ├── Bash
│   └── Python
│
├── CI/CD
│   └── GitHub Actions
│
├── Monitoring
│
└── Security


## 3. Host and Virtualization

```text
HOST
│
└── Arch Linux
      │
      └── QEMU/KVM
            │
            └── libvirt
                  │
                  └── engineering-lab
                        ├── MINT01
                        ├── DC01
                        └── WIN01
