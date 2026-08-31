
# Active Directory Setup Script

#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Configures the Active Directory foundation for the Engineering Company IT Lab.

.DESCRIPTION
    Creates the Engineering Company OU structure, security groups, and
    laboratory user accounts for the engineering.local domain.

    The script is intentionally idempotent:
    existing OUs, groups, and users are detected and reused.

    Passwords are never stored in this script.

.REQUIREMENTS
    - Windows Server with Active Directory Domain Services installed
    - Domain controller for engineering.local
    - ActiveDirectory PowerShell module
    - Administrative privileges

    Expected domain:

        engineering.local

    Expected OU structure:

        engineering.local
        └── Engineering Company
            ├── Users
            ├── Groups
            └── Workstations

    Expected users:

        alice -> GG-Engineering
        john  -> GG-IT
        sarah -> GG-Management
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory


# ==============================================================================
# CONFIGURATION
# ==============================================================================

$DomainName = "engineering.local"
$DomainDN   = "DC=engineering,DC=local"

$CompanyOU = "OU=Engineering Company,$DomainDN"

$UsersOU = "OU=Users,$CompanyOU"
$GroupsOU = "OU=Groups,$CompanyOU"
$WorkstationsOU = "OU=Workstations,$CompanyOU"


# ==============================================================================
# HELPERS
# ==============================================================================

function Ensure-OrganizationalUnit {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $existing = Get-ADOrganizationalUnit `
        -LDAPFilter "(ou=$Name)" `
        -SearchBase $Path `
        -SearchScope OneLevel `
        -ErrorAction SilentlyContinue

    if ($null -eq $existing) {
        Write-Host "Creating OU: $Name"

        New-ADOrganizationalUnit `
            -Name $Name `
            -Path $Path `
            -ProtectedFromAccidentalDeletion $true
    }
    else {
        Write-Host "OU already exists: $Name"
    }
}


function Ensure-SecurityGroup {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $existing = Get-ADGroup `
        -Identity $Name `
        -ErrorAction SilentlyContinue

    if ($null -eq $existing) {
        Write-Host "Creating security group: $Name"

        New-ADGroup `
            -Name $Name `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $Path `
            -Description "Engineering Company IT Lab security group"
    }
    else {
        Write-Host "Security group already exists: $Name"

        if ($existing.GroupScope -ne "Global") {
            throw "Group '$Name' exists but is not Global scope."
        }

        if ($existing.GroupCategory -ne "Security") {
            throw "Group '$Name' exists but is not a Security group."
        }
    }
}


function Ensure-User {
    param (
        [Parameter(Mandatory)]
        [string]$SamAccountName,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $existing = Get-ADUser `
        -Identity $SamAccountName `
        -ErrorAction SilentlyContinue

    if ($null -ne $existing) {
        Write-Host "User already exists: $SamAccountName"

        if ($existing.DistinguishedName -notlike "*$Path") {
            Write-Warning `
                "User '$SamAccountName' exists outside the expected Users OU."
        }

        return
    }

    Write-Host "Creating user: $SamAccountName"

    $password = Read-Host `
        "Enter initial password for $SamAccountName" `
        -AsSecureString

    New-ADUser `
        -Name $Name `
        -SamAccountName $SamAccountName `
        -UserPrincipalName $UserPrincipalName `
        -Path $Path `
        -AccountPassword $password `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -PasswordNeverExpires $false `
        -Description "Engineering Company IT Lab standard domain user"
}


function Ensure-GroupMembership {
    param (
        [Parameter(Mandatory)]
        [string]$User,

        [Parameter(Mandatory)]
        [string]$Group
    )

    $membership = Get-ADGroupMember `
        -Identity $Group `
        -ErrorAction Stop |
        Where-Object { $_.SamAccountName -eq $User }

    if ($null -eq $membership) {
        Write-Host "Adding $User to $Group"

        Add-ADGroupMember `
            -Identity $Group `
            -Members $User
    }
    else {
        Write-Host "$User is already a member of $Group"
    }
}


# ==============================================================================
# VALIDATE DOMAIN
# ==============================================================================

Write-Host ""
Write-Host "==============================================="
Write-Host " Engineering Company AD Setup"
Write-Host "==============================================="
Write-Host ""

$domain = Get-ADDomain

if ($domain.DNSRoot -ne $DomainName) {
    throw "Expected domain '$DomainName', found '$($domain.DNSRoot)'."
}

Write-Host "Domain verified: $DomainName"


# ==============================================================================
# CREATE OU STRUCTURE
# ==============================================================================

Write-Host ""
Write-Host "Creating OU structure..."
Write-Host ""

$domainRoot = $DomainDN

Ensure-OrganizationalUnit `
    -Name "Engineering Company" `
    -Path $domainRoot

Ensure-OrganizationalUnit `
    -Name "Users" `
    -Path $CompanyOU

Ensure-OrganizationalUnit `
    -Name "Groups" `
    -Path $CompanyOU

Ensure-OrganizationalUnit `
    -Name "Workstations" `
    -Path $CompanyOU


# ==============================================================================
# CREATE SECURITY GROUPS
# ==============================================================================

Write-Host ""
Write-Host "Creating security groups..."
Write-Host ""

Ensure-SecurityGroup `
    -Name "GG-Engineering" `
    -Path $GroupsOU

Ensure-SecurityGroup `
    -Name "GG-IT" `
    -Path $GroupsOU

Ensure-SecurityGroup `
    -Name "GG-Management" `
    -Path $GroupsOU


# ==============================================================================
# CREATE USERS
# ==============================================================================

Write-Host ""
Write-Host "Creating users..."
Write-Host ""

Ensure-User `
    -SamAccountName "alice" `
    -Name "Alice" `
    -UserPrincipalName "alice@$DomainName" `
    -Path $UsersOU

Ensure-User `
    -SamAccountName "john" `
    -Name "John" `
    -UserPrincipalName "john@$DomainName" `
    -Path $UsersOU

Ensure-User `
    -SamAccountName "sarah" `
    -Name "Sarah" `
    -UserPrincipalName "sarah@$DomainName" `
    -Path $UsersOU


# ==============================================================================
# CONFIGURE GROUP MEMBERSHIP
# ==============================================================================

Write-Host ""
Write-Host "Configuring group memberships..."
Write-Host ""

Ensure-GroupMembership `
    -User "alice" `
    -Group "GG-Engineering"

Ensure-GroupMembership `
    -User "john" `
    -Group "GG-IT"

Ensure-GroupMembership `
    -User "sarah" `
    -Group "GG-Management"


# ==============================================================================
# VERIFICATION
# ==============================================================================

Write-Host ""
Write-Host "==============================================="
Write-Host " Verification"
Write-Host "==============================================="
Write-Host ""

Write-Host "Organizational Units:"
Get-ADOrganizationalUnit `
    -SearchBase $CompanyOU `
    -SearchScope OneLevel |
    Select-Object Name, DistinguishedName |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Security Groups:"

Get-ADGroup `
    -SearchBase $GroupsOU `
    -SearchScope OneLevel `
    -Filter * |
    Select-Object Name, GroupScope, GroupCategory |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Users:"

Get-ADUser `
    -SearchBase $UsersOU `
    -SearchScope OneLevel `
    -Filter * |
    Select-Object Name, SamAccountName, UserPrincipalName, Enabled |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Group Membership:"

foreach ($group in @(
    "GG-Engineering",
    "GG-IT",
    "GG-Management"
)) {
    Write-Host ""
    Write-Host "$group"

    Get-ADGroupMember `
        -Identity $group |
        Select-Object Name, SamAccountName, ObjectClass |
        Format-Table -AutoSize
}


# ==============================================================================
# COMPLETE
# ==============================================================================

Write-Host ""
Write-Host "==============================================="
Write-Host " AD configuration completed successfully."
Write-Host "==============================================="
Write-Host ""

Write-Host "Domain:"
Write-Host "    $DomainName"

Write-Host ""
Write-Host "OU structure:"
Write-Host "    $CompanyOU"
Write-Host "    ├── Users"
Write-Host "    ├── Groups"
Write-Host "    └── Workstations"

Write-Host ""
Write-Host "Users:"
Write-Host "    alice  -> GG-Engineering"
Write-Host "    john   -> GG-IT"
Write-Host "    sarah  -> GG-Management"

Write-Host ""
Write-Host "No passwords or other credentials were stored by the script."
