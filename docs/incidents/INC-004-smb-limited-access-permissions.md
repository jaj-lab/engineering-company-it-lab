# INC-004 — SMB Share Permissions Limited Domain Users to Read Access

## Summary

During Phase 3.18 — User / Group / Permission Behavior verification,
domain SMB shares were found to be accessible but effectively read-only.

The NTFS permissions on the `C:\CompanyData` directories were correctly
configured to grant `GG-IT` Full Control.

However, the SMB share permissions for the `Engineering`, `IT`, and
`Management` shares were configured as:

```
Everyone    Allow    Read
```

Because SMB share permissions and NTFS permissions are both evaluated,
the restrictive SMB share permission limited the effective access of
`GG-IT` users to Read, despite their NTFS Full Control permissions.

The issue was identified when `engineering\john.smith`, a member of
`GG-IT`, could access all three shares but could not create files.

The issue was resolved by changing the SMB share permissions to:

```
Everyone    Allow    Full
```

while retaining the existing NTFS ACLs as the primary authorization
mechanism.

---

## Impact

Affected resources:

```
\\DC01\Engineering
\\DC01\IT
\\DC01\Management
```

Observed behavior before remediation:

```
Share access       -> Allowed
Directory listing  -> Allowed
File creation      -> Denied
File modification  -> Denied
```

The issue prevented users from performing write operations through SMB
shares.

No data was lost, deleted, or corrupted.

The underlying NTFS permissions were not incorrect.

---

## Timeline

### 1. SMB shares created

The following SMB shares were created on DC01:

```
Engineering -> C:\CompanyData\Engineering
IT           -> C:\CompanyData\IT
Management   -> C:\CompanyData\Management
```

The shares were intended to provide network access to the corresponding
company data directories.

---

### 2. NTFS permissions verified

The NTFS permissions for the IT directory were:

```
CREATOR OWNER              Full Control
NT AUTHORITY\SYSTEM        Full Control
BUILTIN\Administrators     Full Control
ENGINEERING\GG-IT          Full Control
```

The corresponding Engineering and Management directories had their
intended group-based NTFS permissions.

For example:

```
Engineering
    GG-Engineering    Modify
    GG-IT             Full Control

IT
    GG-IT             Full Control

Management
    GG-IT             Full Control
    GG-Management     Modify
```

The NTFS configuration therefore appeared correct.

---

### 3. SMB share ACL discovered

The SMB permissions were inspected using:

```
Get-SmbShareAccess -Name "Engineering"
Get-SmbShareAccess -Name "IT"
Get-SmbShareAccess -Name "Management"
```

The result for all three shares was:

```
Everyone    Allow    Read
```

This revealed that the SMB layer was more restrictive than the NTFS
layer.

---

## Symptoms

The affected user was:

```
engineering\john.smith
```

The user's group membership was verified:

```
ENGINEERING\GG-IT
```

The user could successfully access all three shares:

```
Test-Path "\\DC01\IT"
Test-Path "\\DC01\Engineering"
Test-Path "\\DC01\Management"
```

Results:

```
True
True
True
```

However, attempting to create files failed:

```
"IT test" | Out-File "\\DC01\IT\john-test.txt"
"Engineering test" | Out-File "\\DC01\Engineering\john-test.txt"
"Management test" | Out-File "\\DC01\Management\john-test.txt"
```

The result was:

```
Access to the path ... is denied.
```

This initially appeared inconsistent with the NTFS configuration because
`GG-IT` had Full Control on the directories.

---

## Investigation

### Verify user identity

On WIN01:

```
whoami
```

Result:

```
engineering\john.smith
```

---

### Verify group membership

```
whoami /groups
```

The user was confirmed to be a member of:

```
ENGINEERING\GG-IT
```

Therefore the user's Active Directory group membership was correct.

---

### Verify NTFS permissions

On DC01:

```
Get-Acl "C:\CompanyData\IT" |
    Select-Object -ExpandProperty Access |
    Format-Table IdentityReference, FileSystemRights,
        AccessControlType, IsInherited
```

The relevant permission was:

```
ENGINEERING\GG-IT    FullControl    Allow    False
```

This confirmed that NTFS was granting the expected permissions.

---

### Verify SMB permissions

The share ACL was:

```
Get-SmbShareAccess -Name "IT"
```

Result:

```
IT    *    Everyone    Allow    Read
```

The same configuration existed on the Engineering and Management
shares.

This explained the discrepancy.

---

## Root Cause

The root cause was a mismatch between SMB share permissions and NTFS
permissions.

The intended configuration was:

```
GG-IT
    |
    +-- NTFS -> Full Control
    |
    +-- SMB  -> sufficient access for write operations
```

The actual configuration was:

```
GG-IT
    |
    +-- NTFS -> Full Control
    |
    +-- SMB  -> Everyone: Read
```

SMB share permissions therefore restricted the effective access.

The authorization path was effectively:

```
SMB Share Permission
      +
NTFS Permission
      |
      v
Effective Access
```

For John:

```
SMB     = Read
NTFS    = Full Control
-----------------------
Effective = Read
```

Therefore:

```
Read directory       -> SUCCESS
Access share         -> SUCCESS
Create file          -> DENIED
Modify file          -> DENIED
```

The presence of Full Control in the NTFS ACL did not override the
restrictive SMB share permission.

---

## Resolution

The SMB share permissions were changed to allow Full Control at the
share layer.

For the IT share:

```
Revoke-SmbShareAccess `
    -Name "IT" `
    -AccountName "Everyone" `
    -Force

Grant-SmbShareAccess `
    -Name "IT" `
    -AccountName "Everyone" `
    -AccessRight Full `
    -Force
```

The resulting configuration was verified:

```
Get-SmbShareAccess -Name "IT"
```

Result:

```
IT    *    Everyone    Allow    Full
```

The same correction was applied to the Engineering and Management
shares.

The intended security restrictions remain enforced by the NTFS ACLs.

---

## Verification

### Verify share access

From WIN01 as `engineering\john.smith`:

```
Test-Path "\\DC01\IT"
Test-Path "\\DC01\Engineering"
Test-Path "\\DC01\Management"
```

Results:

```
True
True
True
```

---

### Verify file creation

The following operations were then performed successfully:

```
"IT test" |
    Out-File "\\DC01\IT\john-test.txt"

"Engineering test" |
    Out-File "\\DC01\Engineering\john-test.txt"

"Management test" |
    Out-File "\\DC01\Management\john-test.txt"
```

No access-denied errors were returned.

---

### Verify files

```
dir "\\DC01\IT"
dir "\\DC01\Engineering"
dir "\\DC01\Management"
```

The following files were successfully created:

```
IT
    john-test.txt

Engineering
    john-test.txt

Management
    john-test.txt
```

This confirmed that `GG-IT` users could now perform the expected write
operations through SMB.

---

## Final Permission Model

The final configuration separates network share access from actual
resource authorization.

### SMB Share Layer

```
Engineering
    Everyone -> Full

IT
    Everyone -> Full

Management
    Everyone -> Full
```

### NTFS Layer

```
Engineering
    GG-Engineering -> Modify
    GG-IT          -> Full Control

IT
    GG-IT          -> Full Control

Management
    GG-Management  -> Modify
    GG-IT          -> Full Control
```

Therefore NTFS permissions determine which users are actually authorized
to access or modify the underlying data.

---

## Expected Effective Access

```
User              Group               Engineering   IT   Management
----------------------------------------------------------------------
Alice Miller      GG-Engineering          Modify     -       -
John Smith        GG-IT                    Full      Full    Full
Sarah Wilson      GG-Management             -        -      Modify
```

The remaining positive and negative access cases will be verified as
part of Phase 3.18.

---

## Lessons Learned

### 1. SMB and NTFS permissions are separate security layers

Granting Full Control through NTFS does not automatically provide Full
Control through an SMB share.

Both layers must permit the requested operation.

---

### 2. `Test-Path` does not prove write access

The following can succeed even when the user cannot create files:

```
Test-Path "\\DC01\IT"
```

A successful path test only demonstrates that the resource can be
accessed. Write operations must be tested separately.

---

### 3. Test actual operations, not only ACL configuration

The configuration appeared correct from the NTFS perspective.

The problem became obvious only when an actual write operation was
performed:

```
Out-File "\\DC01\IT\john-test.txt"
```

Operational testing therefore revealed an issue that static ACL inspection
alone did not immediately expose.

---

### 4. Share permissions can be intentionally broad when NTFS controls access

The final configuration uses permissive SMB share permissions and keeps
the detailed authorization model in NTFS.

This makes the NTFS ACL the primary access-control mechanism for the
CompanyData directories.

---

### 5. Group-based permissions remain the security boundary

The `GG-*` groups remain responsible for determining which users have
access to which data.

The SMB share configuration provides the necessary network-level access,
while NTFS determines the actual authorization.

---

## Status

```
RESOLVED
```

SMB write access was restored for authorized users.

NTFS permissions remained unchanged.

`GG-IT` users can now access and modify all intended CompanyData shares.

Phase 3.18 permission-boundary testing can continue with the
Engineering and Management users.
