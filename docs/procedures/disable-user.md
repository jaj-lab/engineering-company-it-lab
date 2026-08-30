
# Disable Domain User

## Purpose

This procedure describes how to disable an existing user account in the `engineering.local` Active Directory domain.

Disabling an account prevents the user from authenticating while preserving the Active Directory user object, its identity, and existing group memberships for administrative and audit purposes.

This is a **standard operational procedure** for the Engineering Lab. It was not specifically performed as part of Phase 3.

The procedure follows:

```text
Identify Account
    |
    v
Disable AD Account
    |
    v
Verify Disabled State
    |
    v
Review Group Membership
    |
    v
Determine Whether Additional Access Changes Are Required
    |
    v
Verify
```

---

## Important Distinction

Disabling an account is not the same as deleting or fully deprovisioning it.

```text
Disable Account
    |
    +-- Authentication prevented
    +-- User object preserved
    +-- Group memberships preserved
    +-- Account can be re-enabled
```

Whereas deletion removes the AD user object:

```text
Delete Account
    |
    +-- User object removed
    +-- Recovery requires restoration/recreation
```

Therefore, **do not delete the user or automatically remove all group memberships as part of this procedure**.

If the organization requires complete offboarding, that should be handled as a separate documented workflow.

---

## Environment

Domain:

```text
engineering.local
```

Users OU:

```text
OU=Users,OU=Engineering Company,DC=engineering,DC=local
```

Current role-based security groups:

```text
GG-Engineering
GG-IT
GG-Management
```

---

## Prerequisites

Before disabling an account:

* Confirm the identity of the user.
* Confirm that the account should be disabled.
* Verify that the account is not a service account or another account requiring a different procedure.
* Ensure the administrator has sufficient Active Directory permissions.
* If the user is being disabled because of a role change or departure, determine whether additional access changes are required separately.

---

## 1. Identify the User Account

Search for the account before making changes.

```powershell
Get-ADUser `
    -Identity "username" `
    -Properties Enabled, UserPrincipalName, DistinguishedName |
    Select-Object `
        Name,
        SamAccountName,
        UserPrincipalName,
        Enabled,
        DistinguishedName
```

Confirm that the returned account is the intended user.

For example:

```text
Name
    John Smith

SamAccountName
    john.smith

UserPrincipalName
    john.smith@engineering.local

Enabled
    True
```

Do not proceed if the wrong account has been identified.

---

## 2. Check Current Group Membership

Review the user's current security-group membership before disabling the account.

```powershell
Get-ADPrincipalGroupMembership "username" |
    Select-Object Name, GroupScope, GroupCategory
```

For example, John Smith currently belongs to:

```text
john.smith
    |
    +-- GG-IT
```

This information should be reviewed before making additional access changes.

---

## 3. Disable the Account

Disable the account:

```powershell
Disable-ADAccount -Identity "username"
```

Example:

```powershell
Disable-ADAccount -Identity "john.smith"
```

The command disables the AD account without deleting the user object.

---

## 4. Verify the Disabled State

Verify that the account is now disabled:

```powershell
Get-ADUser `
    -Identity "username" `
    -Properties Enabled |
    Select-Object Name, SamAccountName, Enabled
```

Expected result:

```text
Name             SamAccountName    Enabled
----             --------------    -------
John Smith       john.smith        False
```

The important state is:

```text
Enabled = False
```

---

## 5. Verify Group Membership

Disabling the account does not automatically remove it from security groups.

Verify the memberships again:

```powershell
Get-ADPrincipalGroupMembership "username" |
    Select-Object Name, GroupScope, GroupCategory
```

Existing memberships should remain unless a separate access-management decision requires them to be changed.

For example:

```text
john.smith
    |
    +-- GG-IT
```

This preserves the user's existing AD object and its group-assignment history while authentication is disabled.

---

## 6. Verify Account State

Perform a final account inspection:

```powershell
Get-ADUser `
    -Identity "username" `
    -Properties Enabled, UserPrincipalName, DistinguishedName |
    Select-Object `
        Name,
        SamAccountName,
        UserPrincipalName,
        Enabled,
        DistinguishedName
```

Expected state:

```text
Account
    |
    +-- Exists
    +-- Correct identity
    +-- Correct OU
    +-- Enabled = False
    +-- Group memberships preserved unless separately changed
```

---

## 7. Authentication Verification

For a functional test, attempt authentication using the disabled account from an appropriate domain client.

The expected result is that authentication is rejected because the account is disabled.

Do not use repeated incorrect passwords as the test method, since the domain has an account-lockout policy.

The laboratory domain currently uses:

```text
Lockout threshold
    5 invalid attempts

Lockout duration
    1 minute
```

Therefore, the disabled-account state should be verified from Active Directory first, with an actual authentication test performed only when appropriate.

---

## Group Membership and Access

Disabling an account prevents normal authentication, but it does not rewrite the resource ACLs.

The Engineering Lab uses:

```text
User
  |
  v
AD Security Group
  |
  v
SMB / NTFS Resource Permissions
```

For example:

```text
John Smith
    |
    v
GG-IT
    |
    +-- Full Control -> IT
    +-- Full Control -> Engineering
    +-- Full Control -> Management
```

After disabling John Smith:

```text
John Smith
    |
    v
Account disabled
    |
    X
Authentication
```

The underlying group memberships and resource ACLs remain unchanged.

This is intentional.

If the user is permanently leaving the organization, **access deprovisioning should be handled as a separate process** rather than being implicitly performed by `Disable-ADAccount`.

---

## Re-enable Account

If the account was disabled temporarily and needs to be restored:

```powershell
Enable-ADAccount -Identity "username"
```

Verify:

```powershell
Get-ADUser `
    -Identity "username" `
    -Properties Enabled |
    Select-Object Name, SamAccountName, Enabled
```

Expected result:

```text
Enabled = True
```

Existing group memberships remain available unless they were separately modified.

---

## Troubleshooting

### Account Cannot Be Found

Verify the username:

```powershell
Get-ADUser `
    -Filter 'SamAccountName -eq "username"'
```

If necessary, search by name:

```powershell
Get-ADUser `
    -Filter 'Name -like "*Smith*"'
```

Confirm the correct account before making changes.

---

### Account Is Already Disabled

Check the current state:

```powershell
Get-ADUser `
    -Identity "username" `
    -Properties Enabled |
    Select-Object Name, Enabled
```

If:

```text
Enabled = False
```

no additional disable operation is required.

---

### Account Was Disabled Accidentally

Re-enable it:

```powershell
Enable-ADAccount -Identity "username"
```

Then verify:

```powershell
Get-ADUser `
    -Identity "username" `
    -Properties Enabled |
    Select-Object Name, Enabled
```

---

### User Still Appears in Security Groups

This is expected.

Disabling an account does not remove group memberships.

Inspect them with:

```powershell
Get-ADPrincipalGroupMembership "username" |
    Select-Object Name
```

If memberships must be changed, handle that as a separate access-management action.

---

## Verification Checklist

```text
ACCOUNT IDENTIFICATION
    [ ] User identity confirmed
    [ ] Correct account identified
    [ ] Account is not a service account
    [ ] Current account state inspected
    [ ] Current group membership reviewed

ACCOUNT DISABLE
    [ ] Disable-ADAccount executed
    [ ] Enabled state verified as False

ACCESS REVIEW
    [ ] Group membership reviewed
    [ ] Additional access requirements evaluated
    [ ] No unnecessary ACL changes made as part of disabling

FINAL VERIFICATION
    [ ] User object still exists
    [ ] Correct OU confirmed
    [ ] Account disabled
    [ ] Group memberships reviewed
    [ ] Authentication behavior verified where appropriate
```

## Result

A user account is considered successfully disabled when:

```text
AD User Object
    |
    +-- Preserved
    |
    +-- Enabled = False
    |
    +-- Group memberships preserved
    |
    v
Authentication
    |
    X
    DENIED
```

The account remains available for administrative review or future re-enablement.

Account deletion, group cleanup, data ownership transfer, and complete offboarding are intentionally outside the scope of this procedure.
