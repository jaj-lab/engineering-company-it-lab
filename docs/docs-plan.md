================================================================================
DOCUMENTATION PLAN
================================================================================

PURPOSE
-------

This document defines how documentation is planned and maintained
throughout the Engineering Company IT Lab roadmap.

Documentation is NOT created simply because a file exists in the
planned documentation tree.

At the end of each phase:

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
      UPDATE THIS PLAN
            |
            v
       START NEXT PHASE


The documentation plan is therefore a living plan.

Future documentation is intentionally approximate until the
corresponding phase is completed.

This prevents the documentation structure from becoming a
misrepresentation of the actual laboratory.


================================================================================
DOCUMENTATION PRINCIPLES
================================================================================

1. Document implemented and verified infrastructure.

2. Clearly distinguish planned architecture from implemented state.

3. Do not create empty documentation files only because they appear
   in the planned documentation tree.

4. Update existing documentation when the actual implementation changes.

5. Create procedures when a repeatable administrative task becomes
   meaningful.

6. Create incident documentation when a real or intentionally
   reproduced troubleshooting case occurs.

7. At the end of every phase, review documentation against the
   actual state of the laboratory.

8. After the review, update this document with the current state.

9. Future phases describe expected documentation areas, not guaranteed
   files.

10. Documentation should preserve understanding and decisions, not
    merely record commands.


================================================================================
DOCUMENTATION TYPES
================================================================================

ARCHITECTURE
    Describes what the system is, why it exists, and how major
    components relate.

INFRASTRUCTURE
    Describes what is actually deployed and its current configuration.

PROCEDURES
    Describes repeatable administrative or operational tasks.

INCIDENTS
    Describes failures, investigation, root cause, resolution and
    verification.

SOFTWARE
    Describes software inventory, catalog and licensing.

CLOUD
    Describes cloud-specific implementation and services.

SECURITY
    Describes security controls, permissions and incident response.

DISASTER RECOVERY
    Describes backup, restore and recovery procedures.

TODO
    Describes planned work, extensions and unresolved tasks.

THIS DOCUMENT
    Describes when and how the documentation itself is created,
    reviewed and updated.


================================================================================
DOCUMENTATION TREE
================================================================================

docs/
|
+-- architecture/
|    |
|    +-- overview.md
|    +-- virtualization.md
|    +-- network.md
|    +-- active-directory.md
|    +-- cloud.md
|
+-- infrastructure/
|    |
|    +-- vms.md
|    +-- networking.md
|    +-- services.md
|
+-- procedures/
|    |
|    +-- create-user.md
|    +-- disable-user.md
|    +-- domain-join.md
|    +-- troubleshoot-dns.md
|    +-- reset-password.md
|    +-- software-installation.md
|
+-- incidents/
|    |
|    +-- INC-001.md
|    +-- INC-002.md
|    +-- ...
|
+-- software/
|    |
|    +-- catalog.md
|    +-- licensing.md
|
+-- cloud/
|    |
|    +-- iam.md
|    +-- s3.md
|    +-- lambda.md
|    +-- rds.md
|
+-- security/
|    |
|    +-- baseline.md
|    +-- permissions.md
|    +-- incident-response.md
|
+-- disaster-recovery/
|    |
|    +-- backup.md
|    +-- restore.md
|
+-- documentation-plan.md
|
+-- todo.md


The tree represents the intended documentation architecture.

It does NOT mean that every file must exist immediately.


================================================================================
PHASE 0 — LAB FOUNDATION
================================================================================

IMPLEMENTATION AREAS
--------------------

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


EXPECTED DOCUMENTATION
----------------------

    architecture/
        overview.md
        virtualization.md

    infrastructure/
        vms.md

    incidents/
        troubleshooting cases

    todo.md


PHASE 0 REVIEW
--------------

At the end of Phase 0, review the actual implementation and decide
whether additional documentation is justified.

The following documentation was determined to be justified during
the Phase 0 review:

    architecture/network.md
        -> CREATED IN PHASE 0

    infrastructure/networking.md
        -> CREATED IN PHASE 0

The following documentation remains intentionally deferred:

    infrastructure/services.md
        -> later, when actual services exist

    procedures/*
        -> create only when meaningful procedures exist

    software/*
        -> later, when software inventory becomes meaningful

    security/*
        -> later, when security controls are implemented

    disaster-recovery/*
        -> later, when backup/recovery is implemented


CURRENT PHASE 0 STATE
---------------------

    architecture/overview.md
        DONE

    architecture/virtualization.md
        DONE

    architecture/network.md
        DONE

    infrastructure/vms.md
        DONE

    infrastructure/networking.md
        DONE

    networking/configuration
        IMPLEMENTED

    troubleshooting documentation
        ACTIVE

    todo.md
        ACTIVE


================================================================================
PHASE 1 — NETWORKING
================================================================================

IMPLEMENTATION AREAS
--------------------

    libvirt networks
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


DOCUMENTATION REVIEW
--------------------

At the end of Phase 1, review what was actually implemented.

Likely documentation:

    Update:

        architecture/network.md

        infrastructure/networking.md

    procedures/
        networking procedures
        only where repeatable operational tasks justify them

    incidents/
        networking troubleshooting cases


Do not create documentation for networking features that were
planned but not actually implemented.


================================================================================
PHASE 2 — CLOUD LAB
================================================================================

IMPLEMENTATION AREAS
--------------------

    Floci
    CLI / API
    AWS-compatible concepts
    IAM
    S3
    SQS
    Lambda
    RDS
    Secrets
    cloud networking where useful
    service interaction
    cloud troubleshooting


DOCUMENTATION REVIEW
--------------------

At the end of Phase 2, review the actual cloud implementation.

Potential documentation:

    architecture/
        cloud.md

    cloud/
        iam.md
        s3.md
        lambda.md
        rds.md
        additional service documentation as required

    incidents/
        cloud troubleshooting cases

Only create service-specific files for services actually used.


================================================================================
PHASE 3 — CLOUD APPLICATION
================================================================================

IMPLEMENTATION AREAS
--------------------

    Engineering document workflow
    S3
    SQS
    Lambda
    RDS
    IAM
    Secrets
    logging
    permission failures
    service failures
    end-to-end workflow


DOCUMENTATION REVIEW
--------------------

Update documentation according to the actual application.

Potential documentation:

    architecture/
        cloud.md

    cloud/
        affected service documentation

    incidents/
        permission failures
        service failures
        application failures


The phase should result in documentation of the actual workflow,
not merely the originally planned architecture.


================================================================================
PHASE 4 — TERRAFORM
================================================================================

IMPLEMENTATION AREAS
--------------------

    Providers
    Resources
    Variables
    Outputs
    State
    Plan
    Apply
    Destroy
    Modules
    Dependencies
    Drift
    Reproducible infrastructure


DOCUMENTATION REVIEW
--------------------

Review which Terraform concepts were actually used.

Update relevant:

    architecture/
    infrastructure/
    cloud/

Create procedures only where repeatable Terraform workflows
justify them.

Document actual practices rather than documenting every Terraform
feature theoretically.


================================================================================
PHASE 5 — WINDOWS SERVER
================================================================================

IMPLEMENTATION AREAS
--------------------

    Windows Server
    AD DS
    DNS
    DHCP
    OUs
    Users
    Groups
    Group Policy
    Authentication
    Authorization
    PowerShell
    Windows administration


DOCUMENTATION REVIEW
--------------------

Potential documentation:

    architecture/
        active-directory.md

    infrastructure/
        services.md

    procedures/
        create-user.md
        disable-user.md
        reset-password.md
        troubleshoot-dns.md

Only create procedures that are actually performed and worth
repeating.


================================================================================
PHASE 6 — WINDOWS CLIENT
================================================================================

IMPLEMENTATION AREAS
--------------------

    Windows 10/11
    Domain Join
    User Login
    GPO
    PowerShell
    Software
    Windows administration
    Event Viewer
    Services
    RDP
    Windows troubleshooting


DOCUMENTATION REVIEW
--------------------

Update:

    architecture/
        active-directory.md

    infrastructure/
        vms.md

Potential procedures:

    procedures/
        domain-join.md
        software-installation.md

Potential incidents:

    incidents/
        Windows troubleshooting cases


Create additional documentation only when justified by the
actual implementation.


================================================================================
PHASE 7 — FILE SERVICES / PERMISSIONS
================================================================================

IMPLEMENTATION AREAS
--------------------

    SMB
    NTFS
    Share Permissions
    ACL
    Security Groups
    Effective Permissions
    Inheritance
    Least Privilege
    Permission troubleshooting


DOCUMENTATION REVIEW
--------------------

Potential documentation:

    infrastructure/
        services.md

    security/
        permissions.md

    incidents/
        permission troubleshooting cases

Update architecture documentation if the file-service architecture
introduces an important architectural relationship.


================================================================================
PHASE 8 — REMOTE IT SUPPORT
================================================================================

IMPLEMENTATION AREAS
--------------------

    Windows troubleshooting
    Network troubleshooting
    Event Logs
    Services
    Performance
    RDP
    Incident investigation
    Troubleshooting methodology


DOCUMENTATION REVIEW
--------------------

Update or create:

    procedures/
        relevant support procedures

    incidents/
        relevant incident records

    security/
        incident-response.md
        only if the implementation justifies it


The focus is on documenting real operational workflows and
troubleshooting methodology.


================================================================================
PHASE 9 — ITSM
================================================================================

IMPLEMENTATION AREAS
--------------------

    Open-source ITSM selection
    ITSM deployment
    Users
    Tickets
    Incidents
    Service Requests
    Changes
    Assets
    Software
    Licenses
    Knowledge Base
    Support workflow
    Software / license workflow


DOCUMENTATION REVIEW
--------------------

Potential documentation:

    software/
        catalog.md
        licensing.md

    procedures/
        ITSM operational procedures

    incidents/
        ITSM incidents where applicable

Additional documentation may be created if the selected ITSM
platform introduces architectural or operational requirements.


================================================================================
PHASE 10 — CORE ARCHITECTURE COMPLETION
================================================================================

IMPLEMENTATION AREAS
--------------------

    Review complete architecture
    Connect Windows + ITSM + Cloud
    Verify end-to-end scenarios
    Review networking
    Review identity
    Review permissions
    Review cloud workflow
    Review Terraform
    Review documentation
    Review security baseline
    Identify architecture gaps
    Move remaining enhancements to TODO


DOCUMENTATION REVIEW
--------------------

Perform a complete documentation audit.

Compare:

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


Remove obsolete information.

Correct inaccurate information.

Document important missing components.

Move future work into:

    todo.md


Phase 10 is the major consistency review of the documentation.


================================================================================
PHASE 11+ — FUTURE IMPLEMENTATIONS
================================================================================

There is no fixed documentation plan for future features.

For every new feature:

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
    UPDATE THIS PLAN


Possible future areas include:

    Advanced Networking
    VPN
    Network Segmentation
    Additional Windows Servers
    Monitoring
    Advanced Security
    Additional Cloud Services
    Automation
    ITSM Integration
    Disaster Recovery


Documentation for future features is decided when the feature
actually becomes part of the laboratory.


================================================================================
END-OF-PHASE DOCUMENTATION WORKFLOW
================================================================================

Every phase follows the same process:

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
    | Update documentation    |
    | plan with current state |
    +------------+------------+
                 |
                 v
    +-------------------------+
    | Review next phase       |
    +-------------------------+


IMPORTANT
---------

This document is updated AFTER each phase review.

The plan must reflect what actually happened.

Do not prematurely mark future documentation as completed.

Do not create documentation merely to satisfy the planned tree.

The laboratory implementation is the source of truth.


================================================================================
