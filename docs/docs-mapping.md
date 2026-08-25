PHASE             PRIMARY DOCUMENTATION
------------------------------------------------------------

0 Foundation      overview.md
                  virtualization.md
                  vms.md
                  incidents

1 Networking      network.md
                  networking.md
                  network procedures
                  network incidents

2 Cloud Lab       cloud.md
                  cloud/*.md

3 Cloud App       update cloud/*.md
                  cloud scenarios
                  cloud incidents

4 Terraform       update infrastructure/cloud docs
                  Terraform procedures where useful

5 Windows Server  active-directory.md
                  services.md
                  Windows/AD procedures
                  Windows incidents

6 Windows Client  vms.md
                  active-directory.md
                  domain-join.md
                  Windows procedures/incidents

7 File Services   services.md
                  permissions.md
                  file-service procedures

8 IT Support      troubleshooting procedures
                  incident documentation

9 ITSM            software/*
                  ITSM documentation
                  procedures/incidents

10 Review         EVERYTHING
                  architecture vs reality
                  security
                  DR
                  TODO



================================================================================
PHASE 0 — LAB FOUNDATION
================================================================================

STATUS: IN PROGRESS

                    PHASE 0
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
   FOUNDATION      IMPLEMENTATION   DOCUMENTATION
        |              |              |
       [x]            [x]            [ ]
                                      |
                                      v
                              FINAL REVIEW
                                      |
                                      v
                              PHASE 0 COMPLETE
                                      |
                                      v
                              PHASE 1 NETWORKING


================================================================================
CURRENT STAGE — DOCUMENTATION / FINAL REVIEW
================================================================================

IMPLEMENTATION
    [x] Project architecture
    [x] Repository
    [x] Documentation structure
    [x] Virtualization
    [x] engineering-lab
    [x] MINT01
    [x] DC01
    [x] WIN01
    [x] VM networking
    [x] Connectivity verification
    [x] Snapshots
    [x] Troubleshooting cases


DOCUMENTATION
    [x] architecture/overview.md
    [x] architecture/virtualization.md
    [x] infrastructure/vms.md
    [x] TRB-001
    [x] TRB-002
    [x] TRB-003

    [ ] architecture/network.md
    [ ] infrastructure/networking.md
    [ ] Phase 0 documentation review
    [ ] documentation-plan.md reconciliation


PHASE REVIEW
    [ ] Verify documentation against actual state
    [ ] Identify missing Phase 0 documentation
    [ ] Update documentation plan
    [ ] Review Git changes
    [ ] Commit Phase 0
    [ ] Mark Phase 0 COMPLETE


================================================================================
OUR IMMEDIATE TASK
================================================================================

We are NOT going to create every document in docs/.

We first ask:

    "What does Phase 0 actually require us to document?"


The process is:

    ACTUAL LAB
        |
        v
    REVIEW WHAT EXISTS
        |
        v
    COMPARE WITH DOCUMENTATION
        |
        v
    IDENTIFY GAPS
        |
        v
    UPDATE DOCUMENTATION PLAN
        |
        v
    WRITE REQUIRED DOCUMENTATION
        |
        v
    FINAL REVIEW
        |
        v
    COMMIT
