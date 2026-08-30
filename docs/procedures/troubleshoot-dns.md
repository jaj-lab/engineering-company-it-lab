# Troubleshoot DNS

## Purpose

This procedure provides a structured workflow for diagnosing DNS-related problems in the Engineering Lab Active Directory environment.

DNS is a critical dependency of Active Directory. Domain clients use DNS not only to resolve hostnames, but also to locate Active Directory services through DNS SRV records.

A domain problem should therefore be investigated through DNS before assuming that Active Directory itself is malfunctioning.

---

# Environment

```text
                    engineering.local
                           |
                           v
                    +-------------+
                    |     DC01    |
                    | AD DS + DNS  |
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

### DNS architecture

```text
WIN01
  |
  | DNS queries
  v
DC01
192.168.100.20
  |
  +-- engineering.local
  +-- _msdcs.engineering.local
  +-- AD service records
  |
  +-- Forwarder
       |
       v
    192.168.100.1
       |
       v
    External DNS
```

The workstation should use:

```text
DNS server:
    192.168.100.20
```

The Domain Controller provides internal AD DNS and forwards external queries through:

```text
192.168.100.1
```

---

# Why DNS Matters to Active Directory

Ordinary hostname resolution is only one part of Active Directory DNS.

A client must be able to discover services such as LDAP and the Domain Controller itself.

For example:

```text
engineering.local
        |
        v
    Domain name
```

```text
DC01.engineering.local
        |
        v
    Domain Controller
```

and:

```text
_ldap._tcp.dc._msdcs.engineering.local
        |
        v
    Active Directory service discovery
        |
        v
    DC01.engineering.local
```

Therefore:

```text
google.com resolves
```

does **not** prove that Active Directory DNS is working.

The following must also work:

```text
engineering.local
DC01.engineering.local
_ldap._tcp.dc._msdcs.engineering.local
```

---

# Troubleshooting Decision Tree

```text
Domain / AD problem
        |
        v
Check client DNS configuration
        |
        +-- Wrong DNS
        |      |
        |      +-- Configure DNS -> DC01
        |
        v
Resolve engineering.local
        |
        +-- FAIL
        |      |
        |      +-- Investigate DC DNS
        |
        v
Resolve DC01.engineering.local
        |
        +-- FAIL
        |      |
        |      +-- Investigate DC hostname record
        |
        v
Resolve AD LDAP SRV record
        |
        +-- FAIL
        |      |
        |      +-- Investigate AD-integrated DNS
        |
        v
nltest /dsgetdc
        |
        +-- FAIL
        |      |
        |      +-- Check DNS
        |      +-- Check connectivity
        |      +-- Check AD services
        |
        v
Test required ports
        |
        +-- FAIL
        |      |
        |      +-- Investigate network/firewall
        |
        v
Retest domain functionality
```

---

# Procedure

## 1. Check the client's configured DNS server

On the affected Windows client:

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

For a domain workstation such as WIN01, the expected DNS server is:

```text
192.168.100.20
```

If the client is using an external resolver such as:

```text
8.8.8.8
1.1.1.1
```

or another non-AD DNS server, correct the configuration before continuing.

### Principle

```text
Domain client
    |
    +-- DNS -> Domain Controller
```

not:

```text
Domain client
    |
    +-- DNS -> Public DNS
```

Public DNS may resolve Internet names while having no knowledge of the private Active Directory DNS namespace.

---

# 2. Test basic network connectivity to DC01

Before troubleshooting DNS itself, confirm that the client can reach the Domain Controller.

```powershell
Test-Connection 192.168.100.20 -Count 2
```

If this fails, investigate network connectivity before continuing with DNS troubleshooting.

Possible areas:

```text
Client IP configuration
    |
    +-- Subnet
    +-- Gateway
    +-- Network adapter
    +-- Virtual network
    +-- Firewall
```

---

# 3. Resolve the Active Directory domain

Test the internal domain name:

```powershell
Resolve-DnsName engineering.local
```

Expected result:

```text
engineering.local
    -> 192.168.100.20
```

If this fails, the client cannot successfully resolve the AD domain.

Check:

```text
Client DNS configuration
        |
        v
192.168.100.20
        |
        v
DC01 DNS service
        |
        v
engineering.local zone
```

---

# 4. Resolve the Domain Controller hostname

Test:

```powershell
Resolve-DnsName DC01.engineering.local
```

Expected result:

```text
DC01.engineering.local
    -> 192.168.100.20
```

If `engineering.local` resolves but `DC01.engineering.local` does not, investigate the DNS records on DC01.

On the Domain Controller:

```powershell
Get-DnsServerZone
```

The expected internal zone includes:

```text
engineering.local
```

The AD DNS infrastructure also includes:

```text
_msdcs.engineering.local
```

---

# 5. Verify the Active Directory LDAP SRV record

This is one of the most important checks.

Run:

```powershell
Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV
```

The result should identify:

```text
dc01.engineering.local
```

as an LDAP service target.

Conceptually:

```text
_ldap._tcp.dc._msdcs.engineering.local
                |
                v
        DC01.engineering.local
                |
                v
         192.168.100.20
```

If the normal hostname resolves but the SRV record does not, basic DNS is functioning but Active Directory service discovery may be broken.

---

# 6. Test Domain Controller discovery

Run:

```powershell
nltest /dsgetdc:engineering.local
```

This asks Windows to locate a Domain Controller for the domain.

Expected result identifies:

```text
DC01.engineering.local
192.168.100.20
engineering.local
```

If this fails while ordinary DNS resolution works, investigate:

```text
DNS SRV records
        |
        v
AD-integrated DNS
        |
        v
AD DS / Netlogon
        |
        v
Domain Controller discovery
```

---

# 7. Test DNS connectivity

Verify TCP connectivity to the DNS service:

```powershell
Test-NetConnection 192.168.100.20 -Port 53
```

A successful result indicates that the client can establish TCP connectivity to DNS on DC01.

This test should be considered together with actual DNS resolution.

A successful TCP connection to port 53 does not by itself prove that the DNS configuration or records are correct.

---

# 8. Test LDAP connectivity

Verify LDAP connectivity:

```powershell
Test-NetConnection 192.168.100.20 -Port 389
```

A successful result confirms that the client can reach LDAP on the Domain Controller.

This helps distinguish:

```text
DNS problem
```

from:

```text
Network / firewall / service problem
```

---

# 9. Verify DNS configuration on DC01

If the problem appears to originate from the Domain Controller, inspect its DNS configuration.

### DNS zones

```powershell
Get-DnsServerZone
```

Expected AD-related zones include:

```text
engineering.local
_msdcs.engineering.local
DomainDnsZones.engineering.local
ForestDnsZones.engineering.local
```

### DNS forwarders

```powershell
Get-DnsServerForwarder
```

The Engineering Lab uses:

```text
192.168.100.1
```

as the DNS forwarder for external queries.

### DC01 DNS client configuration

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

DC01 should use itself as its DNS resolver:

```text
192.168.100.20
```

---

# 10. Test external DNS resolution through DC01

Internal DNS and external forwarding should both be functional.

From DC01 or a domain client:

```powershell
Resolve-DnsName google.com -Server 192.168.100.20
```

Expected result is successful external name resolution.

The flow is:

```text
Client
   |
   v
DC01 DNS
   |
   |-- Internal name?
   |       |
   |       +-- Answer from AD DNS
   |
   |-- External name?
           |
           v
       192.168.100.1
           |
           v
      External DNS
```

---

# 11. Verify DNS service on DC01

If DNS queries fail directly against DC01, verify that the DNS service is running.

```powershell
Get-Service DNS
```

Expected:

```text
Status:
    Running

StartType:
    Automatic
```

Also verify AD DS:

```powershell
Get-Service NTDS
```

Expected:

```text
Status:
    Running
```

If AD-integrated DNS records are missing or service discovery is failing, both DNS and AD DS should be considered during the investigation.

---

# Common Failure Scenarios

## Scenario 1 — Client uses the wrong DNS server

```text
WIN01
    |
    +-- DNS -> 8.8.8.8
```

Symptoms:

```text
google.com
    -> SUCCESS

engineering.local
    -> FAIL

DC01.engineering.local
    -> FAIL

nltest /dsgetdc
    -> FAIL
```

### Resolution

Configure the client to use:

```text
192.168.100.20
```

Then repeat the DNS tests.

---

## Scenario 2 — Domain resolves but SRV discovery fails

```text
engineering.local
    -> SUCCESS

DC01.engineering.local
    -> SUCCESS

_ldap._tcp.dc._msdcs.engineering.local
    -> FAIL
```

This suggests that basic hostname resolution works but Active Directory service discovery is not functioning correctly.

Investigate:

```text
AD-integrated DNS
DNS zones
SRV records
AD DS
Netlogon
```

---

## Scenario 3 — DNS works but Domain Controller discovery fails

```text
engineering.local
    -> SUCCESS

DC01.engineering.local
    -> SUCCESS

LDAP SRV
    -> SUCCESS

nltest /dsgetdc
    -> FAIL
```

Continue with:

```powershell
Test-NetConnection 192.168.100.20 -Port 53
```

and:

```powershell
Test-NetConnection 192.168.100.20 -Port 389
```

Then investigate the Domain Controller's AD DS and related services.

---

## Scenario 4 — DNS works but LDAP connectivity fails

```text
DNS resolution
    -> SUCCESS

Port 53
    -> SUCCESS

Port 389
    -> FAIL
```

This is less likely to be a DNS-record problem.

Investigate:

```text
Network connectivity
Firewall
LDAP service availability
Domain Controller health
```

---

# Diagnostic Command Set

For a quick first-pass investigation, run:

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4

Test-Connection 192.168.100.20 -Count 2

Resolve-DnsName engineering.local

Resolve-DnsName DC01.engineering.local

Resolve-DnsName `
    _ldap._tcp.dc._msdcs.engineering.local `
    -Type SRV

nltest /dsgetdc:engineering.local

Test-NetConnection 192.168.100.20 -Port 53

Test-NetConnection 192.168.100.20 -Port 389
```

Interpret the results in this order:

```text
DNS configuration
      |
      v
Basic network connectivity
      |
      v
Domain resolution
      |
      v
DC hostname resolution
      |
      v
AD SRV resolution
      |
      v
Domain Controller discovery
      |
      v
DNS / LDAP connectivity
```

---

# Verification Checklist

```text
DNS TROUBLESHOOTING CHECKLIST
================================================================================

Client
    [ ] Correct IP configuration
    [ ] DNS server = 192.168.100.20

Connectivity
    [ ] DC01 reachable
    [ ] TCP/53 reachable
    [ ] TCP/389 reachable

DNS
    [ ] engineering.local resolves
    [ ] DC01.engineering.local resolves
    [ ] _ldap._tcp.dc._msdcs.engineering.local resolves

Active Directory Discovery
    [ ] nltest /dsgetdc:engineering.local succeeds
    [ ] DC01 identified as Domain Controller

DC01
    [ ] DNS service running
    [ ] NTDS service running
    [ ] engineering.local zone present
    [ ] _msdcs infrastructure present
    [ ] DNS forwarder configured

External Resolution
    [ ] google.com resolves through DC01

RESULT
    DNS / AD SERVICE DISCOVERY FUNCTIONAL
```

---

# Phase 3 Reference

DNS verification was a fundamental part of the Phase 3 implementation.

The Engineering Lab verified:

```text
DC01.engineering.local
    -> 192.168.100.20

engineering.local
    -> 192.168.100.20

_ldap._tcp.dc._msdcs.engineering.local
    -> DC01.engineering.local
    -> 192.168.100.20
```

WIN01 was configured to use:

```text
192.168.100.20
```

as its DNS server and successfully performed:

```text
Domain resolution
    |
    v
DC resolution
    |
    v
LDAP SRV resolution
    |
    v
Domain Controller discovery
```

External DNS resolution was also verified through DC01 using the lab gateway (`192.168.100.1`) as the configured forwarder.

---

# Operational Principle

When troubleshooting an Active Directory domain problem:

```text
                    START
                      |
                      v
             What DNS is client using?
                      |
                      v
             Is it the AD DNS server?
                      |
                +-----+-----+
                |           |
               NO          YES
                |           |
          Fix DNS            v
                        Resolve domain
                              |
                              v
                         Resolve DC
                              |
                              v
                       Resolve SRV
                              |
                              v
                      Discover DC
                              |
                              v
                       Test ports
                              |
                              v
                    Check AD/DNS services
                              |
                              v
                         Retest
```

The key rule is:

> **For Active Directory, DNS is part of the directory infrastructure, not merely an Internet name-resolution service.**

When domain operations fail, verify DNS and AD service discovery before making unrelated configuration changes.
