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

## Cloud

The primary cloud laboratory is:

- Floci
- AWS-compatible APIs and concepts

Planned services include:

- IAM
- S3
- SQS
- Lambda
- RDS
- Secrets

## Repository Structure

```text
docs/          Documentation
ad/            Active Directory
windows/       Windows administration
networking/    Network configuration and documentation
terraform/     Infrastructure as Code
automation/    PowerShell / Bash / Python
cloud/         Cloud infrastructure
.github/       GitHub Actions
