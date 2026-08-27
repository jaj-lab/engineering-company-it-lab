================================================================================
AWS ARCHITECTURE — PROJECT INTRODUCTION PROMPT
================================================================================

I am building the ENGINEERING COMPANY IT LAB.

The cloud environment is implemented locally on MINT01 using:

    Docker
        ↓
    Floci
        ↓
    AWS-compatible APIs

Floci is NOT AWS itself.

It is a local AWS-compatible cloud laboratory that lets us
practice AWS-style architecture without depending on a real
AWS account.

The current endpoint is:

    http://localhost:4566

The AWS CLI is configured to communicate with Floci through:

    --endpoint-url=http://localhost:4566


================================================================================
1. AWS ARCHITECTURE — THE BIG PICTURE
================================================================================

Explain AWS architecture to me from the perspective of
an infrastructure / systems administrator who is new to AWS.

Start with the basic mental model:

    AWS
     |
     +-- Regions
     |     |
     |     +-- Availability Zones
     |
     +-- Services
     |
     +-- Resources
     |
     +-- IAM identities / permissions
     |
     +-- Networking
     |
     +-- Data
     |
     +-- Applications
     |
     +-- Monitoring / logging
     |
     +-- Security


Explain what each of these concepts means and how they
relate to each other.

Do NOT turn this into an academic AWS course.

Explain only enough architecture to understand what
we are actually going to build.


================================================================================
2. REGION
================================================================================

Explain:

    What is an AWS Region?

    Why do resources belong to a Region?

    Why does the AWS CLI require:

        --region

    What does:

        eu-east-1

    mean in our lab?

Clarify the difference between:

    AWS Region
    Availability Zone
    local Floci environment


================================================================================
3. IAM
================================================================================

Explain AWS Identity and Access Management.

Cover:

    IAM
    Users
    Groups
    Roles
    Policies
    Access Keys
    Permissions
    Least Privilege


Explain the difference between:

    Authentication
        =
    Who are you?

and:

    Authorization
        =
    What are you allowed to do?


Explain why IAM exists independently from services
such as S3, Lambda and RDS.

Show the relationship:

    IAM
     |
     +-- User
     |
     +-- Role
     |
     +-- Policy
             |
             +-- S3 permissions
             +-- SQS permissions
             +-- Lambda permissions
             +-- RDS permissions
             +-- Secrets permissions


================================================================================
4. S3
================================================================================

Explain Amazon S3.

Cover:

    Bucket
    Object
    Key
    Metadata
    Storage
    Access permissions


Explain the architecture:

    Application
        |
        v
    S3 Bucket
        |
        +-- Object
        +-- Object
        +-- Object


Explain why S3 is called object storage.

Explain how S3 differs conceptually from:

    filesystem
    block storage
    relational database


Our first cloud resource is:

    engineering-documents

Explain why this is a good resource for our
Engineering Document Workflow.


================================================================================
5. SQS
================================================================================

Explain Amazon Simple Queue Service.

Explain:

    Queue
    Message
    Producer
    Consumer
    Visibility timeout
    Message lifecycle


Architecture:

    Application
        |
        | message
        v
    SQS Queue
        |
        | message
        v
    Consumer


Explain why SQS exists between application components.

Explain the difference between:

    synchronous communication

and:

    asynchronous communication


Connect this to our engineering document workflow.


================================================================================
6. LAMBDA
================================================================================

Explain AWS Lambda.

Cover:

    Function
    Invocation
    Event
    Runtime
    Execution
    Permissions


Architecture:

    Event
       |
       v
    Lambda Function
       |
       v
    Processing
       |
       +-- S3
       +-- SQS
       +-- RDS
       +-- Secrets Manager


Explain what "serverless" means.

Clarify:

    serverless != no servers

Explain what AWS manages for us versus what
we manage ourselves.


================================================================================
7. RDS
================================================================================

Explain Amazon Relational Database Service.

Cover:

    Database instance
    Engine
    Database
    Tables
    Connections
    Credentials
    Networking


Explain why RDS exists separately from S3.

Compare:

    S3
        =
    object storage

    RDS
        =
    relational database


Explain how an application might use both.


================================================================================
8. SECRETS MANAGER
================================================================================

Explain AWS Secrets Manager.

Cover:

    Secret
    Secret value
    Access control
    Application retrieval
    Secret rotation


Explain why credentials should NOT be stored directly
inside application source code.

Architecture:

    Application
        |
        v
    Secrets Manager
        |
        v
    Database credentials


Explain how IAM controls access to the secret.


================================================================================
9. CLOUD NETWORKING
================================================================================

Introduce AWS networking only to the level required
for our project.

Explain:

    VPC
    Subnet
    Route Table
    Internet Gateway
    Security Group
    Private vs Public resources


Show the conceptual architecture:

    VPC
     |
     +-- Public Subnet
     |
     +-- Private Subnet
             |
             +-- Application
             +-- Database


Explain why databases are normally placed in
private networks.

Compare this concept with our current libvirt network:

    engineering-lab
    192.168.100.0/24


Make the distinction clear:

    libvirt network
        =
    our local infrastructure network

    VPC
        =
    AWS cloud network


Do not introduce complex AWS networking unless
our implementation actually requires it.


================================================================================
10. LOGGING / MONITORING
================================================================================

Explain the role of:

    CloudWatch
    CloudWatch Logs
    Metrics
    Alarms


Architecture:

    Service
       |
       +-- Logs
       |
       +-- Metrics
       |
       v
    CloudWatch


Explain the difference between:

    logs
    metrics
    traces

Only cover traces if necessary.


================================================================================
11. OUR ENGINEERING DOCUMENT WORKFLOW
================================================================================

Explain how all the services fit together.

Target architecture:

    Employee
        |
        v
    Application
        |
        v
    S3
        |
        v
    SQS
        |
        v
    Lambda
       / \
      /   \
     v     v
   RDS   Secrets Manager
     |
     v
   Data


IAM sits across the architecture:

    IAM
     |
     +-- Application permissions
     +-- Lambda permissions
     +-- S3 permissions
     +-- SQS permissions
     +-- RDS-related permissions
     +-- Secrets permissions


Monitoring/logging sits across the architecture:

    CloudWatch
        |
        +-- Application logs
        +-- Lambda logs
        +-- Service metrics
        +-- Operational visibility


================================================================================
12. SERVICES WE WILL ACTUALLY COVER
================================================================================

For PHASE 2, focus primarily on:

    IAM
    S3
    SQS
    Lambda
    RDS
    Secrets Manager


Supporting concepts:

    Region
    VPC
    Subnets
    Routing
    Security Groups
    CloudWatch / Logs


Do NOT automatically implement every service
provided by Floci.

Floci exposes many AWS-compatible services, but
availability does not mean that our architecture
requires them.


The architecture should be driven by the
Engineering Company scenario.


================================================================================
13. SERVICE RELATIONSHIPS
================================================================================

Create a clear dependency map:

    IAM
      |
      +-------------------------------+
      |                               |
      v                               v
     S3                              SQS
      |                               |
      |                               v
      |                            Lambda
      |                              / \
      |                             /   \
      v                            v     v
    Objects                       RDS   Secrets
                                     
    CloudWatch / Logs
        |
        +-- S3-related operations
        +-- SQS-related operations
        +-- Lambda
        +-- application


Explain which services:

    store data
    process data
    transport messages
    authenticate/authorize
    store secrets
    provide compute
    provide networking
    provide monitoring


================================================================================
14. WHAT WE SHOULD BUILD FIRST
================================================================================

Explain the implementation order.

Our current state:

    [x] Floci deployed
    [x] AWS CLI installed
    [x] AWS CLI configured
    [x] API connectivity verified
    [x] S3 API verified
    [x] engineering-documents bucket created


Recommended implementation direction:

    IAM
      ↓
    S3
      ↓
    SQS
      ↓
    Lambda
      ↓
    RDS
      ↓
    Secrets Manager
      ↓
    Application workflow
      ↓
    Logging / monitoring


Explain why this order makes sense.


================================================================================
15. IMPORTANT AWS MENTAL MODEL
================================================================================

Teach me to think about AWS resources using:

    WHO
      |
    IAM
      |
    WHAT
      |
    SERVICE
      |
    WHERE
      |
    REGION / NETWORK
      |
    DATA
      |
    STORAGE / DATABASE
      |
    HOW
      |
    API / EVENT / MESSAGE
      |
    OBSERVE
      |
    LOGS / METRICS
      |
    SECURE
      |
    IAM / SECURITY GROUPS / SECRETS


The goal is to stop thinking about AWS as
"lots of separate services".

Instead, understand it as:

    IDENTITIES
        +
    COMPUTE
        +
    STORAGE
        +
    DATABASES
        +
    NETWORKING
        +
    MESSAGING
        +
    SECURITY
        +
    OBSERVABILITY


================================================================================
16. TEACHING STYLE
================================================================================

I am learning this while implementing the lab.

Therefore:

    Explain architecture before implementation.

    Do not dump every AWS feature.

    Do not turn this into certification preparation.

    Do not explain services we have no reason to use.

    Connect every AWS concept to:

        ENGINEERING COMPANY IT LAB


When introducing a service, always explain:

    1. What problem does it solve?

    2. What is the main AWS resource?

    3. How does an application interact with it?

    4. How does IAM control it?

    5. Where does the data live?

    6. How does it connect to other services?

    7. Why do WE need it in this project?

    8. What will we actually implement in Floci?


The final objective is not to memorize AWS services.

The objective is to understand why these services
exist and how they form a working infrastructure
architecture.


================================================================================
CURRENT PROJECT CONTEXT
================================================================================

Current phase:

    PHASE 2 — CLOUD


Current stage:

    STAGE 1 — FLOCI FOUNDATION


Already implemented:

    Floci
    Docker Compose
    Persistent storage
    AWS CLI
    Local AWS-compatible API
    S3
    engineering-documents bucket


Current endpoint:

    http://localhost:4566


Current bucket:

    s3://engineering-documents


Next objective:

    Understand the AWS architecture required for the
    Engineering Document Workflow before implementing
    additional cloud services.


================================================================================
END OF PROMPT
================================================================================
