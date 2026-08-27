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
                                | Object-created event
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
        +--> Lambda execution role
        +--> S3 access
        +--> SQS access
        +--> Secrets access
        +--> Logging access


    Logging
        |
        +--> Lambda execution
        +--> Workflow events
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
        floci_data

    Mounted into Floci:
        /app/data


Compose project:


    cloud/floci/


Docker socket:


    /var/run/docker.sock


Purpose:


    Floci uses the Docker socket to launch isolated
    Lambda execution containers.


Current deployment state:


    Floci
        RUNNING

    Health endpoint
        VERIFIED

    AWS CLI
        CONFIGURED

    S3 connectivity
        VERIFIED

    SQS connectivity
        VERIFIED

    Lambda execution
        VERIFIED


Important:


    MINT01 is the administrative workstation for the
    simulated company environment.

    Floci runs on MINT01 as the local cloud laboratory.


================================================================================
AWS CLI CONFIGURATION
================================================================================

AWS CLI is configured on MINT01.

Local credentials are used for the Floci environment.

Endpoint:


    http://localhost:4566


Region:


    eu-east-1


AWS environment variables are loaded through direnv
from the project-level .envrc.


Configured variables include:


    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION
    AWS_ENDPOINT_URL


The endpoint no longer needs to be explicitly supplied
to every AWS CLI command.


Verification:


    aws sts get-caller-identity


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


Important incident:


    INC-001 — Floci State Loss


    Root cause:


        Docker Compose configuration mounted
        /app/data as a named volume, but the volume
        did not contain the previously created cloud
        state.


    Investigation established that Floci's persisted
    application state was not located in the expected
    mounted directory for the previous deployment.


    Operational lesson:


        docker compose down removes containers and the
        Compose network, but does NOT remove named volumes
        unless explicitly requested.


    Current operational practice:


        Use:

            docker compose stop

        when temporarily stopping the cloud lab.


        Use:

            docker compose start

        or:

            docker compose up

        to resume it.


    Named volume:


        floci_data


    The volume itself is preserved by:

        docker compose down


    unless:

        docker compose down -v


    is explicitly used.


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


Implemented application identity:


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


    arn:aws:iam::000000000000:user/engineering-app


Lambda identity:


    document-processor-role


Trust relationship:


    lambda.amazonaws.com
        |
        v
    sts:AssumeRole


Lambda policy:


    document-processor


Current Lambda policy permissions:


    S3:
        s3:GetObject


    SQS:
        sqs:ReceiveMessage
        sqs:DeleteMessage
        sqs:GetQueueAttributes


    Logging:
        logs:CreateLogGroup
        logs:CreateLogStream
        logs:PutLogEvents


Resource scope:


    S3:

        arn:aws:s3:::engineering-documents/*


    SQS:

        arn:aws:sqs:eu-east-1:000000000000:document-processing


Expected access model:


                    document-processor
                           |
                           v
                 document-processor-role
                           |
                           v
                    document-processor
                       policy
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
         S3               SQS             Logs
          |                |                |
          v                v                v
    Read objects      Consume messages   Write logs


IMPORTANT FLOCΙ BEHAVIOR
------------------------

During authorization testing, Floci did not fully enforce
the expected AWS IAM boundaries for the S3 operations tested.

The following operations were possible despite not being
present in the attached application policy:


    ListAllMyBuckets
    CreateBucket
    DeleteBucket


Testing established that:


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


Operations verified:


    [x] ListBucket
    [x] PutObject
    [x] GetObject


Test artifacts:


    test/test-document.txt
    tmp/downloaded-document.txt
    incoming/s3-sqs-test.txt
    incoming/lambda-processing-test.txt


Object upload and retrieval were verified.


S3 event generation was also verified as part of the
S3 → SQS integration.


Expected logical structure:


    engineering-documents/
    |
    +-- incoming/
    |
    +-- processed/
    |
    +-- failed/


Important:


    S3 stores the actual document objects.

    S3 does NOT store the application's structured
    document-processing metadata.


================================================================================
STAGE 4 — SQS
================================================================================

STATUS:


    COMPLETE


Purpose:


    Decouple document upload from document processing.


Queue:


    document-processing


Queue ARN:


    arn:aws:sqs:eu-east-1:000000000000:document-processing


Queue URL:


    http://localhost:4566/000000000000/document-processing


Implemented and verified:


    [x] Queue created
    [x] Queue attributes inspected
    [x] Message retrieval verified
    [x] Message deletion behavior verified
    [x] S3 event notification configured
    [x] S3 → SQS event flow verified


Basic queue workflow:


    send message
        ↓
    receive message
        ↓
    inspect message
        ↓
    delete message


S3 integration:


    S3
      |
      | ObjectCreated:Put
      v
    SQS
      |
      | S3 event notification
      v
    document-processing


Verification:


    Uploading an object to:

        engineering-documents/incoming/


    resulted in an SQS message containing the
    corresponding S3 event.


Verified example:


    incoming/s3-sqs-test.txt


The received message contained:


    eventSource:
        aws:s3


    eventName:
        ObjectCreated:Put


    bucket:
        engineering-documents


    object:
        incoming/s3-sqs-test.txt


Conclusion:


    S3 is successfully producing asynchronous
    processing events through SQS.


================================================================================
STAGE 5 — LAMBDA
================================================================================

STATUS:


    COMPLETE


Purpose:


    Consume SQS messages and act as the document
    processing component of the workflow.


Function:


    document-processor


Runtime:


    Python 3.12


Handler:


    index.handler


Architecture:


    SQS
      |
      | Event Source Mapping
      v
    Lambda
      |
      v
    document-processor


Lambda execution role:


    document-processor-role


Event Source Mapping:


    SQS:
        document-processing


    Batch size:
        1


    State:
        Enabled


The Lambda function was initially implemented as a
minimal execution test.


Current processing logic:


    Receive event
        ↓
    Extract S3 event
        ↓
    Extract bucket name
        ↓
    Extract object key
        ↓
    Log extracted information
        ↓
    Return successful execution


Current function behavior:


    document-processor invoked

    event:
        ...

    event:
        ObjectCreated:Put

    bucket:
        engineering-documents

    object:
        incoming/lambda-processing-test.txt


The function currently DOES NOT:


    [ ] Read the object contents
    [ ] Move objects between S3 prefixes
    [ ] Create RDS records
    [ ] Update document processing status
    [ ] Retrieve secrets
    [ ] Perform real document processing


This is intentional at the current stage.

The Lambda implementation first proves that the
event-driven infrastructure works before adding
database and application logic.


Event-driven verification:


    Employee / test upload
            |
            v
          S3
            |
            | ObjectCreated
            v
          SQS
            |
            | Event Source Mapping
            v
        Lambda
            |
            v
      document-processor
            |
            v
        log output


Verified successfully.


Important incident:


    INC-002 — Floci Lambda Execution Failure


    Symptom:


        Lambda invocation returned:

            FunctionError:
                Unhandled


        with:

            Failed to start Lambda container:
            java.net.SocketException:
            No such file or directory


    Root cause:


        Floci runs inside Docker and requires access
        to the host Docker socket to launch Lambda
        execution containers.


    Resolution:


        Added the Docker socket bind mount:


            /var/run/docker.sock:
                /var/run/docker.sock


        to the Floci Compose service.


    Verification:


        Floci container contains:

            /var/run/docker.sock


        Lambda execution container was successfully
        created and started.


    Result:


        Lambda invocation returned:

            StatusCode: 200


        and the SQS-triggered Lambda execution
        successfully processed and deleted the message.


Operational lesson:


    A local cloud emulator that launches workload
    containers requires access to the container runtime.


================================================================================
CURRENT EVENT-DRIVEN WORKFLOW
================================================================================


    S3 OBJECT UPLOAD
           |
           v
    engineering-documents
           |
           | ObjectCreated:Put
           v
    SQS
    document-processing
           |
           | Event Source Mapping
           v
    Lambda
    document-processor
           |
           +--> extract bucket
           |
           +--> extract object key
           |
           +--> log event
           |
           v
       SUCCESS


This is the first complete asynchronous workflow
implemented in Phase 2.


================================================================================
SERVICES
================================================================================

1. S3
-------

STATUS:


    COMPLETE


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


    COMPLETE


Purpose:


    Provide an asynchronous boundary between
    document storage and processing.


Resource:


    document-processing


Responsibilities:


    Receive S3 object-created events
    Buffer processing messages
    Decouple S3 from Lambda
    Provide reliable message consumption


--------------------------------------------------------------------------------
3. Lambda
----------

STATUS:


    COMPLETE — INITIAL IMPLEMENTATION


Purpose:


    Consume SQS messages and extract information
    about uploaded documents.


Function:


    document-processor


Current responsibilities:


    Receive SQS event
        ↓
    Extract S3 event
        ↓
    Extract bucket
        ↓
    Extract object key
        ↓
    Log information
        ↓
    Complete successfully


Future responsibilities:


    Read document from S3
        ↓
    Perform processing
        ↓
    Store metadata in RDS
        ↓
    Update processing state
        ↓
    Handle processing failures


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


    IMPLEMENTED


Application identity:


    engineering-app


Application policy:


    engineering-app-s3


Lambda identity:


    document-processor-role


Lambda policy:


    document-processor


Current Lambda permissions:


    S3:
        s3:GetObject

    SQS:
        sqs:ReceiveMessage
        sqs:DeleteMessage
        sqs:GetQueueAttributes

    Logging:
        logs:CreateLogGroup
        logs:CreateLogStream
        logs:PutLogEvents


Principle:


    Least privilege.


IMPORTANT:


    Floci's tested S3 authorization behavior does not
    fully reproduce the expected AWS IAM boundaries.


The intended architecture remains least privilege.


--------------------------------------------------------------------------------
7. Logging
----------

STATUS:


    PARTIALLY IMPLEMENTED


Current behavior:


    Lambda execution logs are generated.


Verified information includes:


    document-processor invoked
    S3 event type
    bucket
    object key


Floci creates Lambda log streams under:


    /aws/lambda/document-processor/


Future logging work:


    document received
    processing started
    processing completed
    database operation
    processing errors
    operational troubleshooting


The dedicated logging work will be completed later
as part of the observability portion of the workflow.


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
CURRENT REPOSITORY STRUCTURE
================================================================================


    cloud/
    |
    +-- floci/
    |   |
    |   +-- compose.yaml
    |   +-- tmp/
    |
    +-- iam/
    |   |
    |   +-- engineering-app-s3-policy.json
    |
    +-- s3/
    |   |
    |   +-- s3-to-sqs-notification.json
    |   +-- tmp/
    |
    +-- sqs/
    |
    +-- lambda/
    |   |
    |   +-- document-processor/
    |       |
    |       +-- index.py
    |       +-- function.zip
    |       +-- test-event.json
    |       +-- response.json
    |
    +-- rds/


Service-specific READMEs are intentionally deferred.

They will be written after the complete workflow has
been implemented so that the documentation reflects
the final architecture rather than intermediate states.


================================================================================
CURRENT RESOURCE SET
================================================================================

Currently implemented:


    Floci
        |
        +-- AWS-compatible APIs
        +-- Docker-backed Lambda execution


    S3
        |
        +-- engineering-documents


    SQS
        |
        +-- document-processing


    Lambda
        |
        +-- document-processor


    IAM
        |
        +-- engineering-app
        +-- engineering-app-s3
        +-- document-processor-role
        +-- document-processor


    S3 → SQS → Lambda
        |
        +-- VERIFIED


Not yet implemented:


    RDS
    Secrets Manager
    Full application
    Complete observability workflow


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
        +-- Lambda execution role
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
        +-- endpoint configuration
        +-- connectivity
        +-- health verification
        +-- Lambda Docker runtime support

            |
            v

    [x] STAGE 2
        IAM / Access Model

        +-- engineering-app
        +-- engineering-app-s3
        +-- Lambda execution role
        +-- Lambda policy
        +-- policy attachment
        +-- authorization testing
        +-- Floci limitation documented

            |
            v

    [x] STAGE 3
        S3

        +-- engineering-documents
        +-- object operations
        +-- upload / download verification
        +-- event notification configuration

            |
            v

    [x] STAGE 4
        SQS

        +-- document-processing
        +-- queue verification
        +-- message operations
        +-- S3 event integration
        +-- S3 → SQS verification

            |
            v

    [x] STAGE 5
        Lambda

        +-- document-processor
        +-- Python 3.12 runtime
        +-- Lambda execution role
        +-- SQS Event Source Mapping
        +-- SQS event consumption
        +-- S3 event extraction
        +-- workflow logging
        +-- successful message deletion

            |
            v

    [ ] STAGE 6
        RDS

        +-- PostgreSQL
        +-- documents metadata
        +-- Lambda integration
        +-- processing state

            |
            v

    [ ] STAGE 7
        Secrets

        +-- database credentials
        +-- Lambda retrieval
        +-- secure configuration

            |
            v

    [ ] STAGE 8
        Logging

        +-- workflow logging
        +-- structured events
        +-- error investigation
        +-- operational visibility

            |
            v

    [ ] STAGE 9
        Application

        +-- document upload
        +-- S3
        +-- workflow integration
        +-- document status

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
        [x] Complete


    STAGE 5 — Lambda
        [x] Complete
        |
        +-- Initial event-processing implementation


    STAGE 6 — RDS
        [ ] Next


    STAGE 7 — Secrets
        [ ]


    STAGE 8 — Logging
        [ ]


    STAGE 9 — Application
        [ ]


    STAGE 10 — End-to-End Verification
        [ ]


Current position:


    >>> STAGE 6 — RDS <<<


================================================================================
PHASE 2 DEFINITION OF DONE
================================================================================

Phase 2 is complete when:


    [x] Floci cloud environment is operational

    [x] AWS CLI works against Floci

    [x] IAM access model is implemented

    [x] engineering-documents S3 bucket exists

    [x] S3 object operations verified

    [x] SQS document-processing queue exists

    [x] S3 → SQS event flow works

    [x] Lambda document-processor exists

    [x] SQS → Lambda Event Source Mapping works

    [x] Lambda extracts S3 event information

    [x] Lambda execution is logged

    [ ] RDS PostgreSQL stores document metadata

    [ ] Lambda can interact with RDS

    [ ] Secrets Manager stores sensitive configuration

    [ ] Lambda retrieves required secrets

    [ ] Complete workflow logging implemented

    [ ] Application can submit documents

    [ ] End-to-end workflow works

    [x] Important IAM limitation investigated

    [x] INC-001 investigated

    [x] INC-002 investigated

    [ ] Important additional failures investigated

    [ ] Actual implementation is documented

    [ ] Service READMEs completed

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


    STAGE 6 — RDS


Objective:


    Introduce structured persistence for document
    processing metadata.


Initial target:


    PostgreSQL database


Conceptual entity:


    documents


Expected relationship:


    S3
        |
        | document object
        v
    Lambda
        |
        | document metadata
        v
    RDS
        |
        v
    documents


Initial database information:


    id
    object_key
    filename
    status
    uploaded_at
    processed_at
    error_message


The Lambda implementation will be extended only after
the database foundation is verified.


After RDS:


    Lambda
        |
        +--> S3
        |
        +--> RDS


Then:


    Secrets Manager


will be introduced to remove sensitive database
configuration from the Lambda implementation.


================================================================================
END OF DOCUMENT
================================================================================
