================================================================================
DOCUMENTATION PLAN
==================

## PURPOSE

This document defines how documentation is planned, reviewed and maintained
throughout the Engineering Company IT Lab roadmap.

Documentation is created from the actual implemented and verified state of
the laboratory.

The documentation workflow is:

```
PHASE IMPLEMENTATION
        |
        v
   VERIFICATION
        |
        v
REVIEW WHAT ACTUALLY EXISTS
        |
        v
IDENTIFY DOCUMENTATION NEEDED
        |
        v
CREATE / UPDATE DOCUMENTATION
        |
        v
  REVIEW FOR CONSISTENCY
        |
        v
   START NEXT PHASE
```

Documentation is therefore treated as a living part of the project rather
than as a predefined checklist of files.

Future documentation is intentionally approximate until the corresponding
implementation exists.

The laboratory implementation is the source of truth.

================================================================================
DOCUMENTATION PRINCIPLES
========================

1. Document implemented and verified infrastructure.

2. Clearly distinguish implemented state from planned architecture.

3. Do not create empty documentation files only because they appear in a
   planned documentation structure.

4. Update existing documentation when the actual implementation changes.

5. Create procedures when a repeatable administrative or operational task
   becomes meaningful.

6. Create incident documentation when a real or intentionally reproduced
   troubleshooting case occurs.

7. At the end of every phase, review documentation against the actual state
   of the laboratory.

8. Remove or update obsolete documentation when the architecture changes.

9. Future phases describe expected documentation areas, not guaranteed files.

10. Documentation should preserve understanding, decisions and operational
    knowledge, not merely record commands.

11. The project implementation is the source of truth for implementation
    status.

12. Documentation may describe planned architecture, prerequisites or future
    dependencies when explicitly identified as such. It must not claim that
    planned infrastructure is implemented or verified.

13. When an implementation changes an existing component, its existing
    documentation must be reviewed before creating additional documents.

14. Service-specific documentation should describe the final verified role of
    the service within the actual architecture.

15. Documentation structure may be changed, consolidated or simplified when
    the actual project architecture demonstrates that the previous structure
    is no longer appropriate.

================================================================================
DOCUMENTATION TYPES
===================

ARCHITECTURE
Describes what the system is, why it exists, and how major components
relate.

INFRASTRUCTURE
Describes what is actually deployed and its current configuration.

PROCEDURES
Describes repeatable administrative or operational tasks.

INCIDENTS
Describes failures, investigation, root cause, resolution and verification.

SOFTWARE
Describes software inventory and relevant licensing information.

CLOUD
Describes cloud-specific implementation and services.

SECURITY
Describes security controls, permissions and related operational
considerations.

DISASTER RECOVERY
Describes backup, restore and recovery procedures.

TODO
Describes planned work, extensions and unresolved tasks.

THIS DOCUMENT
Describes the documentation workflow and current documentation state.

================================================================================
CURRENT DOCUMENTATION TREE
==========================

The currently implemented documentation is:

docs/
|
+-- architecture/
|    |
|    +-- active-directory.md
|    +-- cloud.md
|    +-- network.md
|    +-- overview.md
|    +-- virtualization.md
|
+-- cloud/
|    |
|    +-- app.md
|    +-- iam.md
|    +-- lambda.md
|    +-- rds.md
|    +-- s3.md
|    +-- sqs.md
|
+-- infrastructure/
|    |
|    +-- networking.md
|    +-- services.md
|    +-- vms.md
|
+-- procedures/
|    |
|    +-- create-user.md
|    +-- disable-user.md
|    +-- domain-join.md
|    +-- troubleshoot-dns.md
|
+-- incidents/
|    |
|    +-- INC-001-floci-docker-state-loss.md
|    +-- INC-002-floci-lambda-exec-failure.md
|    +-- INC-003-compose-consolidation-data-loss.md
|    +-- INC-004-smb-limited-access-permissions.md
|    |
|    +-- troubleshooting/
|         |
|         +-- TRB-001-libvirt-network-bridge.md
|         +-- TRB-002-libvirt-network-runtime-configuration.md
|         +-- TRB-003-windows-icmp-firewall.md
|
+-- security/
|    |
|    +-- permissions.md
|
+-- software/
|    |
|    +-- catalog.md
|
+-- disaster-recovery/
|    |
|    +-- [currently empty]
|
+-- docs-mapping.md
|    -> TEMPORARY DOCUMENTATION TRACKING
|
+-- docs-plan.md
|    -> THIS DOCUMENT
|
+-- todo.md
|    -> ACTIVE PROJECT TODO

The current tree represents the actual documentation state.

It is not a requirement that every documentation category contain a file.

Files may be added, removed or consolidated when the implementation changes.

================================================================================
PHASE 0 — LAB FOUNDATION
========================

STATUS:

```
COMPLETE
```

## IMPLEMENTATION AREAS

```
Project architecture
QEMU/KVM
libvirt
virt-manager
VM creation
VM resource allocation
VM snapshots
engineering-lab network
initial VM networking
Git repository
repository structure
documentation structure
initial troubleshooting
project TODO
```

DOCUMENTATION:

```
architecture/overview.md
    -> CREATED

architecture/virtualization.md
    -> CREATED

infrastructure/vms.md
    -> CREATED

infrastructure/networking.md
    -> CREATED

todo.md
    -> CREATED / ACTIVE
```

## PHASE 0 RESULT

The virtualization and initial laboratory infrastructure foundation
was implemented and documented.

Additional documentation was deferred until the corresponding
infrastructure existed.

================================================================================
PHASE 1 — NETWORKING
====================

STATUS:

```
COMPLETE
```

## IMPLEMENTATION AREAS

```
libvirt network
engineering-lab
IP addressing
CIDR
DHCP
DNS
routing
NAT
firewall basics
connectivity troubleshooting
network troubleshooting methodology
```

## DOCUMENTATION REVIEW

The Phase 1 implementation was reviewed against the existing
documentation.

The following documentation was created or updated:

```
architecture/network.md
    -> UPDATED

infrastructure/networking.md
    -> UPDATED

incidents/troubleshooting/TRB-001-libvirt-network-bridge.md
    -> DOCUMENTED

incidents/troubleshooting/TRB-002-libvirt-network-runtime-configuration.md
    -> DOCUMENTED

incidents/troubleshooting/TRB-003-windows-icmp-firewall.md
    -> DOCUMENTED
```

## PHASE 1 RESULT

```
Network architecture
    VERIFIED

IP addressing
    IMPLEMENTED

DHCP
    IMPLEMENTED AND VERIFIED

DNS
    IMPLEMENTED FOR CURRENT LAB ARCHITECTURE

Routing / NAT
    IMPLEMENTED AND VERIFIED

Firewall behavior
    VERIFIED

VM connectivity
    VERIFIED

Network documentation
    COMPLETE

Troubleshooting documentation
    COMPLETE
```

================================================================================
PHASE 2 — CLOUD
===============

STATUS:

```
COMPLETE
```

## OBJECTIVE

Build a realistic AWS-style document-processing workflow inside Floci.

## IMPLEMENTED AREAS

```
[x] Cloud foundation
[x] Docker / Docker Compose
[x] Floci
[x] IAM
[x] S3
[x] SQS
[x] Lambda
[x] PostgreSQL / RDS
[x] Secrets integration
[x] CloudWatch / Lambda logging
[x] Application integration
[x] Document-processing workflow
[x] Cloud troubleshooting
```

DOCUMENTATION:

```
architecture/cloud.md
    -> COMPLETE

cloud/app.md
    -> COMPLETE

cloud/iam.md
    -> COMPLETE

cloud/s3.md
    -> COMPLETE

cloud/sqs.md
    -> COMPLETE

cloud/lambda.md
    -> COMPLETE

cloud/rds.md
    -> COMPLETE
```

INCIDENTS:

```
INC-001 — Floci Docker State Loss
    -> DOCUMENTED

INC-002 — Floci Lambda Execution Failure
    -> DOCUMENTED

INC-003 — Compose Consolidation Data Loss
    -> DOCUMENTED
```

## CLOUD DOCUMENTATION NOTE

Secrets and logging are documented through the relevant cloud service and
architecture documentation.

Dedicated documentation files are not required merely because a cloud
service exists.

The current repository therefore does not contain separate:

```
cloud/secrets-manager.md

cloud/logging.md
```

The documentation structure reflects the actual scope of the implemented
cloud architecture rather than the original planning structure.

## PHASE 2 RESULT

The cloud implementation and its relevant documentation were reviewed
against the implemented state.

Cloud architecture and service documentation are considered complete.

================================================================================
PHASE 3 — WINDOWS / ACTIVE DIRECTORY
====================================

STATUS:

```
COMPLETE
```

## OBJECTIVE

Transform the standalone Windows environment into a managed company
domain environment.

## IMPLEMENTED AREAS

```
[x] Active Directory Domain Services
[x] DNS
[x] DHCP
[x] ENGINEERING domain
[x] Organizational Units
[x] Domain users
[x] Security groups
[x] Group Policy
[x] WIN01 domain join
[x] Windows administration
[x] SMB file shares
[x] NTFS permissions
[x] SMB share permissions
[x] GPO verification
[x] SMB access verification
[x] Windows / AD troubleshooting
```

## DOCUMENTATION REVIEW

The Phase 3 implementation was reviewed against the actual verified
laboratory state.

Architecture:

```
architecture/active-directory.md
    -> COMPLETE
```

Infrastructure:

```
infrastructure/services.md
    -> COMPLETE

infrastructure/networking.md
    -> UPDATED

infrastructure/vms.md
    -> UPDATED
```

Procedures:

```
procedures/create-user.md
    -> COMPLETE

procedures/disable-user.md
    -> COMPLETE

procedures/domain-join.md
    -> COMPLETE

procedures/troubleshoot-dns.md
    -> COMPLETE
```

Security:

```
security/permissions.md
    -> COMPLETE
```

Incidents:

```
incidents/INC-004-smb-limited-access-permissions.md
    -> COMPLETE
```

Architecture review:

```
architecture/network.md
    -> UPDATED

architecture/overview.md
    -> UPDATED
```

## PHASE 3 VERIFICATION

```
[x] DC01 provides AD DS
[x] DNS resolution verified
[x] DHCP server authorized in AD
[x] DHCP scope configured
[x] DHCP reservation configured for WIN01
[x] WIN01 receives DHCP configuration
[x] WIN01 resolves engineering.local
[x] WIN01 resolves DC01
[x] WIN01 resolves AD LDAP SRV records
[x] DC discovery succeeds
[x] WIN01 communicates with DC01
[x] WIN01 is domain joined
[x] Domain user authentication verified
[x] Security group membership verified
[x] Group Policy applied
[x] User restrictions verified
[x] SYSVOL accessible
[x] NETLOGON available
[x] SMB shares accessible
[x] SMB permissions verified
```

## PHASE 3 INCIDENT / TROUBLESHOOTING REVIEW

```
[x] SMB share access restriction identified
[x] SMB share-level permissions investigated
[x] NTFS permissions investigated
[x] Root cause identified
[x] SMB permissions corrected
[x] Access re-tested successfully
```

## PHASE 3 NETWORKING CHANGE

The Phase 3 implementation changed the DHCP architecture.

Previously:

```
libvirt
    |
    +-- DHCP
    +-- DNS forwarding
```

Current:

```
DC01
    |
    +-- DHCP
    +-- Active Directory DNS
```

libvirt continues to provide:

```
192.168.100.1
    -> NAT gateway
```

The libvirt DHCP service was removed from the engineering-lab network.

Current DHCP architecture:

```
DC01
    |
    +-- DHCP scope
    |     192.168.100.50 - 192.168.100.100
    |
    +-- WIN01 reservation
    |     192.168.100.30
    |
    +-- DNS
          192.168.100.20
```

This change required the following documentation updates:

```
architecture/network.md
    -> UPDATED

infrastructure/networking.md
    -> UPDATED

infrastructure/vms.md
    -> UPDATED

architecture/overview.md
    -> UPDATED
```

## PHASE 3 DOCUMENTATION RESULT

```
IMPLEMENTATION ................. COMPLETE
VERIFICATION ................... COMPLETE
INCIDENT DOCUMENTATION ......... COMPLETE
ARCHITECTURE DOCUMENTATION ..... COMPLETE
INFRASTRUCTURE DOCUMENTATION ... COMPLETE
PROCEDURES ..................... COMPLETE
SECURITY DOCUMENTATION ......... COMPLETE
```

PHASE 3 DOCUMENTATION:

```
COMPLETE
```

================================================================================
DOCUMENTATION AUDIT — PHASE 3
=============================

The final Phase 3 documentation review confirmed that the documentation
matches the current implemented architecture.

CURRENT DOCUMENTATION:

```
architecture/
    overview.md
    virtualization.md
    network.md
    active-directory.md
    cloud.md

infrastructure/
    vms.md
    networking.md
    services.md

procedures/
    create-user.md
    disable-user.md
    domain-join.md
    troubleshoot-dns.md

security/
    permissions.md

software/
    catalog.md

cloud/
    app.md
    iam.md
    lambda.md
    rds.md
    s3.md
    sqs.md

incidents/
    INC-001
    INC-002
    INC-003
    INC-004
    TRB-001
    TRB-002
    TRB-003
```

REMOVED / NOT CREATED:

```
procedures/reset-password.md
    -> NOT REQUIRED / REMOVED FROM DOCUMENTATION PLAN

cloud/secrets-manager.md
    -> NOT PRESENT; secrets are documented through existing
       cloud documentation

cloud/logging.md
    -> NOT REQUIRED AT CURRENT SCOPE

security/baseline.md
    -> NOT REQUIRED AT CURRENT SCOPE

security/incident-response.md
    -> NOT REQUIRED AT CURRENT SCOPE

software/licensing.md
    -> NOT REQUIRED AT CURRENT SCOPE

disaster-recovery/backup.md
    -> NOT YET IMPLEMENTED

disaster-recovery/restore.md
    -> NOT YET IMPLEMENTED
```

The absence of these files is intentional.

================================================================================
DOCUMENTATION STATUS AFTER PHASE 3
==================================

IMPLEMENTED AND DOCUMENTED:

```
Virtualization
    COMPLETE

Networking
    COMPLETE

Cloud
    COMPLETE

Active Directory
    COMPLETE

DNS
    COMPLETE

DHCP
    COMPLETE

Windows infrastructure
    COMPLETE

Group Policy
    COMPLETE

SMB / NTFS permissions
    COMPLETE

Administrative procedures
    COMPLETE

Security permissions
    COMPLETE

Incident / troubleshooting documentation
    COMPLETE
```

CURRENT DOCUMENTATION QUALITY STATE:

```
Architecture
    REVIEWED

Infrastructure
    REVIEWED

Procedures
    REVIEWED

Security
    REVIEWED

Incidents
    REVIEWED

Cloud
    REVIEWED

Documentation consistency
    REVIEWED
```

PHASE 3 DOCUMENTATION IS COMPLETE.

================================================================================
PHASE 4 — IT OPERATIONS
=======================

STATUS:

```
PLANNED
```

## OBJECTIVE

Build realistic day-to-day IT administration workflows around the
infrastructure already created.

POTENTIAL IMPLEMENTATION AREAS:

```
User lifecycle
Workstation lifecycle
Software deployment
Access management
Backup operations
Recovery operations
Patch management
Administrative workflows
Operational support
```

## DOCUMENTATION REVIEW

At the end of Phase 4, review the actual implemented workflows.

Potential documentation areas:

```
procedures/
    user lifecycle
    workstation lifecycle
    software installation
    access management
    backup / recovery

infrastructure/
    operational services

incidents/
    operational incidents

security/
    access-control procedures
```

Only create documentation for workflows that are actually implemented
and verified.

================================================================================
PHASE 5 — AUTOMATION / IaC
==========================

STATUS:

```
PLANNED
```

## OBJECTIVE

Automate repeatable infrastructure and operational tasks.

POTENTIAL IMPLEMENTATION AREAS:

```
Terraform
Infrastructure definitions
Configuration automation
PowerShell
Bash
Python
Git workflows
CI/CD
Infrastructure validation
Automated operations
```

## DOCUMENTATION REVIEW

Review the automation actually implemented during the phase.

Potential documentation areas:

```
infrastructure/
procedures/
cloud/
security/
```

Terraform documentation should only be created when Terraform becomes
part of the actual implementation.

Automation introduced earlier for a concrete implementation task may
also be documented at that time.

================================================================================
PHASE 6 — ITSM
==============

STATUS:

```
PLANNED
```

## OBJECTIVE

Introduce structured IT service management around the existing
infrastructure and operational workflows.

POTENTIAL IMPLEMENTATION AREAS:

```
ITSM platform
Users / organizations
Tickets
Incidents
Service requests
Assets
Knowledge base
Change management
Operational workflows
```

## DOCUMENTATION REVIEW

Create documentation according to the actual ITSM platform and workflows
implemented.

Potential areas include:

```
software/
procedures/
incidents/
architecture/
```

================================================================================
PHASE 7 — MONITORING
====================

STATUS:

```
PLANNED
```

## OBJECTIVE

Introduce infrastructure monitoring, observability and operational
visibility.

POTENTIAL IMPLEMENTATION AREAS:

```
Host monitoring
VM monitoring
Service monitoring
Network monitoring
Logs
Metrics
Alerting
Dashboards
Incident integration
```

## DOCUMENTATION REVIEW

Create documentation based on the monitoring system actually implemented.

Potential areas:

```
infrastructure/
procedures/
security/
incidents/
```

Important:

```
Phase 2 cloud logging is already implemented.

Phase 7 is intended to introduce broader infrastructure monitoring
and observability.

Existing Lambda / CloudWatch logging must not be treated as completion
of the future monitoring phase.
```

================================================================================
PHASE 8 — FINAL INTEGRATION
===========================

STATUS:

```
PLANNED
```

## OBJECTIVE

Connect the individual project phases into one coherent company
IT environment.

POTENTIAL INTEGRATION:

```
Networking
Cloud
Windows / AD
IT Operations
Automation / IaC
ITSM
Monitoring
Security
Backup / Recovery
Documentation
Operational workflows
```

## DOCUMENTATION REVIEW

Perform a complete documentation audit.

Compare:

```
ARCHITECTURE
      |
      v
ACTUAL INFRASTRUCTURE
      |
      v
PROCEDURES
      |
      v
INCIDENTS
      |
      v
SECURITY
      |
      v
DISASTER RECOVERY
```

During the final review:

```
Remove obsolete information.

Correct inaccurate information.

Document important missing components.

Resolve contradictions between architecture and implementation.

Move future work into:

    todo.md
```

Phase 8 is the major consistency review of the complete documentation
set.

================================================================================
FUTURE IMPLEMENTATIONS
======================

There is no fixed documentation plan beyond the current roadmap.

For every new feature:

```
TODO
  |
  v
REASON
  |
  v
PREREQUISITES
  |
  v
IMPLEMENTATION
  |
  v
VERIFICATION
  |
  v
TROUBLESHOOTING
  |
  v
DOCUMENTATION REVIEW
  |
  v
UPDATE DOCUMENTATION
  |
  v
COMMIT
```

Documentation for future features is decided when the feature actually
becomes part of the laboratory.

================================================================================
END-OF-PHASE DOCUMENTATION WORKFLOW
===================================

Every future phase follows the same process:

```
+-------------------------+
| Complete phase work     |
+------------+------------+
             |
             v
+-------------------------+
| Verify implementation   |
+------------+------------+
             |
             v
+-------------------------+
| Review actual state     |
+------------+------------+
             |
             v
+-------------------------+
| Identify documentation  |
| actually required       |
+------------+------------+
             |
             v
+-------------------------+
| Create / update docs    |
+------------+------------+
             |
             v
+-------------------------+
| Review consistency      |
+------------+------------+
             |
             v
+-------------------------+
| Start next phase        |
+-------------------------+
```

================================================================================
CURRENT PROJECT POSITION
========================

Current phase:

```
PHASE 3 — WINDOWS / ACTIVE DIRECTORY
```

Current phase status:

```
COMPLETE
```

Completed phases:

```
PHASE 0 — LAB FOUNDATION
    COMPLETE

PHASE 1 — NETWORKING
    COMPLETE

PHASE 2 — CLOUD
    COMPLETE

PHASE 3 — WINDOWS / ACTIVE DIRECTORY
    COMPLETE
```

CURRENT PHASE 3 STATE:

```
Active Directory
    COMPLETE

DNS
    COMPLETE

DHCP
    COMPLETE

Domain
    COMPLETE

Organizational Units
    COMPLETE

Users / Groups
    COMPLETE

Group Policy
    COMPLETE

WIN01 domain join
    COMPLETE

SMB
    COMPLETE

NTFS / SMB permissions
    COMPLETE

Troubleshooting
    COMPLETE

Documentation
    COMPLETE
```

CURRENT DOCUMENTATION:

```
Architecture
    COMPLETE

Infrastructure
    COMPLETE

Procedures
    COMPLETE

Security
    COMPLETE

Cloud
    COMPLETE

Incidents / Troubleshooting
    COMPLETE
```

CURRENT PROJECT POSITION:

```
PHASE 3
    IMPLEMENTATION COMPLETE
    DOCUMENTATION COMPLETE
```

NEXT PHASE:

```
PHASE 4 — IT OPERATIONS
    PLANNED
```

IMPORTANT:

```
The documentation is now synchronized with the verified Phase 3
implementation.

Future documentation must be created from the actual implementation
rather than from assumptions about what a future phase may contain.

Do not create documentation merely because a technology, directory
or future task is planned.

Do not treat the existence of a documentation file as proof that
corresponding infrastructure is implemented.

When an implementation changes an existing component, update the
existing documentation before creating additional documentation.

Keep the documentation set coherent, minimal and representative of
the actual laboratory.
```

================================================================================
END OF DOCUMENTATION PLAN
=========================
