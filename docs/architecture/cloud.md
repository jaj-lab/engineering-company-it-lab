# Cloud Architecture

## Overview

The Engineering Company IT Lab includes a local AWS-compatible cloud
environment used to practice cloud infrastructure, service integration,
IAM, event-driven processing, managed database workflows, and application
integration.

The cloud environment is provided by Floci and runs as part of the
laboratory infrastructure.

The current implementation consists of:

- IAM
- S3
- SQS
- Lambda
- RDS PostgreSQL
- Secrets Manager
- CloudWatch Logs
- Papra

The services form an event-driven document processing workflow with
Papra acting as the document management application.


## Cloud Environment

The laboratory uses Floci to provide a local AWS-compatible environment.

AWS CLI is used as the primary management interface.

The environment uses:

    Region:
        eu-east-1

    Account:
        000000000000

AWS service endpoints are configured to point to the local Floci
environment rather than the public AWS infrastructure.

The purpose of this environment is to reproduce AWS service concepts
and workflows locally while keeping the laboratory infrastructure
self-contained.


## Architecture

The current cloud architecture is:

    Papra
    document management application
            |
            | Document upload
            v
    S3
    engineering-documents
            |
            | ObjectCreated
            v
    SQS
    document-processing
            |
            | Event Source Mapping
            v
    Lambda
    document-processor
            |
            +--------------------+
            |                    |
            | GetSecretValue     | INSERT
            v                    v
    Secrets Manager          RDS PostgreSQL
    database credentials     engineering-documents-db
            |
            |
            v
    CloudWatch Logs


## Document Processing Workflow

The current workflow begins when a document is uploaded through the
Papra document management application.

Papra stores uploaded documents in the `engineering-documents` S3 bucket.

S3 produces an object-created event which is delivered to the
`document-processing` SQS queue.

The Lambda function `document-processor` consumes messages from the
queue through an SQS Event Source Mapping.

The Lambda function extracts document metadata from the S3 event,
including:

- bucket
- object key
- event type
- event time
- ETag
- object size

The Lambda function retrieves PostgreSQL credentials from AWS
Secrets Manager and uses them to connect to the RDS PostgreSQL
database.

The extracted document metadata is then stored in the `documents`
table.

After successful Lambda execution, the processed SQS message is
deleted from the queue.

Papra provides the application-level document management interface,
while the cloud services provide document storage, asynchronous
processing, metadata persistence, identity, secrets, and logging.


## Identity and Access

Cloud services use IAM roles and policies to control access.

The Lambda execution role provides the permissions required by the
`document-processor` function.

The Lambda function has permission to retrieve the database secret
from Secrets Manager.

The secret is restricted to the database credentials used by the
document-processing workflow.

Papra uses credentials required to access its configured S3 storage
backend.

Other service permissions are intentionally limited to the resources
required by the laboratory workflow.


## Database

The workflow stores document metadata in PostgreSQL.

The current database contains a `documents` table used to record
information extracted from S3 events.

The database is used for processing metadata and state rather than
storing the uploaded document itself.

The document object remains in S3.


## Logging

Lambda execution logs are available through CloudWatch Logs.

The Lambda logs provide operational information about the document
processing workflow, including:

- function invocation
- received events
- extracted S3 event information
- processed document records
- processing errors

CloudWatch Logs therefore provides the primary operational visibility
for the current Lambda workflow.


## Current State

The following cloud components have been implemented and verified:

    Floci
        VERIFIED

    IAM
        VERIFIED

    S3
        VERIFIED

    SQS
        VERIFIED

    Lambda
        VERIFIED

    RDS PostgreSQL
        VERIFIED

    Secrets Manager
        VERIFIED

    CloudWatch Logs
        VERIFIED

    Papra
        VERIFIED


## Current Scope

The current cloud infrastructure provides the foundation for the
engineering document management and processing workflow.

Papra is now integrated as the application layer for document
management, with S3 providing object storage and the existing
SQS/Lambda/RDS workflow providing asynchronous document metadata
processing.

The infrastructure has been implemented incrementally and verified
through direct service operations and workflow tests.

Further cloud functionality can be built on top of this infrastructure
during the remaining stages of the project.
