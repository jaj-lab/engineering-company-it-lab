# STAGE 9 — APPLICATION INTEGRATION

```text
================================================================================
STAGE 9 — APPLICATION INTEGRATION
================================================================================

Objective:

    Deploy an existing document-management application
    and integrate it with the existing cloud workflow.

Application:

    Papra

Deployment:

    MINT01
        |
        v
    Docker
        |
        v
    Papra


Integration:

    Papra
        |
        | S3 API
        v
    Floci S3
        |
        | ObjectCreated
        v
    SQS
        |
        v
    Lambda
        |
        v
    RDS
```

---

# 0. Prerequisites

The following infrastructure must already exist from the previous stages:

```text
Floci
 |
 +-- S3
 |    |
 |    +-- engineering-documents
 |
 +-- SQS
 |    |
 |    +-- document-processing
 |
 +-- Lambda
 |    |
 |    +-- document-processor
 |
 +-- RDS
      |
      +-- engineering-documents-db
           |
           +-- documents
```

The Floci environment must be running before testing the complete
application workflow.

---

# 1. Create Papra Application Directory

From the project root:

```bash
cd ~/Projects/engineering-company-it-lab

mkdir -p app/papra
cd app/papra
```

Expected structure:

```text
engineering-company-it-lab/
|
+-- app/
|   |
|   +-- papra/
|
+-- cloud/
    |
    +-- floci/
```

---

# 2. Create Persistent Application Storage

Create directories for Papra persistent data:

```bash
mkdir -p papra-data/{db,documents}
```

Verify:

```bash
ls -la
ls papra-data/
```

Expected:

```text
papra-data/
+-- db/
+-- documents/
```

The purpose is to keep Papra application state and document data
outside the disposable container filesystem.

---

# 3. Create Papra Compose Configuration

Create the Compose file:

```bash
nano compose.yaml
```

Use the final Papra Compose configuration created for this stage.

The Compose configuration must provide:

```text
Papra container
    |
    +-- persistent application state
    |
    +-- persistent document storage
    |
    +-- environment configuration
    |
    +-- access to Floci through host.docker.internal
```

After creating the file:

```bash
cat compose.yaml
```

---

# 4. Configure Papra Environment

Create/edit the environment file:

```bash
nano .env
```

The configuration must contain the Papra storage settings required
to use the existing Floci S3-compatible endpoint.

Important configuration concepts:

```text
DOCUMENT_STORAGE_DRIVER
DOCUMENT_STORAGE_S3_ENDPOINT
DOCUMENT_STORAGE_S3_BUCKET_NAME
DOCUMENT_STORAGE_S3_REGION
DOCUMENT_STORAGE_S3_FORCE_PATH_STYLE
```

The actual values should match the final working configuration
used in this lab.

---

# 5. Validate Compose Configuration

Before starting the application:

```bash
docker compose config
```

The command must complete successfully without configuration errors.

---

# 6. Pull Papra Image

Pull the configured Papra image:

```bash
docker compose pull
```

---

# 7. Start Papra

Start the application:

```bash
docker compose up -d
```

Verify:

```bash
docker compose ps
```

If necessary:

```bash
docker compose ps -a
```

Expected:

```text
papra    ...    Up
```

---

# 8. Verify Papra Logs

Inspect the application logs:

```bash
docker compose logs --tail=100 papra
```

The application should start without fatal configuration or
database errors.

For additional inspection:

```bash
docker compose logs
```

---

# 9. Verify Papra Web UI

Open the Papra web interface using the configured application URL.

Verify:

```text
[ ] Papra web UI loads
[ ] Authentication works
[ ] Application is usable
[ ] Documents page is accessible
```

---

# 10. Verify Application Persistence

Restart Papra:

```bash
docker compose restart
```

Verify:

```bash
docker compose ps
```

Then open the Papra web UI again.

Verify that application state survives the restart.

```text
Container restart
       |
       v
Papra starts again
       |
       v
Persistent data restored
       |
       v
Application state remains available
```

---

# 11. Start Floci

The existing Floci environment is located under:

```text
cloud/floci/
```

Start it:

```bash
cd ~/Projects/engineering-company-it-lab/cloud/floci

docker compose up -d
```

Verify:

```bash
docker compose ps
```

Return to Papra:

```bash
cd ~/Projects/engineering-company-it-lab/app/papra
```

---

# 12. Verify Floci S3

Verify that the existing bucket is available:

```bash
aws s3 ls s3://engineering-documents \
  --endpoint-url http://localhost:4566
```

Verify the bucket directly:

```bash
aws s3api head-bucket \
  --bucket engineering-documents \
  --endpoint-url http://localhost:4566
```

List existing objects:

```bash
aws s3 ls s3://engineering-documents/ \
  --recursive \
  --endpoint-url http://localhost:4566
```

---

# 13. Verify Docker -> Floci Connectivity

Papra runs inside Docker while Floci exposes its S3-compatible
endpoint through the host.

The host-side endpoint is:

```text
http://localhost:4566
```

From inside the Papra container, use:

```text
http://host.docker.internal:4566
```

Verify that Docker can resolve the host:

```bash
docker compose exec papra \
  getent hosts host.docker.internal
```

---

# 14. Test Floci Endpoint From Papra Container

Test the Floci/LocalStack-compatible endpoint from inside Papra:

```bash
docker compose exec papra sh -c \
  'wget -qO- http://host.docker.internal:4566/_localstack/health || true'
```

Also test from the host:

```bash
curl -i http://localhost:4566/_localstack/health
```

The important distinction is:

```text
HOST
    |
    | localhost:4566
    v
Floci S3 endpoint


PAPRA CONTAINER
    |
    | host.docker.internal:4566
    v
HOST
    |
    v
Floci S3 endpoint
```

---

# 15. Verify Papra -> Floci Network Access Using Node

Papra's runtime can also be used to verify HTTP connectivity:

```bash
docker compose exec papra node -e \
'fetch("http://host.docker.internal:4566/_localstack/health").then(async r => console.log(r.status, await r.text())).catch(e => { console.error(e); process.exit(1) })'
```

A successful response confirms that the Papra container can reach
the Floci endpoint.

---

# 16. Configure Papra S3 Storage

Papra must use Floci instead of its local filesystem for document
storage.

The desired configuration is:

```text
Papra
 |
 | S3 API
 v
host.docker.internal:4566
 |
 v
Floci S3
 |
 v
engineering-documents
```

Inspect the effective environment inside the Papra container:

```bash
docker compose exec papra sh -c \
'env | grep -E "^(DOCUMENT_STORAGE|S3_|AWS_|APP_BASE_URL)" | sed "s/=.*/=<set>/"'
```

Inspect the relevant storage variables:

```bash
docker compose exec papra sh -c '
printf "DRIVER=%s\n" "$DOCUMENT_STORAGE_DRIVER"
printf "ENDPOINT=%s\n" "$DOCUMENT_STORAGE_S3_ENDPOINT"
printf "BUCKET=%s\n" "$DOCUMENT_STORAGE_S3_BUCKET_NAME"
printf "REGION=%s\n" "$DOCUMENT_STORAGE_S3_REGION"
printf "FORCE_PATH_STYLE=%s\n" "$DOCUMENT_STORAGE_S3_FORCE_PATH_STYLE"
printf "FILESYSTEM_ROOT=%s\n" "$DOCUMENT_STORAGE_FILESYSTEM_ROOT"
'
```

Expected concepts:

```text
DRIVER
    S3-compatible storage

ENDPOINT
    Floci endpoint reachable from Papra

BUCKET
    engineering-documents

REGION
    configured Floci/AWS-compatible region

FORCE_PATH_STYLE
    enabled as required by the S3-compatible endpoint
```

---

# 17. Restart Papra After Configuration

After modifying `.env` or `compose.yaml`, recreate the container:

```bash
docker compose down
docker compose up -d
```

Verify:

```bash
docker compose ps
```

Check logs:

```bash
docker compose logs --tail=100 papra
```

---

# 18. Verify S3 Bucket Before Upload

From the host:

```bash
aws s3 ls s3://engineering-documents \
  --endpoint-url http://localhost:4566
```

Verify the bucket:

```bash
aws s3api head-bucket \
  --bucket engineering-documents \
  --endpoint-url http://localhost:4566
```

List objects:

```bash
aws s3 ls s3://engineering-documents/ \
  --recursive \
  --endpoint-url http://localhost:4566
```

---

# 19. Upload a Document Through Papra

This is the primary Stage 9 application test.

Open the Papra web UI.

Create/upload a test document through the Papra interface.

Do NOT upload the document directly with the AWS CLI for this test.

The purpose is to verify:

```text
Papra
    |
    | application upload
    v
S3 API
    |
    v
Floci
```

After the upload, verify Papra logs if necessary:

```bash
docker compose logs --tail=100 papra
```

---

# 20. Verify Document Object in Floci S3

List the bucket:

```bash
aws s3 ls s3://engineering-documents/ \
  --recursive \
  --endpoint-url http://localhost:4566
```

A successful Papra upload should create an object under an
organization/document path similar to:

```text
org_<organization-id>/originals/doc_<document-id>.<extension>
```

Example observed during this stage:

```text
org_jco9kqjq9kfylkxdtgtlq1yh/originals/doc_e6txofn2dvhko7s0idmg3km7.txt
```

Papra may also generate additional objects as part of document
processing, for example extracted Markdown/content.

Observed example:

```text
org_jco9kqjq9kfylkxdtgtlq1yh/originals/doc_la69mef6lb6l1n3v3161i0i8.md
```

---

# 21. Verify S3 -> SQS

The Papra upload generates an S3 ObjectCreated event.

The existing cloud workflow is:

```text
Papra
    |
    | PutObject
    v
Floci S3
    |
    | ObjectCreated:Put
    v
SQS
    |
    v
document-processing
```

Inspect the Floci services:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

If necessary, inspect the Floci application logs:

```bash
docker logs floci-app-1 --tail 50
```

---

# 22. Verify SQS -> Lambda

The SQS event is consumed by:

```text
document-processor
```

Inspect the Lambda/document processor logs:

```bash
docker logs floci-document-processor-8c0a7074 --tail 30
```

The exact container name may change.

Find it with:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Expected workflow:

```text
S3 ObjectCreated
       |
       v
SQS message
       |
       v
document-processor
       |
       v
Lambda processing
```

---

# 23. Verify Lambda -> RDS

The Lambda function writes document metadata into PostgreSQL.

The existing RDS instance is:

```text
engineering-documents-db
```

Inspect it:

```bash
aws rds describe-db-instances \
  --db-instance-identifier engineering-documents-db
```

Important:

```text
RDS instance identifier:
    engineering-documents-db

PostgreSQL database:
    documents

PostgreSQL user:
    engineering
```

The RDS instance identifier is NOT the PostgreSQL username.

---

# 24. Determine RDS Endpoint

The Floci RDS-compatible service exposes PostgreSQL through its
container network.

The endpoint returned by the existing environment is expected to
look similar to:

```text
Address:
    172.18.0.2

Port:
    7001
```

Verify using:

```bash
aws rds describe-db-instances \
  --db-instance-identifier engineering-documents-db
```

---

# 25. Verify PostgreSQL Connectivity

Check that the PostgreSQL endpoint is reachable:

```bash
nc -vz 172.18.0.2 7001
```

Connect using the actual PostgreSQL credentials:

```bash
PGPASSWORD='password' psql \
  -h 172.18.0.2 \
  -p 7001 \
  -U engineering \
  -d documents
```

---

# 26. Verify Document Metadata

Query the database:

```bash
PGPASSWORD='password' psql \
  -h 172.18.0.2 \
  -p 7001 \
  -U engineering \
  -d documents \
  -c "
SELECT
    id,
    bucket,
    object_key,
    event_type,
    size_bytes,
    status,
    uploaded_at,
    processed_at
FROM documents
ORDER BY id;
"
```

The Papra-uploaded document should appear in the result.

Example observed result:

```text
 id | bucket                 | object_key
----+------------------------+---------------------------------------------------------------
  7 | engineering-documents  | org_jco9kqjq9kfylkxdtgtlq1yh/originals/doc_e6txofn2dvhko7s0idmg3km7.txt

 event_type:
     ObjectCreated:Put

 size_bytes:
     11

 status:
     received
```

---

# 27. Verify Complete End-to-End Workflow

The final workflow must be:

```text
================================================================================
END-TO-END DOCUMENT FLOW
================================================================================

                        MINT01
                           |
                           v
                        Docker
                           |
                           v
                         Papra
                           |
                           | Upload document
                           v
                    S3-compatible API
                           |
                           v
                     Floci S3
                           |
                           | ObjectCreated:Put
                           v
                          SQS
                           |
                           | message
                           v
                    document-processor
                        Lambda
                           |
                           | INSERT metadata
                           v
                    PostgreSQL RDS
                           |
                           v
                       documents
                           |
                           v
                  Document metadata
```

Verify each transition:

```text
[x] Papra is running
[x] Papra web UI works
[x] Papra state survives restart
[x] Papra is configured for S3 storage
[x] Papra can reach Floci
[x] Papra uploads document
[x] Document appears in Floci S3
[x] S3 generates ObjectCreated event
[x] Event reaches SQS
[x] SQS invokes document-processor
[x] Lambda processes event
[x] Lambda connects to RDS
[x] Lambda inserts metadata
[x] Metadata appears in documents table
```

---

# 28. Troubleshooting Notes

## 28.1 Papra cannot reach Floci

From the Papra container:

```bash
docker compose exec papra \
  getent hosts host.docker.internal
```

Then:

```bash
docker compose exec papra sh -c \
  'wget -qO- http://host.docker.internal:4566/_localstack/health || true'
```

Compare with host-side access:

```bash
curl -i http://localhost:4566/_localstack/health
```

Remember:

```text
Host:
    localhost:4566

Papra container:
    host.docker.internal:4566
```

---

## 28.2 Papra S3 configuration inspection

Use:

```bash
docker compose exec papra sh -c \
'env | grep -E "^(DOCUMENT_STORAGE|S3_|AWS_|APP_BASE_URL)" | sed "s/=.*/=<set>/"'
```

Then:

```bash
docker compose exec papra sh -c '
printf "DRIVER=%s\n" "$DOCUMENT_STORAGE_DRIVER"
printf "ENDPOINT=%s\n" "$DOCUMENT_STORAGE_S3_ENDPOINT"
printf "BUCKET=%s\n" "$DOCUMENT_STORAGE_S3_BUCKET_NAME"
printf "REGION=%s\n" "$DOCUMENT_STORAGE_S3_REGION"
printf "FORCE_PATH_STYLE=%s\n" "$DOCUMENT_STORAGE_S3_FORCE_PATH_STYLE"
printf "FILESYSTEM_ROOT=%s\n" "$DOCUMENT_STORAGE_FILESYSTEM_ROOT"
'
```

---

## 28.3 PostgreSQL role errors

The RDS environment uses:

```text
POSTGRES_USER=engineering
POSTGRES_DB=documents
```

Therefore this is correct:

```bash
psql -U engineering -d documents
```

These are incorrect:

```bash
psql -U postgres
psql -U engineering-documents-db
psql -U documents
```

The distinction is:

```text
RDS INSTANCE
    engineering-documents-db

POSTGRES ROLE
    engineering

DATABASE
    documents
```

---

## 28.4 PostgreSQL endpoint

Do not assume that the RDS instance identifier is the hostname.

Get the endpoint with:

```bash
aws rds describe-db-instances \
  --db-instance-identifier engineering-documents-db
```

Use the returned:

```text
Address
Port
```

For the current Floci environment:

```text
Address:
    172.18.0.2

Port:
    7001
```

---

# 29. Useful Inspection Commands

## Papra

```bash
cd ~/Projects/engineering-company-it-lab/app/papra

docker compose ps

docker compose ps -a

docker compose logs --tail=100 papra

docker compose restart
```

---

## Floci

```bash
cd ~/Projects/engineering-company-it-lab/cloud/floci

docker compose ps

docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

---

## S3

```bash
aws s3 ls s3://engineering-documents/ \
  --recursive \
  --endpoint-url http://localhost:4566
```

---

## RDS

```bash
aws rds describe-db-instances \
  --db-instance-identifier engineering-documents-db
```

```bash
PGPASSWORD='password' psql \
  -h 172.18.0.2 \
  -p 7001 \
  -U engineering \
  -d documents \
  -c "
SELECT
    id,
    bucket,
    object_key,
    event_type,
    size_bytes,
    status,
    uploaded_at,
    processed_at
FROM documents
ORDER BY id;
"
```

---

# 30. Final Architecture

```text
================================================================================
                    ENGINEERING COMPANY IT LAB
                    STAGE 9 — APPLICATION INTEGRATION
================================================================================


                         MINT01
                           |
                           v
                     Docker Compose
                           |
                           v
                         PAPRA
                           |
                           | S3 API
                           v
                    host.docker.internal
                           |
                           v
                    Floci / S3 API
                           |
                           v
                engineering-documents
                           |
                           | ObjectCreated
                           v
                  document-processing
                         SQS
                           |
                           v
                document-processor
                      Lambda
                           |
                           | GetSecretValue
                           v
                  Secrets Manager
                           |
                           | DB credentials
                           v
                document-processor
                           |
                           | PostgreSQL
                           v
                engineering-documents-db
                      PostgreSQL
                           |
                           v
                       documents


DOCUMENT DATA:

    Papra
       |
       +--> S3 object
       |
       +--> generated/extracted content


METADATA:

    S3 event
       |
       v
    SQS
       |
       v
    Lambda
       |
       v
    PostgreSQL
       |
       v
    documents table
```

---

# 31. Stage 9 Verification Checklist

```text
================================================================================
STAGE 9 — FINAL CHECK
================================================================================

DEPLOYMENT

    [x] Papra deployed with Docker
    [x] Papra container starts successfully
    [x] Papra web UI verified


PERSISTENCE

    [x] Persistent application storage configured
    [x] Papra restart tested
    [x] Application state persisted


S3 INTEGRATION

    [x] Papra configured for S3 storage
    [x] Floci S3 endpoint reachable from Papra
    [x] engineering-documents bucket accessible
    [x] Document uploaded through Papra
    [x] Object verified in Floci S3


EVENT PIPELINE

    [x] S3 ObjectCreated event generated
    [x] S3 -> SQS verified
    [x] SQS -> Lambda verified
    [x] Lambda -> RDS verified


DATABASE

    [x] PostgreSQL connectivity verified
    [x] documents database verified
    [x] documents table verified
    [x] Document metadata inserted
    [x] Metadata queried successfully


END-TO-END

    [x] Papra
          |
          v
        Floci S3
          |
          v
        SQS
          |
          v
        Lambda
          |
          v
        RDS
          |
          v
        documents


STATUS:

    COMPLETE
```

---

# 32. Stage 9 Result

```text
================================================================================
RESULT
================================================================================

The existing cloud infrastructure was successfully extended with
Papra as the application layer.

Papra is responsible for:

    - document management
    - document upload
    - application state
    - document processing

Floci provides:

    - S3-compatible object storage
    - SQS
    - Lambda
    - RDS PostgreSQL
    - Secrets Manager

The complete application workflow was verified:

    Papra
      |
      v
    Floci S3
      |
      v
    SQS
      |
      v
    Lambda
      |
      v
    RDS PostgreSQL


STAGE 9:

    COMPLETE
================================================================================
```
