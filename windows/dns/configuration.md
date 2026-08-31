# DNS Configuration

## 1. Domain

The laboratory Active Directory domain is:

```text
engineering.local
```

The DNS namespace is provided by the Active Directory-integrated DNS
service running on DC01.

```text
DNS domain:
    engineering.local

Domain Controller:
    DC01

IP:
    192.168.100.20
```

---

## 2. DNS Server

DNS is hosted on:

```text
DC01
192.168.100.20
```

DNS was installed as part of the Active Directory Domain Services
deployment and forest creation.

No separate standalone DNS server is used in the laboratory.

The Windows clients use DC01 as their primary DNS server.

---

## 3. DNS Zone

The primary Active Directory DNS zone is:

```text
engineering.local
```

The zone is associated with the Active Directory domain and is used
for internal name resolution.

Expected structure:

```text
engineering.local
├── DC01
├── WIN01
└── _msdcs
```

The Active Directory DNS records also include the service records
required for domain functionality.

---

## 4. Active Directory Integration

DNS provides the name-resolution infrastructure required by Active
Directory.

The domain controller publishes DNS records used by domain clients
to locate services such as:

```text
LDAP
Kerberos
Global Catalog
Domain Controllers
```

Active Directory service discovery relies on DNS SRV records.

For example:

```text
_ldap._tcp
_kerberos._tcp
```

These records allow domain-joined systems such as WIN01 to locate
DC01 and communicate with the Active Directory domain.

---

## 5. Client DNS Configuration

The laboratory DHCP server provides DC01 as the DNS server to
domain clients.

Current DNS configuration:

```text
DNS Server:
    192.168.100.20

DNS Domain:
    engineering.local
```

WIN01 receives this configuration through the DHCP scope configured
on DC01.

The resulting dependency is:

```text
WIN01
   |
   | DNS query
   v
DC01
192.168.100.20
   |
   v
engineering.local
```

---

## 6. Hostname Resolution

The laboratory requires internal name resolution for the primary
infrastructure systems.

Current hosts include:

```text
DC01
    192.168.100.20

WIN01
    192.168.100.30
```

DNS resolution is used by WIN01 for:

* Domain Controller discovery
* Active Directory authentication
* Kerberos
* LDAP
* Domain services
* Internal hostname resolution

---

## 7. Configuration Method

DNS was not configured through a separate standalone DNS deployment
script.

The initial DNS infrastructure was created automatically during
Active Directory forest/domain deployment on DC01.

The implementation sequence was:

```text
Install AD DS
      |
      v
Create new forest
      |
      v
engineering.local
      |
      v
DNS role / AD-integrated DNS
      |
      v
DNS zone and AD service records
```

Subsequent DNS configuration is managed as part of the Windows
Active Directory infrastructure.

---

## 8. Verification

The implemented DNS configuration was verified through the domain
environment.

Verified functionality includes:

```text
[x] DC01 provides DNS
[x] engineering.local zone exists
[x] WIN01 receives DC01 as DNS server
[x] WIN01 resolves engineering.local
[x] WIN01 locates DC01 through DNS SRV records
[x] Domain authentication works
[x] Active Directory services are reachable
```

DNS functionality was also validated during the WIN01 domain-join
and domain authentication process.

---

## 9. Relationship to Active Directory

DNS is a core dependency of the Active Directory environment.

The resulting architecture is:

```text
                    DC01
                     |
          +----------+----------+
          |                     |
         AD DS                  DNS
          |                     |
          +----------+----------+
                     |
              engineering.local
                     |
                    WIN01
```

Active Directory and DNS are therefore treated as one integrated
Windows infrastructure component rather than independent services.

The Active Directory architecture is documented in:

```text
docs/architecture/active-directory.md
```

The DHCP configuration that provides DNS settings to clients is
documented in:

```text
windows/dhcp/scope.md
```

---

## 10. Current State

The laboratory DNS infrastructure is:

```text
Status:
    IMPLEMENTED AND VERIFIED

DNS Server:
    DC01

DNS IP:
    192.168.100.20

DNS Domain:
    engineering.local

Integration:
    Active Directory

Client:
    WIN01

Client DNS:
    192.168.100.20
```

The actual Windows environment remains the source of truth.

If the domain, DNS topology, client configuration, or Active Directory
architecture changes, this document must be reviewed and updated.
