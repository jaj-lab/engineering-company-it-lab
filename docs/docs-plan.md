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
corresponding implementation is completed.

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

11. The project state is the source of truth for implementation status.

12. Documentation may exist before an implementation is complete when
    it is explicitly documenting the intended design, prerequisites,
    or current planned state. Such documentation must not claim the
    infrastructure is implemented or verified.

13. When an implementation changes an existing component, its
    documentation must be reviewed rather than automatically creating
    a new document.

14. Service-specific documentation should describe the final verified
    role of the service within the actual architecture, not merely
    isolated commands used during implementation.


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
|    +-- INC-001-floci-state-loss.md
|    +-- INC-002-floci-lambda-exec-failure.md
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
|    +-- sqs.md
|    +-- lambda.md
|    +-- rds.md
|    +-- secrets-manager.md
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

Service-specific cloud documentation is created when the service
becomes relevant to the implementation and is reviewed against the
actual implementation state.

Documentation files may be added, removed or consolidated when the
actual architecture demonstrates that a different structure is more
accurate.


================================================================================
PHASE 0 — LAB FOUNDATION
================================================================================

STATUS:

    COMPLETE


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


DOCUMENTATION:

    architecture/overview.md
        -> CREATED

    architecture/virtualization.md
        -> CREATED

    architecture/network.md
        -> CREATED

    infrastructure/vms.md
        -> CREATED

    infrastructure/networking.md
        -> CREATED

    todo.md
        -> ACTIVE


PHASE 0 RESULT
--------------

The virtualization and initial laboratory networking foundation
was implemented and documented.

Additional documentation was intentionally deferred until the
corresponding infrastructure existed.


================================================================================
PHASE 1 — NETWORKING
================================================================================

STATUS:

    COMPLETE


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

Phase 1 implementation was reviewed against the existing
documentation.

The following documentation was updated:

    architecture/network.md
        -> UPDATED

    infrastructure/networking.md
        -> UPDATED


No dedicated networking procedure was created because the
implemented configuration did not introduce a sufficiently
meaningful repeatable administrative workflow requiring a
standalone procedure.

No additional networking incident documentation was required
after verification.


PHASE 1 RESULT
--------------

    Network architecture
        VERIFIED

    IP addressing
        IMPLEMENTED

    DHCP
        IMPLEMENTED AND VERIFIED

    DNS
        VERIFIED FOR CURRENT LAB STATE

    Routing/NAT
        IMPLEMENTED AND VERIFIED

    Firewall behavior
        VERIFIED

    VM connectivity
        VERIFIED

    Network documentation
        UPDATED

    Networking procedures
        NOT REQUIRED

    Networking incidents
        NOT REQUIRED


================================================================================
PHASE 2 — CLOUD
================================================================================

STATUS:

    IN PROGRESS


OBJECTIVE
---------

Build a realistic AWS-style document-processing workflow inside
Floci.

Cloud implementation was developed incrementally.

Documentation was created and updated as individual cloud
components became implemented and verified.


--------------------------------------------------------------------------------
STAGE 1 — CLOUD FOUNDATION
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


IMPLEMENTATION:

    [x] MINT01 cloud tooling
    [x] Docker
    [x] Docker Compose
    [x] Floci
    [x] Persistent volume
    [x] AWS CLI
    [x] AWS endpoint configuration
    [x] Floci connectivity
    [x] Health verification
    [x] direnv environment management


DOCUMENTATION:

    Cloud foundation
        -> DOCUMENTED THROUGH CLOUD / ARCHITECTURE DOCUMENTATION


INCIDENTS:

    INC-001 — Floci State Loss
        -> DOCUMENTED

    INC-002 — Floci Lambda Execution Failure
        -> DOCUMENTED


--------------------------------------------------------------------------------
STAGE 2 — IAM ACCESS MODEL
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


IMPLEMENTED:

    [x] engineering-app
    [x] engineering-app-s3
    [x] Access key
    [x] S3 permissions
    [x] Authorization testing
    [x] Lambda execution role
    [x] document-processor-role
    [x] document-processor policy
    [x] Role trust relationship
    [x] S3 permissions for Lambda
    [x] SQS permissions for Lambda
    [x] CloudWatch Logs permissions
    [x] Floci IAM limitation documented


DOCUMENTATION:

    docs/cloud/iam.md
        -> CREATED

    IAM limitation
        -> DOCUMENTED


--------------------------------------------------------------------------------
STAGE 3 — S3
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


IMPLEMENTED:

    [x] engineering-documents
    [x] Object upload
    [x] Object download
    [x] Object listing
    [x] S3 event notification
    [x] S3 → SQS integration


DOCUMENTATION:

    docs/cloud/s3.md
        -> CREATED

    S3 documentation
        -> REVIEWED AGAINST IMPLEMENTED STATE


--------------------------------------------------------------------------------
STAGE 4 — SQS
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


IMPLEMENTED:

    [x] document-processing queue
    [x] Queue verification
    [x] S3 event delivery
    [x] Message reception
    [x] Message inspection
    [x] Lambda consumer integration


DOCUMENTATION:

    docs/cloud/sqs.md
        -> CREATED

    SQS documentation
        -> REVIEWED AGAINST IMPLEMENTED STATE


--------------------------------------------------------------------------------
STAGE 5 — LAMBDA
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


IMPLEMENTED:

    [x] document-processor
    [x] Python 3.12
    [x] index.handler
    [x] Manual invocation
    [x] Lambda execution role
    [x] SQS event source mapping
    [x] Event source mapping enabled
    [x] Batch size = 1
    [x] S3 → SQS → Lambda flow
    [x] S3 object event extraction
    [x] Lambda execution logging
    [x] Successful SQS message deletion


INITIAL LAMBDA PURPOSE:

    Demonstrate event-driven document-processing infrastructure.

    The function initially extracted and logged:

        event type
        bucket
        object key


UPDATED LAMBDA ROLE:

    Lambda now participates in the implemented document-processing
    workflow and persists document metadata into PostgreSQL.


CURRENT LAMBDA RESPONSIBILITIES:

    [x] Receive SQS event
    [x] Extract S3 event information
    [x] Identify bucket
    [x] Identify object key
    [x] Process the document event
    [x] Persist document metadata
    [x] Retrieve required secret configuration
    [x] Produce execution / workflow logs
    [x] Successfully complete SQS processing


DOCUMENTATION:

    docs/cloud/lambda.md
        -> CREATED

    Lambda documentation
        -> UPDATED TO REFLECT RDS / SECRETS / LOGGING INTEGRATION


--------------------------------------------------------------------------------
STAGE 6 — RDS
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


OBJECTIVE:

    Introduce PostgreSQL storage for structured document-processing
    metadata.


IMPLEMENTED:

    [x] PostgreSQL
    [x] documents metadata table
    [x] Document metadata model
    [x] Lambda → RDS integration
    [x] Metadata persistence verified


DOCUMENTATION:

    docs/cloud/rds.md
        -> UPDATED / FINALIZED


DOCUMENTATION STATE:

    RDS infrastructure
        IMPLEMENTED

    RDS documentation
        EXISTS

    RDS documentation status
        IMPLEMENTED / VERIFIED


Important:

    The RDS documentation now describes the actual implemented
    PostgreSQL integration.

    It must be updated if the schema or integration architecture
    changes during later Phase 2 stages.


--------------------------------------------------------------------------------
STAGE 7 — SECRETS
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


OBJECTIVE:

    Introduce managed storage for sensitive database configuration
    and allow Lambda to retrieve the required secret.


IMPLEMENTED:

    [x] Secrets Manager
    [x] Database credentials / sensitive configuration
    [x] Lambda secret retrieval
    [x] Secret integration with Lambda → RDS workflow
    [x] Secret retrieval verified


DOCUMENTATION:

    docs/cloud/secrets-manager.md
        -> CREATED

    Secrets Manager documentation
        -> DOCUMENTED AGAINST IMPLEMENTED STATE


Documentation must describe the implemented secret-management
workflow without exposing actual secret values.


--------------------------------------------------------------------------------
STAGE 8 — LOGGING
--------------------------------------------------------------------------------

STATUS:

    COMPLETE


OBJECTIVE:

    Provide sufficient visibility into the implemented cloud
    workflow for execution, troubleshooting and operational review.


IMPLEMENTED:

    [x] Lambda execution logs
    [x] Floci Lambda runtime logs
    [x] Workflow visibility
    [x] Error visibility required by the current implementation
    [x] CloudWatch logging integration
    [x] Logging behavior verified


DOCUMENTATION:

    Logging behavior
        -> DOCUMENTED THROUGH CLOUD / LAMBDA DOCUMENTATION

    Dedicated logging document
        -> NOT REQUIRED AT CURRENT SCOPE


Reason:

    The current logging implementation is sufficiently small that
    a separate logging document would duplicate information already
    covered by the Lambda and cloud architecture documentation.

    A dedicated logging document may be introduced later if the
    monitoring architecture becomes substantially more complex.


--------------------------------------------------------------------------------
STAGE 9 — APPLICATION
--------------------------------------------------------------------------------

STATUS:

    CURRENT


OBJECTIVE:

    Introduce the employee-facing application that submits
    documents into the cloud processing workflow.


PLANNED / IN PROGRESS:

    [ ] Employee-facing application
    [ ] Document upload
    [ ] Application → S3 integration
    [ ] Document status
    [ ] End-to-end workflow integration


EXPECTED WORKFLOW:

    Employee
        ↓
    Application
        ↓
    S3
        ↓
    SQS
        ↓
    Lambda
        ↓
    RDS
        +
    Secrets
        +
    Logging


DOCUMENTATION:

    No additional application-specific documentation is currently
    finalized.

    Documentation requirements will be reviewed after the
    application is implemented and verified.


Potential documentation areas:

    architecture/
        cloud architecture updates

    cloud/
        application-specific documentation if justified

    infrastructure/
        service documentation if required

    procedures/
        operational procedures if the application introduces
        meaningful repeatable administrative workflows


Important:

    Do not create application documentation merely because the
    application is planned.

    Review and document the actual implementation after it exists.


--------------------------------------------------------------------------------
STAGE 10 — END-TO-END VERIFICATION
--------------------------------------------------------------------------------

STATUS:

    PLANNED


OBJECTIVE:

    Verify the complete document-processing workflow as one
    coherent system rather than as individually tested services.


PLANNED FINAL WORKFLOW:

    Employee
        ↓
    Application
        ↓
    S3
        ↓
    SQS
        ↓
    Lambda
        ↓
    RDS
        +
    Secrets
        +
    Logging


VERIFICATION:

    [ ] Employee can submit document
    [ ] Application uploads document to S3
    [ ] S3 emits ObjectCreated event
    [ ] SQS receives event
    [ ] Lambda consumes event
    [ ] Lambda retrieves required secret
    [ ] Lambda stores document metadata in RDS
    [ ] Logging provides workflow visibility
    [ ] Failure behavior is understood
    [ ] Final workflow is reproducible


DOCUMENTATION REVIEW:

    architecture/cloud.md
        -> FINAL REVIEW

    cloud/*
        -> REVIEW / UPDATE

    incidents/
        -> ADD ONLY IF JUSTIFIED

    documentation-plan.md
        -> UPDATE WITH FINAL PHASE 2 STATE


================================================================================
PHASE 2 DOCUMENTATION STATE
================================================================================

CURRENTLY COMPLETED:

    architecture/cloud.md
        DONE

    cloud/iam.md
        DONE

    cloud/s3.md
        DONE

    cloud/sqs.md
        DONE

    cloud/lambda.md
        DONE

    cloud/rds.md
        DONE

    cloud/secrets-manager.md
        DONE


CURRENT CLOUD DOCUMENTATION COVERAGE:

    Cloud foundation
        DOCUMENTED

    IAM
        DOCUMENTED

    S3
        DOCUMENTED

    SQS
        DOCUMENTED

    Lambda
        DOCUMENTED

    RDS
        DOCUMENTED

    Secrets Manager
        DOCUMENTED

    Logging
        DOCUMENTED THROUGH EXISTING CLOUD / LAMBDA DOCUMENTATION


DELETED / OBSOLETE:

    cloud/aws-architecture.md
        DELETED

    cloud/cloud-lab.md
        DELETED

    cloud/flow.md
        DELETED


The obsolete cloud documents were replaced by the consolidated
cloud architecture documentation and service-specific documentation.


INCIDENT DOCUMENTATION:

    incidents/INC-001-floci-state-loss.md
        EXISTS

    incidents/INC-002-floci-lambda-exec-failure.md
        EXISTS


IMPORTANT:

    Documentation completion and infrastructure completion are
    separate states.

    However, for the currently completed cloud stages:

        RDS
            IMPLEMENTED

        Secrets Manager
            IMPLEMENTED

        Logging
            IMPLEMENTED


    Documentation reflects those implemented states.

    The existence of a documentation file alone must never be
    interpreted as proof of implementation.


================================================================================
PHASE 3 — WINDOWS / ACTIVE DIRECTORY
================================================================================

STATUS:

    PLANNED


OBJECTIVE
---------

Transform the existing standalone Windows environment into a
managed company domain environment.


IMPLEMENTATION AREAS
--------------------

    AD DS
    DNS
    DHCP
    Domain
    Organizational Units
    Users
    Groups
    Group Policy
    WIN01 domain join
    Windows administration
    Permissions


DOCUMENTATION REVIEW
--------------------

At the end of Phase 3, review the actual Windows / AD
implementation.

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
        domain-join.md

    incidents/
        Windows / AD troubleshooting cases


Do not create procedures merely because they were listed here.

Create them only when the corresponding workflow is actually
implemented and sufficiently meaningful to document.


IMPORTANT:

    DC01 is currently a Windows Server installation.

    It is NOT yet a Domain Controller.

    WIN01 is currently standalone.

    AD DS and domain join must not be documented as implemented
    until Phase 3.


================================================================================
PHASE 4 — IT OPERATIONS
================================================================================

STATUS:

    PLANNED


OBJECTIVE
---------

Build realistic day-to-day IT administration workflows around
the infrastructure already created.


POTENTIAL IMPLEMENTATION AREAS:

    User lifecycle
    Workstation lifecycle
    Software deployment
    Access management
    Backup operations
    Recovery operations
    Patch management
    Administrative procedures
    Operational documentation


DOCUMENTATION REVIEW
--------------------

Potential documentation:

    procedures/
        user lifecycle
        workstation lifecycle
        software installation
        access management
        backup / recovery

    infrastructure/
        services.md

    incidents/
        operational incidents


Only create documentation for workflows actually implemented.


================================================================================
PHASE 5 — AUTOMATION / IaC
================================================================================

STATUS:

    PLANNED


OBJECTIVE
---------

Automate repeatable infrastructure and operational tasks.


POTENTIAL IMPLEMENTATION AREAS:

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


DOCUMENTATION REVIEW
--------------------

Review the automation actually implemented during the phase.

Potential documentation areas:

    infrastructure/
    procedures/
    cloud/
    security/


Terraform documentation should only be created when Terraform
becomes part of the actual implementation.

Automation introduced earlier for a concrete implementation task
may also be documented at that time.


IMPORTANT:

    Automation / IaC is a later project phase.

    It is NOT currently part of the active implementation.

    Do not create Terraform documentation merely because a
    terraform/ directory exists in the repository.


================================================================================
PHASE 6 — ITSM
================================================================================

STATUS:

    PLANNED


OBJECTIVE
---------

Introduce structured IT service management around the existing
infrastructure and operational workflows.


POTENTIAL IMPLEMENTATION AREAS:

    ITSM platform
    Users / organizations
    Tickets
    Incidents
    Service requests
    Assets
    Knowledge base
    Change management
    Operational workflows


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

    Additional architecture documentation where justified.


Create documentation according to the actual ITSM platform and
workflow implemented.


================================================================================
PHASE 7 — MONITORING
================================================================================

STATUS:

    PLANNED


OBJECTIVE
---------

Introduce infrastructure monitoring, observability and
operational visibility.


POTENTIAL IMPLEMENTATION AREAS:

    Host monitoring
    VM monitoring
    Service monitoring
    Network monitoring
    Logs
    Metrics
    Alerting
    Dashboards
    Incident integration


DOCUMENTATION REVIEW
--------------------

Potential documentation:

    infrastructure/
        monitoring-related documentation

    procedures/
        monitoring procedures

    security/
        incident-response.md
        where justified

    incidents/
        monitoring / alerting incidents


Create documentation based on the monitoring system actually
implemented.


IMPORTANT:

    Phase 2 logging is already implemented.

    Phase 7 is intended to introduce broader infrastructure
    monitoring and observability.

    Do not treat the existing Phase 2 CloudWatch / Lambda logging
    as completion of the future monitoring phase.


================================================================================
PHASE 8 — FINAL INTEGRATION
================================================================================

STATUS:

    PLANNED


OBJECTIVE
---------

Connect the individual project phases into one coherent company
IT environment.


POTENTIAL INTEGRATION:

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


During the final review:

    Remove obsolete information.

    Correct inaccurate information.

    Document important missing components.

    Resolve contradictions between architecture and
    implementation.

    Move future work into:

        todo.md


Phase 8 is the major consistency review of the complete
documentation set.


================================================================================
FUTURE IMPLEMENTATIONS
================================================================================

There is no fixed documentation plan beyond the current roadmap.

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


================================================================================
CURRENT PROJECT POSITION
================================================================================

Current phase:

    PHASE 2 — CLOUD


Current stage:

    STAGE 9 — APPLICATION


Completed phases:

    PHASE 0 — LAB FOUNDATION
        COMPLETE

    PHASE 1 — NETWORKING
        COMPLETE


Completed Phase 2 stages:

    STAGE 1 — CLOUD FOUNDATION
        COMPLETE

    STAGE 2 — IAM ACCESS MODEL
        COMPLETE

    STAGE 3 — S3
        COMPLETE

    STAGE 4 — SQS
        COMPLETE

    STAGE 5 — LAMBDA
        COMPLETE

    STAGE 6 — RDS
        COMPLETE

    STAGE 7 — SECRETS
        COMPLETE

    STAGE 8 — LOGGING
        COMPLETE


CURRENT PHASE 2 STAGE:

    STAGE 9 — APPLICATION
        CURRENT


REMAINING PHASE 2 STAGES:

    STAGE 10 — END-TO-END VERIFICATION
        PLANNED


CURRENT CLOUD DOCUMENTATION:

    architecture/cloud.md
        DONE

    cloud/iam.md
        DONE

    cloud/s3.md
        DONE

    cloud/sqs.md
        DONE

    cloud/lambda.md
        DONE

    cloud/rds.md
        DONE

    cloud/secrets-manager.md
        DONE


CURRENT CLOUD IMPLEMENTATION DOCUMENTATION:

    IAM
        DOCUMENTED

    S3
        DOCUMENTED

    SQS
        DOCUMENTED

    Lambda
        DOCUMENTED

    RDS
        DOCUMENTED

    Secrets Manager
        DOCUMENTED

    Logging
        DOCUMENTED THROUGH EXISTING DOCUMENTATION


CURRENT INCIDENT DOCUMENTATION:

    INC-001 — Floci State Loss
        DOCUMENTED

    INC-002 — Floci Lambda Execution Failure
        DOCUMENTED


CURRENT CLOUD WORKFLOW:

    S3
      |
      v
    SQS
      |
      v
    Lambda
      |
      +------> RDS PostgreSQL
      |
      +------> Secrets Manager
      |
      +------> CloudWatch / Logging


CURRENT DOCUMENTATION POSITION:

    Cloud foundation
        DOCUMENTED

    IAM
        DOCUMENTED

    S3
        DOCUMENTED

    SQS
        DOCUMENTED

    Lambda
        DOCUMENTED

    RDS
        DOCUMENTED

    Secrets Manager
        DOCUMENTED

    Logging
        DOCUMENTED

    Application
        NOT YET DOCUMENTED AS IMPLEMENTED

    End-to-End workflow
        NOT YET FINALLY VERIFIED


IMMEDIATE OBJECTIVE:

    Implement the employee-facing application.

    Then:

        IMPLEMENT
            ↓
        TEST
            ↓
        TROUBLESHOOT IF NEEDED
            ↓
        DOCUMENT
            ↓
        REVIEW
            ↓
        COMMIT


IMPORTANT RESTRICTIONS:

    Do NOT configure AD DS yet.

    Do NOT configure DC01 as a Domain Controller yet.

    Do NOT domain-join WIN01 yet.

    Do NOT prematurely implement Terraform / IaC.

    Do NOT create documentation for infrastructure that does
    not exist.

    Do NOT treat the existence of a documentation file as proof
    that the corresponding infrastructure is implemented.

    Do NOT create application documentation before the application
    is actually implemented and verified.

    Do NOT create a dedicated logging document unless the logging
    architecture becomes sufficiently substantial to justify one.

    The laboratory implementation is the source of truth.


================================================================================
END OF DOCUMENTATION PLAN
================================================================================
