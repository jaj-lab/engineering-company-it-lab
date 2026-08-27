# INC-003 — Floci Data Missing After Compose Consolidation

## Summary

After consolidating the separate Floci and Papra Docker Compose projects
into a single root `compose.yaml`, the previously existing Floci AWS
state appeared to be missing.

The Floci container started successfully, but S3 buckets, SQS resources,
Lambda functions, RDS state, and other previously created resources were
not visible.

The data was not actually lost.

Docker Compose created a new project-scoped volume:

    engineering-company-it-lab_floci-data

instead of using the existing persistent Floci volume:

    floci_data

The issue was resolved by explicitly binding the Compose volume to the
existing `floci_data` volume.

---

## Impact

The consolidated Compose deployment initially started with an empty Floci
storage state.

Observed symptoms:

    S3 bucket engineering-documents     -> missing
    S3 objects                          -> missing
    RDS connectivity                    -> unavailable
    Existing AWS emulator state        -> missing

Papra itself started successfully.

No persistent Floci data was deleted or corrupted.

---

## Timeline

### 1. Original setup

Floci was running as an independent Compose project:

    cloud/floci/compose.yaml

with:

    services:
      app:
        ...
        volumes:
          - data:/app/data

    volumes:
      data:

Docker created the persistent volume:

    floci_data

Floci AWS resources were stored in this volume.

---

### 2. Compose consolidation

Floci and Papra were moved into the root Compose project:

    compose.yaml

The initial configuration used:

    volumes:
      floci-data:

This caused Docker Compose to create a new project-scoped volume:

    engineering-company-it-lab_floci-data

The new Floci container mounted this empty volume.

---

### 3. Symptoms

After starting the consolidated Compose project:

    docker compose up -d

the containers were running:

    engineering-company-it-lab-floci-1
    papra

However:

    aws s3api list-buckets \
      --endpoint-url http://localhost:4566

returned:

    {
        "Buckets": []
    }

The previously existing:

    engineering-documents

bucket was not visible.

---

## Investigation

### Check Docker volumes

    docker volume ls

The output showed both:

    engineering-company-it-lab_floci-data
    floci_data

This was the key indication that Docker was using two different
volumes.

---

### Check the original volume

The existing Floci volume was:

    floci_data

This contained the previously created AWS emulator state.

---

### Check the new Compose volume

The newly created volume was:

    engineering-company-it-lab_floci-data

This was created automatically because the volume was declared as a
normal Compose-managed volume without an explicit external name.

The volume was effectively empty from Floci's perspective.

---

## Root Cause

The root cause was a Docker Compose volume naming change.

The original Floci Compose project used:

    data:

which resolved to the Docker volume:

    floci_data

The new root Compose project used:

    floci-data:

which Compose resolved to:

    engineering-company-it-lab_floci-data

Therefore:

    OLD

    Floci
      |
      v
    floci_data
      |
      v
    existing AWS state


    NEW

    Floci
      |
      v
    engineering-company-it-lab_floci-data
      |
      v
    empty/new state

The underlying data was still present in:

    floci_data

---

## Resolution

The Compose volume was changed to explicitly reference the existing
Docker volume:

    volumes:
      floci-data:
        external: true
        name: floci_data

This tells Docker Compose:

    "Do not create a project-scoped volume.
     Use the existing Docker volume named floci_data."

The obsolete automatically-created volume was then removed:

    docker volume rm engineering-company-it-lab_floci-data

The consolidated Compose project was started again:

    docker compose up -d

---

## Verification

### Verify containers

    docker compose ps

Expected:

    engineering-company-it-lab-floci-1    ...    Up ... (healthy)
    papra                                  ...    Up ...

### Verify Floci S3 state

    aws s3api list-buckets \
      --endpoint-url http://localhost:4566

The previously existing buckets returned:

    engineering-documents
    awslambda-eu-east-1-tasks

This confirmed that the original Floci state had been restored by
mounting the correct persistent volume.

---

## Final Configuration

The final Compose configuration uses:

    volumes:
      floci-data:
        external: true
        name: floci_data

Therefore:

    Docker Compose
          |
          v
    floci service
          |
          v
    floci_data
          |
          +-- S3
          +-- SQS
          +-- Lambda
          +-- RDS
          +-- Secrets Manager
          +-- other Floci state

The Papra application uses its own persistent bind mount:

    ./app/papra/papra-data:/app/app-data

---

## Lessons Learned

### 1. Compose project names affect volume names

Compose automatically prefixes named volumes with the project name unless
the volume is explicitly configured otherwise.

For example:

    floci-data

can become:

    engineering-company-it-lab_floci-data

---

### 2. A running container does not mean the correct persistent state is mounted

Floci started successfully and reported healthy status, but it was using
a different volume.

Container health alone was therefore insufficient to verify persistence.

---

### 3. Always inspect volumes when persistent state appears to disappear

Useful commands:

    docker volume ls

    docker inspect <container>

    docker volume inspect <volume>

---

### 4. Existing state should be explicitly mapped during Compose migration

When moving a service between Compose projects, existing persistent volumes
should be explicitly identified and bound.

Example:

    volumes:
      floci-data:
        external: true
        name: floci_data

---

## Status

    RESOLVED

No persistent Floci data was lost.

The incident was caused by mounting a newly created Compose volume instead
of the existing persistent volume.
