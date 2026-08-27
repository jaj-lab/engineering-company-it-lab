
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


# LAMBDA
Lambda uses Role istead of IAM user + access key.

```
nano lambda-document-processor-trust-policy.json
{
  "Version": "2026-08-27",
  "Statement": [
    {
      "Sid": "AllowLambdaToAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}


lambda.amazonaws.com
        |
        | sts:AssumeRole
        v
document-processor-role
```

## Back to IAM

### Create the role
aws iam create-role \
  --role-name document-processor-role \
  --assume-role-policy-document file://lambda-document-processor-trust-policy.json

### Get/Verify the role
aws iam get-role \
  --role-name document-processor-role

### List roles
aws iam list-roles \
  --query 'Roles[].{Name:RoleName,Arn:Arn}' \
  --output table


## Permissions

### Policy for lambda role to do things
nano lambda-document-processor-policy.json

```
{
  "Version": "2026-08-27",
  "Statement": [
    {
      "Sid": "ReadDocumentObjects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::engineering-documents/*"
    },
    {
      "Sid": "ConsumeDocumentQueue",
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "arn:aws:sqs:eu-east-1:000000000000:document-processing"
    },
    {
      "Sid": "WriteLambdaLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

### Create that policy
aws iam create-policy \
  --policy-name document-processor \
  --policy-document file://lambda-document-processor-policy.json

### List policy
aws iam list-policies \
  --scope Local \
  --query 'Policies[].{Name:PolicyName,Arn:Arn}' \
  --output table

### Attach policy to the role
aws iam attach-role-policy \
  --role-name document-processor-role \
  --policy-arn arn:aws:iam::000000000000:policy/document-processor

### List attached policies to role
aws iam list-attached-role-policies \
  --role-name document-processor-role


## LAMBDA Functions

```
S3
 │
 │ ObjectCreated
 ▼
SQS
 │
 │ message
 ▼
Lambda
 │
 ├── read S3 object
 ├── process document
 └── log result
 ```

### Write lambda function

```
nano index.py

def handler(event, context):
    print("document-processor invoked")
    print(f"event: {event}")

    return {
        "statusCode": 200,
        "body": "document-processor executed successfully"
    }
```

Package it
zip function.zip index.py


### Create lambda function
aws lambda create-function \
  --function-name document-processor \
  --runtime python3.12 \
  --role arn:aws:iam::000000000000:role/document-processor-role \
  --handler index.handler \
  --zip-file fileb://function.zip

### Update lambda funciton
aws lambda update-function-code \
  --function-name document-processor \
  --zip-file fileb://function.zip

### List functions
aws lambda list-functions \
  --query 'Functions[].{Name:FunctionName,Runtime:Runtime,Role:Role}' \
  --output table

### Get function
aws lambda get-function \
  --function-name document-processor

### Get function configuration
aws lambda get-function-configuration \
  --function-name document-processor

### Manuall function invoke

```
cat > test-event.json <<'EOF'
{
  "test": true,
  "source": "manual"
}
EOF
```

aws lambda invoke \
  --function-name document-processor \
  --payload fileb://test-event.json \
  response.json


## EVENT SOURCE MAPPING
### Create source mapping
aws lambda create-event-source-mapping \
  --function-name document-processor \
  --event-source-arn "$QUEUE_ARN" \
  --batch-size 1 \
  --enabled

### List source mapping
aws lambda list-event-source-mappings \
  --function-name document-processor

aws lambda list-event-source-mappings \
  --function-name document-processor \
  --query 'EventSourceMappings[].{State:State,Queue:EventSourceArn,BatchSize:BatchSize,UUID:UUID}' \
  --output table

### TEST LAMBDA

```
index.py

import json


def handler(event, context):
    print("document-processor invoked")
    print(f"received SQS event: {event}")

    for record in event.get("Records", []):
        message_body = json.loads(record["body"])

        for s3_record in message_body.get("Records", []):
            event_name = s3_record["eventName"]
            bucket = s3_record["s3"]["bucket"]["name"]
            object_key = s3_record["s3"]["object"]["key"]

            print(f"event: {event_name}")
            print(f"bucket: {bucket}")
            print(f"object: {object_key}")

    return {
        "statusCode": 200,
        "body": "document processed successfully"
    }


rm -f function.zip

zip function.zip index.py
```

### Update the Lambda
aws lambda update-function-code \
  --function-name document-processor \
  --zip-file fileb://function.zip

### Test the func
cd ~/Projects/engineering-company-it-lab/cloud/s3

echo "Lambda SQS processing test" > tmp/lambda-processing-test.txt

aws s3api put-object \
  --bucket engineering-documents \
  --key incoming/lambda-processing-test.txt \
  --body tmp/lambda-processing-test.txt


```
S3 PutObject
    |
    v
engineering-documents
    |
    | ObjectCreated:Put
    v
document-processing (SQS)
    |
    | received 1 message
    v
document-processor (Lambda)
    |
    +--> parsed SQS event
    +--> extracted S3 event
    +--> extracted bucket
    +--> extracted object key
    |
    v
Lambda succeeded
    |
    v
SQS message deleted
```
