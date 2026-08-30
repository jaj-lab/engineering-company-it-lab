# Domain Join Procedure

## Purpose

This procedure describes how to join a Windows workstation to the `engineering.local` Active Directory domain.

The procedure is designed for the Engineering Lab environment and assumes that:

* `DC01` is the Active Directory Domain Controller.
* `DC01` provides Active Directory-integrated DNS.
* `DC01` uses the address `192.168.100.20`.
* The domain is `engineering.local`.
* Domain workstations are organized under:

```text
OU=Workstations,OU=Engineering Company,DC=engineering,DC=local
```

The workstation must be able to locate the Domain Controller through DNS before attempting the domain join.

---

## Environment

```text
                    engineering.local
                           |
                           |
                    +------+------+
                    |     DC01    |
                    |  AD DS/DNS  |
                    | 192.168.100.20
                    +------+------+
                           |
                    engineering-lab
                    192.168.100.0/24
                           |
                       +---+---+
                       | WIN01 |
                       | .30   |
                       +-------+
```

### Domain

```text
Domain:
    engineering.local

NetBIOS:
    ENGINEERING
```

### Domain Controller

```text
Hostname:
    DC01

FQDN:
    DC01.engineering.local

IPv4:
    192.168.100.20
```

### Workstation

```text
Hostname:
    WIN01

IPv4:
    192.168.100.30

Gateway:
    192.168.100.1

DNS:
    192.168.100.20
```

---

# Procedure

## 1. Verify workstation identity

Confirm the workstation has the expected hostname and is currently in a workgroup.

```powershell
hostname
```

Then:

```powershell
Get-CimInstance Win32_ComputerSystem |
    Select-Object `
        Name,
        Domain,
        PartOfDomain,
        DomainRole
```

Expected state:

```text
Name:
    WIN01

Domain:
    WORKGROUP

PartOfDomain:
    False
```

The workstation should not already be joined to another domain.

---

## 2. Verify network configuration

Inspect the workstation's network configuration:

```powershell
Get-NetIPConfiguration
```

Confirm:

```text
IPv4:
    192.168.100.30/24

Default Gateway:
    192.168.100.1

DNS:
    192.168.100.20
```

The workstation must use the Domain Controller as its DNS server.

### Important

Do not configure the workstation to use a public DNS resolver such as:

```text
8.8.8.8
1.1.1.1
```

as its primary DNS server for Active Directory operations.

The expected path is:

```text
WIN01
    |
    +-- DNS query
           |
           v
        DC01
    192.168.100.20
           |
           +-- AD-integrated DNS
           |
           +-- engineering.local
           |
           +-- _msdcs.engineering.local
```

Active Directory depends on DNS records, including SRV records, to locate domain services.

---

## 3. Verify gateway and Domain Controller connectivity

Test the local gateway:

```powershell
Test-Connection 192.168.100.1 -Count 2
```

Test the Domain Controller:

```powershell
Test-Connection 192.168.100.20 -Count 2
```

Both should succeed.

---

## 4. Verify DNS resolution

Resolve the AD domain:

```powershell
Resolve-DnsName engineering.local
```

Resolve the Domain Controller:

```powershell
Resolve-DnsName DC01.engineering.local
```

Expected result:

```text
DC01.engineering.local
    -> 192.168.100.20
```

---

## 5. Verify Active Directory service discovery

Active Directory clients use DNS SRV records to locate domain services.

Verify the LDAP SRV record:

```powershell
Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV
```

The record should identify:

```text
dc01.engineering.local
```

as the Domain Controller.

---

## 6. Discover the Domain Controller

Use `nltest` to verify that Windows can locate the Domain Controller:

```powershell
nltest /dsgetdc:engineering.local
```

Expected result should identify:

```text
DC:
    DC01.engineering.local

Address:
    192.168.100.20

Domain:
    engineering.local
```

If Domain Controller discovery fails, do not continue with the domain join.

Investigate DNS and network connectivity first.

---

## 7. Verify required network services

Verify DNS:

```powershell
Test-NetConnection 192.168.100.20 -Port 53
```

Verify LDAP:

```powershell
Test-NetConnection 192.168.100.20 -Port 389
```

Both should report a successful TCP connection.

---

# 8. Join the workstation to the domain

Once all prerequisite checks succeed, join the workstation to:

```text
engineering.local
```

The domain can be joined through the Windows GUI or PowerShell.

### PowerShell

```powershell
Add-Computer `
    -DomainName "engineering.local" `
    -Credential "ENGINEERING\Administrator" `
    -Restart
```

Windows will request the credentials of an account authorized to join computers to the domain.

The workstation will restart after the operation.

> Use an appropriate delegated domain account in a real environment rather than routinely using Domain Administrator credentials.

---

# 9. Authenticate using a domain account

After reboot, select a domain account and authenticate using the:

```text
ENGINEERING
```

domain.

For example:

```text
ENGINEERING\alice.miller
```

or:

```text
alice.miller@engineering.local
```

The account must already exist in Active Directory and must be enabled.

---

# 10. Verify domain membership

After logging in, verify the workstation's domain state:

```powershell
Get-CimInstance Win32_ComputerSystem |
    Select-Object `
        Name,
        Domain,
        PartOfDomain,
        DomainRole
```

Expected result:

```text
Name:
    WIN01

Domain:
    engineering.local

PartOfDomain:
    True
```

Verify the current identity:

```powershell
whoami
```

Expected format:

```text
engineering\username
```

---

# 11. Verify domain controller discovery after the join

Run:

```powershell
nltest /dsgetdc:engineering.local
```

The workstation should continue to locate:

```text
DC01.engineering.local
```

Verify DNS:

```powershell
Resolve-DnsName DC01.engineering.local
```

And:

```powershell
Resolve-DnsName engineering.local
```

---

# 12. Move the computer object to the Workstations OU

Newly joined computers may initially appear in the default:

```text
CN=Computers
```

container.

Engineering Lab workstations should be placed in:

```text
OU=Workstations,OU=Engineering Company,DC=engineering,DC=local
```

This is important because the Workstations OU is the intended target for workstation-specific Group Policy.

### PowerShell

On a system with the Active Directory PowerShell module:

```powershell
Move-ADObject `
    -Identity "CN=WIN01,CN=Computers,DC=engineering,DC=local" `
    -TargetPath "OU=Workstations,OU=Engineering Company,DC=engineering,DC=local"
```

Verify:

```powershell
Get-ADComputer WIN01 |
    Select-Object Name, DistinguishedName
```

Expected location:

```text
OU=Workstations,OU=Engineering Company,DC=engineering,DC=local
```

---

# 13. Verify Group Policy processing

After moving the workstation to the Workstations OU, refresh Group Policy:

```powershell
gpupdate /force
```

Then generate a Resultant Set of Policy report:

```powershell
gpresult /h C:\Temp\WIN01-gpresult.html
```

The report should show the workstation receiving the policies linked to:

```text
OU=Workstations,OU=Engineering Company
```

In the Engineering Lab this includes:

```text
Engineering Workstation Baseline
```

which provides the workstation firewall baseline.

---

# Verification Checklist

```text
DOMAIN JOIN VERIFICATION
================================================================================

Identity
    [ ] Hostname is WIN01
    [ ] Previous WORKGROUP state confirmed
    [ ] Domain membership = engineering.local
    [ ] PartOfDomain = True

Network
    [ ] IPv4 = 192.168.100.30
    [ ] Gateway = 192.168.100.1
    [ ] DNS = 192.168.100.20

DNS
    [ ] engineering.local resolves
    [ ] DC01.engineering.local resolves
    [ ] LDAP SRV record resolves
    [ ] _ldap._tcp.dc._msdcs.engineering.local resolves

Active Directory
    [ ] Domain Controller discovered
    [ ] DC01.engineering.local identified
    [ ] LDAP connectivity verified
    [ ] Domain authentication successful

Computer Object
    [ ] WIN01 exists in Active Directory
    [ ] WIN01 moved to OU=Workstations
    [ ] Distinguished Name verified

Group Policy
    [ ] gpupdate completed successfully
    [ ] Engineering Workstation Baseline applied
    [ ] gpresult verified

RESULT
    DOMAIN JOIN COMPLETE
    WORKSTATION READY FOR DOMAIN OPERATIONS
```

---

# Troubleshooting

## Domain cannot be found

Check DNS first:

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

The DNS server should be:

```text
192.168.100.20
```

Then:

```powershell
Resolve-DnsName engineering.local
```

and:

```powershell
Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV
```

Finally:

```powershell
nltest /dsgetdc:engineering.local
```

---

## DNS resolves external names but domain join fails

External DNS resolution alone is not sufficient.

For example:

```powershell
Resolve-DnsName google.com
```

proving that DNS works does not prove that Active Directory service discovery works.

Verify:

```powershell
Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV
```

and:

```powershell
nltest /dsgetdc:engineering.local
```

---

## Domain Controller cannot be reached

Check:

```powershell
Test-Connection 192.168.100.20 -Count 2
```

Then:

```powershell
Test-NetConnection 192.168.100.20 -Port 53
```

and:

```powershell
Test-NetConnection 192.168.100.20 -Port 389
```

Investigate network connectivity, firewall configuration, and DNS before retrying the join.

---

## Computer object is in the wrong location

Check:

```powershell
Get-ADComputer WIN01 |
    Select-Object Name, DistinguishedName
```

If the object is still under:

```text
CN=Computers
```

move it to:

```text
OU=Workstations,OU=Engineering Company,DC=engineering,DC=local
```

Then refresh Group Policy:

```powershell
gpupdate /force
```

---

# Phase 3 Relationship

During Phase 3, WIN01's **domain-join prerequisites were successfully verified**.

The verification established:

```text
WIN01
    |
    +-- Correct hostname
    +-- Correct IP configuration
    +-- DNS -> 192.168.100.20
    +-- engineering.local resolves
    +-- DC01.engineering.local resolves
    +-- LDAP SRV record resolves
    +-- Domain Controller discovery succeeds
    +-- LDAP connectivity succeeds
    +-- DNS connectivity succeeds
```

This established that WIN01 was ready for domain joining.

The full join procedure above documents the standard operational workflow, including the subsequent computer-object placement and Group Policy verification.

---

# Operational Principle

The most important rule for an Active Directory domain join is:

```text
                DNS FIRST
                   |
                   v
            Find Domain Controller
                   |
                   v
          Verify AD connectivity
                   |
                   v
              Domain Join
                   |
                   v
          Domain Authentication
                   |
                   v
        Move Computer Object
                   |
                   v
          Apply / Verify GPO
```

If DNS is incorrectly configured, troubleshooting the domain join should begin with DNS rather than repeatedly attempting the join operation.
