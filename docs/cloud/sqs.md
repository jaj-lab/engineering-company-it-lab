# Amazon SQS

## Overview

The Engineering Company IT Lab uses Amazon SQS through the AWS-compatible
Floci environment to provide an asynchronous message queue between S3
and Lambda.

The current queue is:

    Name:
        document-processing

    Queue URL:
        http://localhost:4566/000000000000/document-processing

    Region:
        eu-east-1


## Purpose

SQS acts as the messaging layer between the S3 document bucket and the
Lambda processing function.

Instead of invoking Lambda directly from the document storage layer,
the S3 event is delivered to SQS first.

This provides an asynchronous boundary between document creation and
document processing.


## Architecture

The current workflow is:

    S3
    engineering-documents
        |
        | ObjectCreated event
        v
    SQS
    document-processing
        |
        | SQS message
        v
    Lambda
    document-processor


SQS therefore connects the storage layer with the serverless
processing layer.


## Queue

The queue was created using the AWS CLI:

    aws sqs create-queue \
      --queue-name document-processing


The queue can be inspected with:

    aws sqs get-queue-attributes \
      --queue-url http://localhost:4566/000000000000/document-processing \
      --attribute-names All


Queues can be listed with:

    aws sqs list-queues


## Message Structure

The queue receives S3 event notifications.

The resulting message contains the S3 event as its message body.

The general structure is:

    SQS message
        |
        +-- body
              |
              +-- S3 event
                    |
                    +-- Records[]
                          |
                          +-- eventName
                          +-- eventTime
                          +-- s3
                                |
                                +-- bucket
                                +-- object
                                      |
                                      +-- key
                                      +-- size
                                      +-- eTag


For the document-processing workflow, the important information is
the S3 bucket and object metadata contained inside the event.


## S3 Integration

The `engineering-documents` S3 bucket is configured to send
object-created events to the `document-processing` queue.

The workflow is:

    PutObject
        |
        v
    engineering-documents
        |
        | ObjectCreated
        v
    document-processing
        |
        | message available
        v
    Lambda


This allows newly created documents to enter the processing workflow
automatically.


## Message Lifecycle

The basic message lifecycle is:

    S3 ObjectCreated
        |
        v
    Message sent to SQS
        |
        v
    Message received by Lambda
        |
        v
    Lambda processes event
        |
        v
    Lambda succeeds
        |
        v
    Message deleted


A message can also be inspected manually using the AWS CLI.

Receive a message:

    aws sqs receive-message \
      --queue-url http://localhost:4566/000000000000/document-processing


The queue can be inspected using:

    aws sqs get-queue-attributes \
      --queue-url http://localhost:4566/000000000000/document-processing \
      --attribute-names ApproximateNumberOfMessages


A manually received message can be deleted using its receipt handle:

    aws sqs delete-message \
      --queue-url http://localhost:4566/000000000000/document-processing \
      --receipt-handle "<RECEIPT_HANDLE>"


## Lambda Integration

Lambda consumes the queue through an Event Source Mapping.

The current relationship is:

    document-processing
            |
            | Event Source Mapping
            v
    document-processor


The Event Source Mapping is configured with:

    Batch size:
        1

    State:
        Enabled


Lambda receives available SQS messages as invocation events.

After successful processing, the message is deleted through the
Lambda/SQS integration.


## IAM Permissions

The Lambda execution role has the SQS permissions required to consume
messages from the queue.

These permissions are:

    sqs:ReceiveMessage
    sqs:DeleteMessage
    sqs:GetQueueAttributes


The permissions are scoped to:

    arn:aws:sqs:eu-east-1:000000000000:document-processing


The queue therefore forms part of the Lambda execution access model.


## Verification

SQS was verified independently and as part of the complete document
processing workflow.

### Independent verification

A test message was sent manually:

    aws sqs send-message \
      --queue-url http://localhost:4566/000000000000/document-processing \
      --message-body '{"event":"document-uploaded","bucket":"engineering-documents","key":"incoming/test-document.txt"}'


The message was then received and inspected using:

    aws sqs receive-message \
      --queue-url http://localhost:4566/000000000000/document-processing


### S3 → SQS verification

A document was uploaded to:

    s3://engineering-documents/incoming/


The resulting event was delivered to:

    document-processing


The queue received the S3 event message successfully.


### SQS → Lambda verification

The Lambda Event Source Mapping consumed the message and invoked:

    document-processor


The Lambda successfully processed the S3 event and the SQS message was
subsequently deleted.


The verified workflow is:

    S3 PutObject
        |
        v
    S3 ObjectCreated
        |
        v
    SQS message
        |
        v
    Lambda invocation
        |
        v
    Successful processing
        |
        v
    SQS message deleted


## Current State

    document-processing queue
        IMPLEMENTED AND VERIFIED

    S3 → SQS integration
        IMPLEMENTED AND VERIFIED

    SQS message operations
        IMPLEMENTED AND VERIFIED

    Lambda Event Source Mapping
        IMPLEMENTED AND VERIFIED

    Lambda → SQS consumption
        IMPLEMENTED AND VERIFIED

    Successful message deletion
        IMPLEMENTED AND VERIFIED


## Scope

The current SQS implementation is intentionally simple and is focused
on demonstrating asynchronous event processing.

The laboratory currently uses SQS for:

    event buffering
    asynchronous processing
    S3 event delivery
    Lambda invocation

Advanced queue configuration such as dedicated dead-letter queues,
custom retry policies, visibility-timeout tuning, and failure recovery
strategies is outside the current implementation scope.
