# Create Domain User

## Purpose

This procedure describes how to create a new user account in the `engineering.local` Active Directory domain.

The workflow places the user in the company `Users` OU, configures the account identity and initial password, enables the account, assigns the appropriate security group, and verifies the resulting configuration.

The procedure follows the laboratory access-control model:

```text
Create User
    |
    v
Place in Users OU
    |
    v
Configure Initial Password
    |
    v
Enable Account
    |
    v
Assign Security Group
    |
    v
Verify Account
```

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

Security Groups OU:

```text
OU=Groups,OU=Engineering Company,DC=engineering,DC=local
```

Current role-based security groups:

```text
GG-Engineering
GG-IT
GG-Management
```

---

## Prerequisites

Before creating the account:

* Active Directory Domain Services must be operational.
* The Active Directory PowerShell module must be available.
* The administrator must have sufficient permissions to create users.
* The intended username and display name must be known.
* The user's initial security group must be identified.

Verify the AD PowerShell module:

```powershell
Get-Module -ListAvailable ActiveDirectory
```

Import it if necessary:

```powershell
Import-Module ActiveDirectory
```

---

## 1. Define User Information

Define the user's identity and target OU.

Example:

```powershell
$UserName = "alice.miller"
$FirstName = "Alice"
$LastName = "Miller"
$UserPrincipalName = "$UserName@engineering.local"

$UsersOU = "OU=Users,OU=Engineering Company,DC=engineering,DC=local"
```

The naming convention used in the laboratory is:

```text
firstname.lastname
```

For example:

```text
alice.miller
john.smith
sarah.wilson
```

---

## 2. Check Whether the Account Already Exists

Before creating the account, verify that the requested username is not already present.

```powershell
Get-ADUser `
    -Filter "SamAccountName -eq '$UserName'"
```

If the command returns an existing account, do not create a duplicate account.

Investigate the existing account instead.

---

## 3. Create the User

Create the account in the company `Users` OU.

```powershell
New-ADUser `
    -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $UserName `
    -UserPrincipalName $UserPrincipalName `
    -Path $UsersOU `
    -AccountPassword (Read-Host "Enter password" -AsSecureString) `
    -Enabled $true
```

This creates the account with:

```text
Name
    Firstname Lastname

SamAccountName
    firstname.lastname

UPN
    firstname.lastname@engineering.local

OU
    OU=Users,OU=Engineering Company

Account
    Enabled
```

---

## 4. Assign the Appropriate Security Group

Users should receive resource access through Active Directory security groups rather than through direct permissions on resources.

For an Engineering user:

```powershell
Add-ADGroupMember `
    -Identity "GG-Engineering" `
    -Members $UserName
```

For an IT user:

```powershell
Add-ADGroupMember `
    -Identity "GG-IT" `
    -Members $UserName
```

For a Management user:

```powershell
Add-ADGroupMember `
    -Identity "GG-Management" `
    -Members $UserName
```

The group should correspond to the user's intended role.

The access model is:

```text
User
  |
  v
AD Security Group
  |
  v
Resource ACL
```

Do not assign resource permissions directly to the individual user unless there is a documented exception.

---

## 5. Verify the User Account

Verify the newly created account:

```powershell
Get-ADUser `
    -Identity $UserName `
    -Properties UserPrincipalName, Enabled |
    Select-Object `
        Name,
        SamAccountName,
        UserPrincipalName,
        Enabled,
        DistinguishedName
```

Expected result:

```text
Name
    Alice Miller

SamAccountName
    alice.miller

UserPrincipalName
    alice.miller@engineering.local

Enabled
    True

DistinguishedName
    CN=Alice Miller,OU=Users,OU=Engineering Company,...
```

---

## 6. Verify Group Membership

Check the user's group membership:

```powershell
Get-ADPrincipalGroupMembership $UserName |
    Select-Object Name, GroupScope, GroupCategory
```

The intended role group should be present.

For example:

```text
alice.miller
    |
    +-- GG-Engineering
```

---

## 7. Verify the Account from the Group Perspective

The corresponding group can also be inspected:

```powershell
Get-ADGroupMember "GG-Engineering" |
    Select-Object Name, SamAccountName, ObjectClass
```

This confirms that the account was successfully added to the intended security group.

---

## Phase 3 Example

Three domain users were created during Phase 3:

```text
OU=Users,OU=Engineering Company
    |
    +-- Alice Miller
    |      |
    |      +-- alice.miller
    |      +-- GG-Engineering
    |
    +-- John Smith
    |      |
    |      +-- john.smith
    |      +-- GG-IT
    |
    └-- Sarah Wilson
           |
           +-- sarah.wilson
           +-- GG-Management
```

The accounts were verified for:

```text
[x] Correct OU placement
[x] SamAccountName
[x] UserPrincipalName
[x] Enabled state
[x] Security group membership
```

---

## Troubleshooting

### User Already Exists

Check whether an account with the requested username exists:

```powershell
Get-ADUser `
    -Filter "SamAccountName -eq '$UserName'"
```

If an account exists, determine whether it is the intended account before making changes.

---

### User Was Created in the Wrong OU

Check the current Distinguished Name:

```powershell
Get-ADUser $UserName |
    Select-Object DistinguishedName
```

Move the account to the correct OU if required:

```powershell
Move-ADObject `
    -Identity (Get-ADUser $UserName).DistinguishedName `
    -TargetPath $UsersOU
```

Then verify the resulting location.

---

### User Has Incorrect Group Membership

Inspect current memberships:

```powershell
Get-ADPrincipalGroupMembership $UserName |
    Select-Object Name
```

Add the required role group:

```powershell
Add-ADGroupMember `
    -Identity "GG-Engineering" `
    -Members $UserName
```

Group removal should only be performed when the user's intended role has been confirmed.

---

### Account Is Disabled

Check the account:

```powershell
Get-ADUser `
    -Identity $UserName `
    -Properties Enabled |
    Select-Object Name, Enabled
```

If the account should be active:

```powershell
Enable-ADAccount -Identity $UserName
```

Then verify again.

---

## Verification Checklist

```text
USER CREATION
    [ ] Username confirmed
    [ ] Username does not already exist
    [ ] User created
    [ ] Correct first / last name
    [ ] Correct SamAccountName
    [ ] Correct UserPrincipalName
    [ ] Correct Users OU
    [ ] Initial password configured
    [ ] Account enabled

GROUP ASSIGNMENT
    [ ] Correct role identified
    [ ] Appropriate security group selected
    [ ] User added to security group
    [ ] Group membership verified

FINAL VERIFICATION
    [ ] User object verified
    [ ] OU placement verified
    [ ] Enabled state verified
    [ ] Group membership verified
```

## Result

A domain user is considered successfully provisioned when:

```text
AD User
    |
    +-- Correct identity
    +-- Correct OU
    +-- Enabled
    +-- Valid initial password
    |
    v
Role-based Security Group
    |
    v
Resource Access
```

User access should subsequently be controlled through the user's Active Directory security-group membership rather than direct permissions on individual resources.
