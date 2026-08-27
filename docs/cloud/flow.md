
# S3 BUCKET
### List S3 Buckets
aws --endpoint-url=http://localhost:4566 s3api list-buckets

### Create S3 Bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://engineering-documents  

aws --endpoint-url=http://localhost:4566 s3api create-bucket \
  --bucket unauthorized-bucket

### Delete S3 Bucket
aws --endpoint-url=http://localhost:4566 s3api delete-bucket \
  --bucket engineering-documents

### List S3 Bucket
aws --endpoint-url=http://localhost:4566 s3 ls

### List Object in Bucket
aws --endpoint-url=http://localhost:4566 s3api list-objects \
  --bucket <BUCKET_NAME>


# IAM (Identity & Access Model)
### List All
aws --endpoint-url=http://localhost:4566 iam list-users  
aws --endpoint-url=http://localhost:4566 iam list-roles  
aws --endpoint-url=http://localhost:4566 iam list-policies  


```
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
                |
                |
             ALLOWED


      CreateBucket  ────────> DENIED
      DeleteBucket  ────────> DENIED
      IAM management ───────> DENIED
      Other buckets ────────> DENIED
```


## USERS
### Create User
aws --endpoint-url=http://localhost:4566 iam create-user \
  --user-name engineering-app

### List User
aws --endpoint-url=http://localhost:4566 iam list-users

### Verify Caller Identity
aws --endpoint-url=http://localhost:4566 sts get-caller-identity

```
engineering-app
       |
       | attached policy
       v
engineering-documents-policy
       |
       v
S3 permissions
       |
       +-- ListBucket
       +-- GetObject
       +-- PutObject
```


## POLICY
### Create policy config
nano engineering-app-s3-policy.json

```
engineering-app-s3
      |
      +-- ListBucket
      +-- GetObject
      +-- PutObject

{
  "Version": "2026-08-25",
  "Statement": [
    {
      "Sid": "ListEngineeringDocumentsBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::engineering-documents"
    },
    {
      "Sid": "ReadWriteEngineeringDocuments",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::engineering-documents/*"
    }
  ]
}
```

### Append policy from file
aws --endpoint-url=http://localhost:4566 iam create-policy \
  --policy-name engineering-app-s3 \
  --policy-document file://engineering-app-s3-policy.json

### List Policies
aws --endpoint-url=http://localhost:4566 iam list-policies \
  --scope Local \
  --query 'Policies[].{Name:PolicyName,Arn:Arn}' \
  --output table

### Get Policy
aws --endpoint-url=http://localhost:4566 iam get-policy \
  --policy-arn arn:aws:iam::000000000000:policy/engineering-app-s3

### Get Policy Details
aws --endpoint-url=http://localhost:4566 iam get-policy-version \
  --policy-arn arn:aws:iam::000000000000:policy/engineering-app-s3 \
  --version-id v1

### Attach Policy to User
aws --endpoint-url=http://localhost:4566 iam attach-user-policy \
  --user-name engineering-app \
  --policy-arn arn:aws:iam::000000000000:policy/engineering-app-s3

### Verify attachment
aws --endpoint-url=http://localhost:4566 iam list-attached-user-policies \
  --user-name engineering-app

```
POLICY DESIGN
     │
     │ correct
     ▼
engineering-app-s3
     │
     │ attached
     ▼
engineering-app
     │
     │
     ▼
ACTUAL FLOCΙ
     │
┌──────────┴──────────┐
│                     │
Policy-scoped          Other S3 operations
operations             also permitted
│                     │
▼                     ▼
WORKS                WORKS
```

## ACCESS KEY
### Create access key for user
aws --endpoint-url=http://localhost:4566 iam create-access-key \
  --user-name engineering-app

### Delete access key
aws --endpoint-url=http://localhost:4566 iam delete-access-key \
  --user-name engineering-app \
  --access-key-id AKIAFGPJO4BWKWIH9HS8

### List access key
aws --endpoint-url=http://localhost:4566 iam list-access-keys \
  --user-name engineering-app

### Verify caller identity
aws --endpoint-url=http://localhost:4566 sts get-caller-identity


## OBJECT OPERATIONS
### List objects
aws --endpoint-url=http://localhost:4566 s3api list-objects \
  --bucket engineering-documents

### Put Object (Upload)
aws --endpoint-url=http://localhost:4566 s3api put-object \
  --bucket engineering-documents \
  --key files/test-document.txt \
  --body tmp/test-document.txtV

### Get Object (Download)
aws --endpoint-url=http://localhost:4566 s3api get-object \
  --bucket engineering-documents \
  --key files/test-document.txt \
  tmp/downloaded-document.txt


# SQS
```
S3
engineering-documents
|
| Object-created event
v
+-------------+
|     SQS     |
|             |
| document-   |
| processing  |
+------+------+
|
| Message
v
Lambda
document-processor
```


## QUEUEs

### Create the queue
aws sqs create-queue \
  --queue-name document-processing

Expected:
{
    "QueueUrl": "http://localhost:4566/000000000000/document-processing"
}

### List queues
aws sqs list-queues

### Get queue attributes
aws sqs get-queue-attributes \
  --queue-url http://localhost:4566/000000000000/document-processing \
  --attribute-names All


## MESSAGES
### Send a text message
aws sqs send-message \
  --queue-url http://localhost:4566/000000000000/document-processing \
  --message-body '{"event":"document-uploaded","bucket":"engineering-documents","key":"incoming/test-document.txt"}'

### Receive the message
aws sqs receive-message \
  --queue-url http://localhost:4566/000000000000/document-processing

### Inspect queue (number of messages)
aws sqs get-queue-attributes \
  --queue-url http://localhost:4566/000000000000/document-processing \
  --attribute-names ApproximateNumberOfMessages

### Delete the message
aws sqs delete-message \
  --queue-url http://localhost:4566/000000000000/document-processing \
  --receipt-handle "<RECEIPT_HANDLE>"
