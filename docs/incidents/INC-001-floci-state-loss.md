================================================================================
INC-001 — FLOCΙ STATE LOST AFTER CONTAINER RECREATION
================================================================================

DATE
----

2026-08-27


SEVERITY
--------

LOW / LAB


STATUS
------

RESOLVED


SUMMARY
-------

AWS resources created inside Floci disappeared after the Floci
container was removed and recreated.

Affected resources included:

    S3 buckets
    IAM users
    IAM policies
    IAM access keys


EXPECTED BEHAVIOR
-----------------

Docker named volume:

    floci_data

was expected to preserve Floci state across container recreation.


OBSERVED BEHAVIOR
-----------------

The Docker volume survived:

    docker volume ls

    floci_data


The volume was correctly mounted:

    /app/data
        |
        v
    floci_data


However:

    /app/data

was empty after the container was recreated.

Floci started with a clean AWS state:

    S3 buckets:
        0

    IAM users:
        0

    IAM roles:
        0


INVESTIGATION
-------------

Verified Docker volume:

    docker volume inspect floci_data


Verified container mount:

    docker inspect floci-app-1 \
      --format '{{json .Mounts}}'


Result:

    floci_data
        ->
    /app/data


Verified contents:

    /var/lib/docker/volumes/floci_data/_data
        -> empty

    /app/data
        -> empty


ROOT CAUSE
----------

The Docker volume was mounted correctly, but Floci was using
in-memory storage.

A Docker volume does not automatically make application state
persistent.

The application itself must be configured to write its state
to the mounted storage.


ORIGINAL CONFIGURATION
----------------------

    services:
      app:
        image: floci/floci:latest
        volumes:
          - data:/app/data


This created the Docker storage correctly, but did not configure
Floci's storage mode.


CORRECTED CONFIGURATION
-----------------------

Floci was configured to use persistent storage:

    environment:
      FLOCI_STORAGE_MODE: hybrid
      FLOCI_STORAGE_PERSISTENT_PATH: /app/data


Final model:

    Floci
       |
       | persistent state
       v
    /app/data
       |
       v
    Docker named volume
       |
       v
    floci_data


WHY THIS MATTERS
----------------

This incident demonstrated an important infrastructure principle:

    "A mounted volume does not guarantee application persistence."

Persistence depends on BOTH:

    1. Storage being available
    2. The application actually using that storage


RECOVERY
--------

The previous Floci state could not be recovered because it had
only existed in the previous container's memory.

Therefore:

    Previous IAM resources:
        recreated

    Previous S3 resources:
        recreated

No production data was affected.

This is a development lab.


LESSON LEARNED
--------------

Do not verify persistence only by checking:

    docker volume ls


Instead verify the complete persistence path:

    Application
        |
        v
    Application storage configuration
        |
        v
    Mounted path
        |
        v
    Docker volume
        |
        v
    State survives recreation


PREVENTION
----------

Before continuing the cloud workflow:

    [x] Configure Floci persistent storage
    [x] Verify /app/data is mounted
    [x] Verify state is written to the volume
    [x] Recreate the container
    [x] Verify state survives


CURRENT STATUS
--------------

    RESOLVED

Floci is now configured for persistent storage.

The cloud lab can continue from the implementation stage
after persistence has been explicitly verified.


================================================================================
