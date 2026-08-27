================================================================================
S3 — ENGINEERING DOCUMENT STORAGE
================================================================================

PURPOSE
-------

Object storage for engineering documents in the local Floci environment.


PLATFORM
--------

Floci

Endpoint:

    http://localhost:4566


BUCKET
------

    engineering-documents


CURRENT STATE
-------------

    [x] Bucket created
    [x] Bucket exists
    [x] ListBucket verified
    [x] PutObject verified
    [x] GetObject verified


TEST OBJECT
-----------

    test/test-document.txt


TEST OBJECT STATUS
------------------

    Removed after verification.


EXPECTED OBJECT STRUCTURE
-------------------------

    engineering-documents/
    |
    +-- incoming/
    |
    +-- processed/
    |
    +-- failed/


IAM
---

Application identity:

    engineering-app

Policy:

    engineering-app-s3


Allowed S3 operations:

    s3:ListBucket
    s3:GetObject
    s3:PutObject


IMPORTANT PLATFORM LIMITATION
-----------------------------

During IAM verification, Floci allowed some S3 operations
that were not granted by the attached policy.

Observed:

    ListAllMyBuckets
    CreateBucket
    DeleteBucket

The IAM policy itself follows the intended least-privilege design.

The observed behavior is treated as a Floci authorization
implementation limitation.


VERIFICATION
------------

Bucket listing:

    aws --endpoint-url=http://localhost:4566 s3 ls


List objects:

    aws --endpoint-url=http://localhost:4566 s3api list-objects \
      --bucket engineering-documents


Upload:

    aws --endpoint-url=http://localhost:4566 s3api put-object \
      --bucket engineering-documents \
      --key test/test-document.txt \
      --body tmp/test-document.txt


Download:

    aws --endpoint-url=http://localhost:4566 s3api get-object \
      --bucket engineering-documents \
      --key test/test-document.txt \
      tmp/downloaded-document.txt


RESULT
------

S3 storage is implemented and verified.

The bucket is ready to become the storage component of the
Engineering Document Workflow.


================================================================================
