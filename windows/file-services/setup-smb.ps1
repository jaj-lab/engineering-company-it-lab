#Requires -RunAsAdministrator

Import-Module SmbShare

$Domain = "engineering.local"
$CompanyData = "C:\CompanyData"

$Shares = @{
    "Engineering" = @{
        Path = Join-Path $CompanyData "Engineering"
        ModifyGroup = "$Domain\GG-Engineering"
    }

    "IT" = @{
        Path = Join-Path $CompanyData "IT"
        ModifyGroup = "$Domain\GG-IT"
    }

    "Management" = @{
        Path = Join-Path $CompanyData "Management"
        ModifyGroup = "$Domain\GG-Management"
    }
}

$ITGroup = "$Domain\GG-IT"


# ==============================================================================
# 1. Create company data directories
# ==============================================================================

Write-Host "Creating company data directories..."

foreach ($Share in $Shares.GetEnumerator()) {

    $Path = $Share.Value.Path

    if (-not (Test-Path $Path)) {

        New-Item `
            -Path $Path `
            -ItemType Directory `
            -Force | Out-Null

        Write-Host "Created: $Path"
    }
    else {

        Write-Host "Already exists: $Path"
    }
}


# ==============================================================================
# 2. Create SMB shares
# ==============================================================================

Write-Host ""
Write-Host "Creating SMB shares..."

foreach ($Share in $Shares.GetEnumerator()) {

    $ShareName = $Share.Key
    $Path = $Share.Value.Path

    $ExistingShare = Get-SmbShare `
        -Name $ShareName `
        -ErrorAction SilentlyContinue

    if (-not $ExistingShare) {

        New-SmbShare `
            -Name $ShareName `
            -Path $Path `
            -FullAccess "Everyone" | Out-Null

        Write-Host "Created SMB share: \\$env:COMPUTERNAME\$ShareName"
    }
    else {

        Write-Host "SMB share already exists: \\$env:COMPUTERNAME\$ShareName"
    }
}


# ==============================================================================
# 3. Configure SMB share permissions
# ==============================================================================

Write-Host ""
Write-Host "Configuring SMB share permissions..."

foreach ($Share in $Shares.GetEnumerator()) {

    $ShareName = $Share.Key
    $ModifyGroup = $Share.Value.ModifyGroup

    # Remove the default Everyone permission.
    Revoke-SmbShareAccess `
        -Name $ShareName `
        -AccountName "Everyone" `
        -Force `
        -ErrorAction SilentlyContinue | Out-Null

    # IT administrators receive full control over every share.
    Grant-SmbShareAccess `
        -Name $ShareName `
        -AccountName $ITGroup `
        -AccessRight Full `
        -Force | Out-Null

    # The corresponding business group receives Change access.
    Grant-SmbShareAccess `
        -Name $ShareName `
        -AccountName $ModifyGroup `
        -AccessRight Change `
        -Force | Out-Null

    Write-Host "Configured SMB permissions: $ShareName"
}


# ==============================================================================
# 4. Configure NTFS permissions
# ==============================================================================

Write-Host ""
Write-Host "Configuring NTFS permissions..."

foreach ($Share in $Shares.GetEnumerator()) {

    $ShareName = $Share.Key
    $Path = $Share.Value.Path
    $ModifyGroup = $Share.Value.ModifyGroup

    $Acl = Get-Acl $Path

    # Disable inheritance while preserving existing inherited permissions.
    $Acl.SetAccessRuleProtection($true, $true)

    # --------------------------------------------------------------------------
    # IT administrators
    # --------------------------------------------------------------------------

    $ITRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $ITGroup,
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $Acl.SetAccessRule($ITRule)

    # --------------------------------------------------------------------------
    # Business group
    # --------------------------------------------------------------------------

    $ModifyRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $ModifyGroup,
        "Modify",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $Acl.SetAccessRule($ModifyRule)

    Set-Acl `
        -Path $Path `
        -AclObject $Acl

    Write-Host "Configured NTFS permissions: $ShareName"
}


# ==============================================================================
# 5. Verify SMB shares
# ==============================================================================

Write-Host ""
Write-Host "Verifying SMB shares..."

Get-SmbShare |
    Where-Object {
        $_.Name -in $Shares.Keys
    } |
    Select-Object Name, Path


# ==============================================================================
# 6. Verify SMB share permissions
# ==============================================================================

Write-Host ""
Write-Host "Verifying SMB share permissions..."

foreach ($Share in $Shares.GetEnumerator()) {

    Write-Host ""
    Write-Host "Share: $($Share.Key)"

    Get-SmbShareAccess `
        -Name $Share.Key
}


# ==============================================================================
# 7. Verify NTFS permissions
# ==============================================================================

Write-Host ""
Write-Host "Verifying NTFS permissions..."

foreach ($Share in $Shares.GetEnumerator()) {

    Write-Host ""
    Write-Host "Path: $($Share.Value.Path)"

    (Get-Acl $Share.Value.Path).Access |
        Select-Object `
            IdentityReference,
            FileSystemRights,
            AccessControlType,
            IsInherited
}


# ==============================================================================
# 8. Final summary
# ==============================================================================

Write-Host ""
Write-Host "==============================================="
Write-Host "SMB CONFIGURATION COMPLETE"
Write-Host "==============================================="

foreach ($Share in $Shares.GetEnumerator()) {

    Write-Host ""
    Write-Host "$($Share.Key)"
    Write-Host "  UNC: \\$env:COMPUTERNAME\$($Share.Key)"
    Write-Host "  Local: $($Share.Value.Path)"
    Write-Host "  Modify: $($Share.Value.ModifyGroup)"
    Write-Host "  IT: $ITGroup -> Full Control"
}

Write-Host ""
Write-Host "SMB file services are configured."
