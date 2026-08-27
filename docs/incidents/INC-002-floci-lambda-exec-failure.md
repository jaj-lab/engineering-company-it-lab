================================================================================
INC-002 — FLOCΙ LAMBDA EXECUTION FAILURE
================================================================================

STATUS

    RESOLVED


DATE

    2026-08-27


SYSTEM

    Floci
    Docker
    AWS Lambda


COMPONENT

    document-processor


================================================================================
SYMPTOM
================================================================================

Lambda function creation completed successfully.

However, manual invocation failed:


    aws lambda invoke \
      --function-name document-processor \
      --payload fileb://test-event.json \
      response.json


Initial result:


    StatusCode: 200
    FunctionError: Unhandled


Response:


    {
        "errorMessage":
            "Failed to start Lambda container:
             java.net.SocketException: No such file or directory",

        "errorType":
            "Lambda.InitError"
    }


The Lambda handler itself was not reached.


================================================================================
INVESTIGATION
================================================================================

Floci container logs showed:


    Launching container for function: document-processor

    RuntimeApiServer started on port 9200

    Creating DockerClient for host:
        unix:///var/run/docker.sock


    Running in Docker — using container IP for Runtime API:
        172.18.0.2


    Container launch failed for function document-processor

    java.net.SocketException: No such file or directory


This indicated that the problem occurred while Floci was attempting
to launch the Lambda execution container.


================================================================================
ROOT CAUSE
================================================================================

Floci itself runs inside a Docker container.

The original Floci Compose configuration provided the persistent
application data volume:


    volumes:

        - data:/app/data


However, the Docker socket was not mounted into the Floci container.


Therefore:


    HOST
      |
      | Docker daemon
      |
      X
      |
    FLOCΙ CONTAINER
      |
      X
      |
      Lambda execution container


Floci attempted to use:


    /var/run/docker.sock


but the socket was unavailable inside the container.


================================================================================
RESOLUTION
================================================================================

The host Docker socket was mounted into the Floci container.


Updated Compose configuration:


    services:

      app:
        image: floci/floci:latest

        ports:
          - "4566:4566"

        volumes:
          - data:/app/data
          - /var/run/docker.sock:/var/run/docker.sock


This provides Floci access to the host Docker daemon.


Resulting architecture:


    HOST
      |
      +------------------------------------------------+
      |                                                |
      | Docker daemon                                  |
      |      |                                         |
      |      | Docker socket                           |
      |      v                                         |
      |  FLOCΙ CONTAINER                               |
      |      |                                         |
      |      | Docker API                              |
      |      v                                         |
      |  LAMBDA EXECUTION CONTAINER                    |
      |      |                                         |
      |      v                                         |
      |  document-processor                            |
      |                                                |
      +------------------------------------------------+


================================================================================
VERIFICATION
================================================================================

Docker socket became available inside the Floci container:


    docker compose exec app ls -lah /var/run/docker.sock


Result:


    srw-rw---- 1 root docker-host 0 ... /var/run/docker.sock


Container mounts were verified:


    docker inspect floci-app-1 \
      --format '{{json .Mounts}}' | jq


Relevant mounts:


    /app/data
        -> floci_data


    /var/run/docker.sock
        -> /var/run/docker.sock


Lambda was invoked again:


    aws lambda invoke \
      --function-name document-processor \
      --payload fileb://test-event.json \
      response.json


Result:


    {
        "StatusCode": 200,
        "ExecutedVersion": "$LATEST"
    }


Lambda response:


    {
        "statusCode": 200,
        "body": "document-processor executed successfully"
    }


================================================================================
IMPACT
================================================================================

Before resolution:


    Lambda creation       [OK]
    Lambda invocation    [FAILED]
    Lambda execution     [FAILED]


After resolution:


    Lambda creation       [OK]
    Lambda invocation    [OK]
    Lambda execution     [OK]


Other previously verified services were unaffected:


    S3                     [OK]
    IAM                    [OK]
    SQS                    [OK]


================================================================================
SECURITY CONSIDERATION
================================================================================

Mounting:


    /var/run/docker.sock


into a container provides that container with powerful access
to the host Docker daemon.

This configuration is acceptable for the local engineering lab
because Floci requires Docker access to launch Lambda execution
containers.

It should not automatically be considered an appropriate
production security architecture.


================================================================================
LESSON LEARNED
================================================================================

A containerized cloud emulator may itself depend on the host
container runtime to implement certain services.

Therefore, when debugging service execution failures, verify
both:


    APPLICATION CONFIGURATION
        |
        +-- Lambda function
        +-- runtime
        +-- handler
        |
        v

    PLATFORM DEPENDENCIES
        |
        +-- Docker daemon
        +-- Docker socket
        +-- execution containers


A successful Lambda function creation does not guarantee that
the Lambda execution environment can actually be started.


================================================================================
FINAL STATE
================================================================================


    Floci
      |
      | Docker socket
      v
    Docker daemon
      |
      v
    Lambda execution container
      |
      v
    document-processor
      |
      v
    SUCCESS


INC-002 CLOSED


================================================================================
