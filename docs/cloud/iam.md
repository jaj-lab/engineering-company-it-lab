# IAM

## Overview

The Engineering Company IT Lab uses IAM to model identity and access
control for the local AWS-compatible cloud environment provided by
Floci.

IAM is used to define:

- users
- roles
- policies
- trust relationships
- access permissions

The current implementation contains two primary access models:

    Application access
        |
        v
    IAM User
    engineering-app
        |
        v
    engineering-app-s3 policy


    Lambda execution
        |
        v
    IAM Role
    document-processor-role
        |
        +-- S3
        +-- SQS
        +-- CloudWatch Logs
        +-- Secrets Manager


## Cloud Environment

IAM operations are performed through the AWS CLI against the local
Floci environment.

    Region:
        eu-east-1

    Account:
        000000000000

The environment is AWS-compatible but runs locally. IAM behavior
therefore represents the concepts and configuration of AWS IAM while
also reflecting the limitations of the local implementation.


## IAM User

### engineering-app

The `engineering-app` IAM user represents an application-facing
identity used to test authenticated access to cloud resources.

The user has an access key that can be used by the AWS CLI.

The identity can be verified with:

    aws sts get-caller-identity


The user is associated with the:

    engineering-app-s3

policy.


## Application S3 Policy

The `engineering-app-s3` policy was created as a customer-managed IAM
policy.

Its intended purpose is to provide the application with access to the
`engineering-documents` bucket without granting unrelated
administrative permissions.

The policy contains the following permissions:

    s3:ListBucket
        Resource:
        arn:aws:s3:::engineering-documents

    s3:GetObject
    s3:PutObject
        Resource:
        arn:aws:s3:::engineering-documents/*


The policy does not intentionally grant permissions such as:

    s3:CreateBucket
    s3:DeleteBucket
    IAM management


### Policy Structure

The policy can be represented as:

    engineering-app-s3
            |
            +-- ListBucket
            |
            +-- GetObject
            |
            +-- PutObject
            |
            v
    engineering-documents


The policy is attached to the `engineering-app` user.


## Lambda Execution Role

### document-processor-role

The Lambda function does not use the `engineering-app` IAM user.

Instead, it uses a dedicated IAM role:

    document-processor-role

This follows the Lambda execution model where the function assumes an
execution role to obtain the permissions required during execution.


## Role Trust Policy

The role contains a trust policy allowing the Lambda service to assume
the role.

The trust relationship is:

    lambda.amazonaws.com
            |
            | sts:AssumeRole
            v
    document-processor-role


The trust policy therefore defines who can assume the role, while the
role's permission policies define what the assumed role can do.


## Lambda Permissions

The `document-processor-role` provides the permissions required by the
current document-processing workflow.


### S3

Lambda can read document objects from the engineering documents
bucket.

    s3:GetObject

Resource:

    arn:aws:s3:::engineering-documents/*


This allows the Lambda function to access objects associated with the
document-processing workflow.


### SQS

Lambda requires permission to consume messages from the
`document-processing` queue.

The role grants:

    sqs:ReceiveMessage
    sqs:DeleteMessage
    sqs:GetQueueAttributes

Resource:

    arn:aws:sqs:eu-east-1:000000000000:document-processing


These permissions support the SQS Event Source Mapping used by the
Lambda function.


### CloudWatch Logs

The Lambda execution role grants permissions required for Lambda
logging:

    logs:CreateLogGroup
    logs:CreateLogStream
    logs:PutLogEvents

The permissions allow the function to create and write its execution
logs.


### Secrets Manager

The Lambda function retrieves PostgreSQL credentials from Secrets
Manager.

The role therefore has:

    secretsmanager:GetSecretValue

The permission is restricted to the database secret:

    engineering/document-processor/database


The secret contains the credentials required by the Lambda function to
connect to the PostgreSQL database.


## Access Model

The resulting access model is:

    engineering-app
        |
        | IAM policy
        v
    engineering-app-s3
        |
        +-- S3 ListBucket
        +-- S3 GetObject
        +-- S3 PutObject
        |
        v
    engineering-documents


    Lambda
        |
        | assumes
        v
    document-processor-role
        |
        +-- S3 GetObject
        |
        +-- SQS ReceiveMessage
        +-- SQS DeleteMessage
        +-- SQS GetQueueAttributes
        |
        +-- CloudWatch Logs
        |
        +-- Secrets Manager GetSecretValue


## IAM Verification

The IAM configuration was verified through AWS CLI operations.

### List users

    aws iam list-users


### List roles

    aws iam list-roles


### List policies

    aws iam list-policies


### Verify application policy attachment

    aws iam list-attached-user-policies \
      --user-name engineering-app


### Verify Lambda role policy attachment

    aws iam list-attached-role-policies \
      --role-name document-processor-role


### Inspect Lambda role

    aws iam get-role \
      --role-name document-processor-role


### Inspect inline secret policy

    aws iam get-role-policy \
      --role-name document-processor-role \
      --policy-name document-processor-secrets


## Access Keys

An access key was created for the `engineering-app` IAM user to allow
authenticated AWS CLI operations.

Access keys can be listed with:

    aws iam list-access-keys \
      --user-name engineering-app

An access key can be removed with:

    aws iam delete-access-key \
      --user-name engineering-app \
      --access-key-id <ACCESS_KEY_ID>


Access keys are credentials and should not be stored in the Git
repository or documentation.


## Floci IAM Limitation

The IAM policies were designed to model resource-scoped access control.

For example, the `engineering-app-s3` policy intentionally grants
access to:

    engineering-documents

while denying access to unrelated bucket-management operations.

However, testing in the local Floci environment showed that the
configured policy restrictions were not fully enforced.

Operations outside the intended policy scope were still permitted in
the local environment.

The observed behavior can be summarized as:

    Policy design
          |
          v
    engineering-app-s3
          |
          v
    Intended restricted access
          |
          v
    Floci
          |
          +-- Policy-scoped operations     WORK
          |
          +-- Some otherwise unauthorized
              S3 operations                ALSO WORK


This is treated as a limitation of the local cloud environment rather
than the intended IAM design.

The policy configuration is therefore documented separately from the
observed authorization behavior.


## Security Considerations

The IAM configuration follows several basic access-control
principles:

- separate identities are used for application and Lambda execution
- Lambda uses an execution role rather than an IAM user
- permissions are explicitly defined through policies
- S3 permissions are scoped to the engineering documents bucket
- Lambda SQS permissions are scoped to the document-processing queue
- Lambda secret access is scoped to the database secret
- database credentials are stored in Secrets Manager rather than
  directly in the Lambda environment configuration

The local Floci IAM limitation means that these restrictions should not
be considered equivalent to verified AWS IAM enforcement.


## Current State

    engineering-app IAM user
        VERIFIED

    engineering-app-s3 policy
        VERIFIED

    document-processor-role
        VERIFIED

    Lambda trust relationship
        VERIFIED

    Lambda S3 permissions
        VERIFIED

    Lambda SQS permissions
        VERIFIED

    Lambda CloudWatch Logs permissions
        VERIFIED

    Lambda Secrets Manager permission
        VERIFIED

    Access key
        CONFIGURED

    IAM authorization testing
        COMPLETED

    Floci IAM enforcement limitation
        DOCUMENTED
