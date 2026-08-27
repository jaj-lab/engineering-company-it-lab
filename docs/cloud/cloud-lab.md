================================================================================
PHASE 2 — CLOUD LAB
ENGINEERING DOCUMENT WORKFLOW
================================================================================

GOAL
----

Build a small AWS-style cloud application inside Floci that models
a realistic engineering-company document processing workflow.

The final result should not be a collection of unrelated AWS services.

All components must have a clear purpose and connection to the
business scenario.


================================================================================
HIGH-LEVEL ARCHITECTURE
================================================================================


                         ENGINEERING COMPANY
                                |
                                v
                           Employee
                                |
                                v
                         Document Upload
                                |
                                v
                         +-------------+
                         | Application |
                         +------+------+
                                |
                                | Upload
                                v
                         +-------------+
                         |     S3      |
                         | engineering |
                         | -documents  |
                         +------+------+
                                |
                                | Event
                                v
                         +-------------+
                         |     SQS     |
                         | document-   |
                         | processing  |
                         +------+------+
                                |
                                | Message
                                v
                         +-------------+
                         |   Lambda    |
                         | processor   |
                         +------+------+ 
                                |
                    +-----------+-----------+
                    |                       |
                    | Store metadata        | Read secret
                    v                       v
             +-------------+         +-------------+
             |     RDS     |         |  Secrets    |
             | PostgreSQL  |         |  Manager    |
             +-------------+         +-------------+
                    |
                    | Application metadata
                    v
              Document state


Supporting the workflow:

    IAM
        |
        +--> Application access
        +--> Lambda permissions
        +--> S3 access
        +--> SQS access
        +--> Secrets access
        +--> Logging access


    Logging
        |
        +--> Application activity
        +--> Lambda execution
        +--> Errors
        +--> Troubleshooting


================================================================================
CLOUD PLATFORM
================================================================================

Platform:


    Floci
        |
        +-- AWS-compatible local cloud APIs
        |
        +-- Docker container
        |
        +-- localhost:4566


Deployment:


    MINT01
        |
        +-- Docker
        +-- Docker Compose
        |
        v
    Floci container


Persistent storage:


    Docker named volume:
        data

    Mounted into Floci:
        /app/data


Compose project:


    cloud/floci/


Current deployment state:


    Floci
        RUNNING

    Health endpoint
        VERIFIED

    AWS CLI
        CONFIGURED

    S3 connectivity
        VERIFIED


Important:


    MINT01 is the administrative workstation for the
    simulated company environment.

    Floci runs on MINT01 as the local cloud laboratory.


================================================================================
AWS CLI CONFIGURATION
================================================================================

AWS CLI is configured on MINT01.

Configured local credentials are used for the Floci environment.

Endpoint:


    http://localhost:4566


Region:


    eu-east-1


The AWS CLI is explicitly pointed at Floci using:


    --endpoint-url=http://localhost:4566


Verification:


    aws --endpoint-url=http://localhost:4566 sts get-caller-identity


The AWS CLI communicates with Floci instead of AWS itself.


================================================================================
STAGE 1 — CLOUD FOUNDATION
================================================================================

STATUS:


    COMPLETE


Implemented:


    [x] MINT01 prepared
    [x] Docker verified
    [x] Docker Compose verified
    [x] Floci deployed
    [x] Persistent named volume configured
    [x] Floci container healthy
    [x] Health endpoint verified
    [x] AWS CLI configured
    [x] Floci connectivity verified
    [x] S3 API connectivity verified


Floci health endpoint:


    GET /health


Verified that the local cloud services are running.


================================================================================
STAGE 2 — IAM ACCESS MODEL
================================================================================

STATUS:


    COMPLETE


Initial IAM state:


    Users:
        0

    Roles:
        0

    Local policies:
        0


Implemented identity:


    engineering-app


Purpose:


    Application identity used to demonstrate
    cloud access control.


Policy:


    engineering-app-s3


Policy permissions:


    S3:
        s3:ListBucket
        s3:GetObject
        s3:PutObject


Resource scope:


    arn:aws:s3:::engineering-documents

    arn:aws:s3:::engineering-documents/*


The policy was attached to:


    engineering-app


Access key:


    Created for engineering-app


Caller identity verification:


    Arn:
        arn:aws:iam::000000000000:user/engineering-app


Expected access model:


                    engineering-app
                           |
                           v
                  engineering-app-s3
                       policy
                           |
              +------------+------------+
              |                         |
              v                         v
       engineering-documents       Other resources
              |                         |
       +------+------+                  X
       |             |
       v             v
   ListBucket    Object access
                 /        \
                v          v
            PutObject   GetObject


Intended restrictions:


    CreateBucket
        DENIED

    DeleteBucket
        DENIED

    IAM management
        DENIED

    Access to unrelated resources
        DENIED


IMPORTANT FLOCΙ BEHAVIOR
------------------------

During authorization testing, Floci did not fully enforce
the expected AWS IAM boundaries for the S3 operations tested.

The following operations were possible despite not being
present in the attached policy:


    ListAllMyBuckets
    CreateBucket
    DeleteBucket


Testing:


    engineering-app was able to:

        list all buckets
        create unauthorized-bucket
        delete unauthorized-bucket


The test bucket was subsequently removed.


Conclusion:


    The IAM POLICY DESIGN is correct and intentionally
    follows least privilege.

    However, the local Floci implementation does not
    fully reproduce AWS IAM authorization behavior for
    these tested S3 operations.

    This is documented as a platform limitation.

    The architecture is NOT being weakened to accommodate
    this behavior.


================================================================================
STAGE 3 — S3
================================================================================

STATUS:


    COMPLETE


Purpose:


    Object storage for engineering documents.


Bucket:


    engineering-documents


Created and verified.


Initial state:


    Bucket existed
    No objects


Test object:


    test/test-document.txt


Operations verified:


    [x] ListBucket
    [x] PutObject
    [x] GetObject


Upload:


    test/test-document.txt


Download:


    tmp/downloaded-document.txt


Object listing confirmed the uploaded object.


The object was then removed as a test artifact.


The bucket itself remains part of the project infrastructure.


Expected logical structure:


    engineering-documents/
    |
    +-- incoming/
    |
    +-- processed/
    |
    +-- failed/


The prefixes will become meaningful when the document
processing workflow is implemented.


IMPORTANT:


    S3 stores the actual document objects.

    S3 does NOT store the application's structured
    document-processing metadata.


================================================================================
SERVICES
================================================================================

1. S3
-------

Purpose:


    Object storage for engineering documents.


Resource:


    engineering-documents


Responsibilities:


    Store uploaded documents
    Provide object retrieval
    Provide object metadata
    Generate events for the processing workflow


--------------------------------------------------------------------------------
2. SQS
-------

STATUS:


    NOT IMPLEMENTED


Purpose:


    Decouple document upload from document processing.


Planned queue:


    document-processing


Workflow:


    S3
      |
      | Object-created event
      v
    SQS
      |
      | Message
      v
    Lambda


The queue provides an asynchronous boundary between
storage and processing.


--------------------------------------------------------------------------------
3. Lambda
----------

STATUS:


    NOT IMPLEMENTED


Purpose:


    Process uploaded document events.


Function:


    document-processor


Planned responsibilities:


    Receive SQS message
        ↓
    Determine uploaded object
        ↓
    Read required metadata
        ↓
    Retrieve required secret
        ↓
    Perform document-processing logic
        ↓
    Store processing metadata in RDS
        ↓
    Log result


Initial processing should remain intentionally simple.


The objective is to demonstrate service interaction,
not to build a production document-processing engine.


--------------------------------------------------------------------------------
4. RDS
-------

STATUS:


    NOT IMPLEMENTED


Purpose:


    Store structured application metadata.


Database:


    PostgreSQL


Planned conceptual table:


    documents

        id
        object_key
        filename
        status
        uploaded_at
        processed_at
        error_message


Important distinction:


    S3
        =
    actual document


    RDS
        =
    information ABOUT the document


--------------------------------------------------------------------------------
5. Secrets Manager
-------------------

STATUS:


    NOT IMPLEMENTED


Purpose:


    Store sensitive configuration required by
    application components.


Initial use case:


    Database credentials


Conceptually:


    Lambda
       |
       | retrieve secret
       v
    Secrets Manager
       |
       v
    database credentials


Credentials must not be hardcoded into Lambda code.


--------------------------------------------------------------------------------
6. IAM
-------

STATUS:


    PARTIALLY IMPLEMENTED


Implemented:


    engineering-app
        |
        +-- engineering-app-s3
                |
                +-- ListBucket
                +-- GetObject
                +-- PutObject


Future IAM work:


    Lambda execution role
    SQS permissions
    Secrets Manager permissions
    Logging permissions
    More narrowly scoped application permissions


Principle:


    Least privilege.


IMPORTANT:


    Floci's tested S3 authorization behavior currently
    does not fully reproduce the expected AWS IAM boundaries.


The intended architecture remains least privilege.


--------------------------------------------------------------------------------
7. Logging
----------

STATUS:


    NOT IMPLEMENTED


Purpose:


    Provide visibility into application and Lambda execution.


Planned information:


    document received
    processing started
    processing completed
    database operation
    processing errors


Logging will also become useful during troubleshooting.


================================================================================
APPLICATION COMPONENT
================================================================================

STATUS:


    NOT IMPLEMENTED


The project will eventually contain a small application
representing the company's document submission system.


Possible responsibilities:


    upload document
    store document in S3
    expose document status
    interact with the processing workflow


The application does not need to be a complex web platform.


Its purpose is to act as the employee-facing entry point
into the cloud workflow.


================================================================================
CURRENT RESOURCE SET
================================================================================

Currently implemented:


    Floci
        |
        +-- AWS-compatible APIs

    S3
        |
        +-- engineering-documents

    IAM
        |
        +-- engineering-app
        +-- engineering-app-s3


Not yet implemented:


    SQS
    Lambda
    RDS
    Secrets Manager
    Logging
    Application


================================================================================
FINAL RESOURCE SET
================================================================================

The final Phase 2 implementation should contain approximately:


CLOUD PLATFORM

    Floci
        |
        +-- AWS-compatible APIs


STORAGE

    S3
        |
        +-- engineering-documents


MESSAGING

    SQS
        |
        +-- document-processing


COMPUTE

    Lambda
        |
        +-- document-processor


DATABASE

    RDS
        |
        +-- PostgreSQL
        |
        +-- engineering metadata


SECRETS

    Secrets Manager
        |
        +-- database credentials


ACCESS CONTROL

    IAM
        |
        +-- application identity
        +-- Lambda role
        +-- policies


OBSERVABILITY

    Logging
        |
        +-- Lambda execution
        +-- workflow events
        +-- errors


APPLICATION

    Document application
        |
        +-- document upload
        +-- S3 interaction
        +-- status


================================================================================
IMPLEMENTATION ORDER
================================================================================

The implementation proceeds incrementally.


    [x] STAGE 1
        Cloud Foundation

        +-- Floci
        +-- Docker Compose
        +-- persistent storage
        +-- AWS CLI
        +-- endpoint
        +-- connectivity
        +-- health verification

            |
            v

    [x] STAGE 2
        IAM / Access Model

        +-- engineering-app
        +-- engineering-app-s3
        +-- policy attachment
        +-- access key
        +-- authorization testing
        +-- Floci limitation documented

            |
            v

    [x] STAGE 3
        S3

        +-- engineering-documents
        +-- object operations
        +-- upload / download verification

            |
            v

    [ ] STAGE 4
        SQS

        +-- document-processing
        +-- queue verification
        +-- message operations

            |
            v

    [ ] STAGE 5
        Lambda

        +-- document-processor
        +-- SQS integration
        +-- S3 interaction

            |
            v

    [ ] STAGE 6
        RDS

        +-- PostgreSQL
        +-- documents metadata
        +-- Lambda integration

            |
            v

    [ ] STAGE 7
        Secrets

        +-- database credentials
        +-- Lambda retrieval

            |
            v

    [ ] STAGE 8
        Logging

        +-- Lambda logs
        +-- workflow visibility
        +-- error investigation

            |
            v

    [ ] STAGE 9
        Application

        +-- document upload
        +-- S3
        +-- workflow integration

            |
            v

    [ ] STAGE 10
        End-to-End Verification

        +-- Employee
        +-- Application
        +-- S3
        +-- SQS
        +-- Lambda
        +-- RDS
        +-- Secrets
        +-- IAM
        +-- Logging

            |
            v

        PHASE 2 COMPLETE


================================================================================
IMPORTANT ARCHITECTURAL PRINCIPLE
================================================================================

Do not implement a service merely because it exists.

Every component must answer:


    "Why does this exist in the Engineering Company?"


The intended relationships are:


    S3
        =
    document storage


    SQS
        =
    asynchronous workflow / decoupling


    Lambda
        =
    document processing


    RDS
        =
    structured application metadata


    Secrets Manager
        =
    sensitive configuration


    IAM
        =
    authorization


    Logging
        =
    operational visibility


    Application
        =
    employee-facing entry point


Together they form ONE business workflow.


================================================================================
CURRENT IMPLEMENTATION STATE
================================================================================


    PHASE 2 — CLOUD LAB


    STAGE 1 — CLOUD FOUNDATION
        [x] Complete


    STAGE 2 — IAM ACCESS MODEL
        [x] Complete


    STAGE 3 — S3
        [x] Complete


    STAGE 4 — SQS
        [ ] Next


    STAGE 5 — Lambda
        [ ]


    STAGE 6 — RDS
        [ ]


    STAGE 7 — Secrets
        [ ]


    STAGE 8 — Logging
        [ ]


    STAGE 9 — Application
        [ ]


    STAGE 10 — End-to-End Verification
        [ ]


Current position:


    >>> STAGE 4 — SQS <<<


================================================================================
PHASE 2 DEFINITION OF DONE
================================================================================

Phase 2 is complete when:


    [x] Floci cloud environment is operational

    [x] AWS CLI works against Floci

    [x] IAM access model is implemented

    [x] engineering-documents S3 bucket exists

    [x] S3 object operations verified

    [ ] SQS document-processing queue exists

    [ ] Lambda document-processor exists

    [ ] S3 -> SQS -> Lambda flow works

    [ ] RDS PostgreSQL stores document metadata

    [ ] Lambda can interact with RDS

    [ ] Secrets Manager stores sensitive configuration

    [ ] Lambda retrieves required secrets

    [ ] Logging captures workflow execution

    [ ] Application can submit documents

    [ ] End-to-end workflow works

    [x] Important IAM limitation investigated

    [x] Test artifacts cleaned

    [ ] Important additional failures investigated

    [ ] Actual implementation is documented

    [ ] Phase 2 documentation review completed

    [ ] Project state updated

    [ ] Phase 2 committed


Final target:


    EMPLOYEE
       |
       v
    APPLICATION
       |
       v
    S3
       |
       v
    SQS
       |
       v
    LAMBDA
       |
       +--------> RDS
       |
       +--------> SECRETS
       |
       +--------> LOGGING

    IAM controls access across the workflow.


================================================================================
NEXT IMPLEMENTATION
================================================================================

NEXT:


    STAGE 4 — SQS


Objective:


    Introduce asynchronous messaging into the
    Engineering Document Workflow.


First implementation target:


    Queue:


        document-processing


Then verify:


    queue exists
        ↓
    send message
        ↓
    receive message
        ↓
    inspect message
        ↓
    delete message


After that:


    connect S3 events
        ↓
    SQS
        ↓
    prepare for Lambda


================================================================================
END OF DOCUMENT
================================================================================
