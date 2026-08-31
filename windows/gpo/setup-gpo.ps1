#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Creates and configures the baseline Group Policy infrastructure
    for the Engineering Company IT Lab.

.DESCRIPTION
    Configures:

        Engineering Domain Baseline
        Engineering Workstation Baseline
        Engineering User Baseline

    The script:

        - Creates missing GPOs
        - Creates missing GPO links
        - Configures the domain password/account policy
        - Configures Windows Defender Firewall baseline
        - Configures user restrictions
        - Verifies GPO inventory and inheritance

    Existing GPOs and links are reused where possible.

.NOTES
    Domain:
        engineering.local

    Domain Controller:
        DC01

    This script must be executed on a domain controller or a machine
    with the required Active Directory and Group Policy management
    modules installed.
#>

Import-Module ActiveDirectory
Import-Module GroupPolicy

$Domain = "engineering.local"
$DomainDN = "DC=engineering,DC=local"

$EngineeringOU = "OU=Engineering Company,$DomainDN"
$UsersOU = "OU=Users,$EngineeringOU"
$WorkstationsOU = "OU=Workstations,$EngineeringOU"

$DomainBaselineGPO = "Engineering Domain Baseline"
$WorkstationBaselineGPO = "Engineering Workstation Baseline"
$UserBaselineGPO = "Engineering User Baseline"


# ==============================================================================
# Helper Functions
# ==============================================================================

function Ensure-GPO {
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    $gpo = Get-GPO -Name $Name -Domain $Domain -ErrorAction SilentlyContinue

    if ($null -eq $gpo) {
        Write-Host "Creating GPO: $Name"

        New-GPO `
            -Name $Name `
            -Domain $Domain `
            -Comment "Engineering Company IT Lab baseline policy"
    }
    else {
        Write-Host "GPO already exists: $Name"
    }
}


function Ensure-GPLink {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Target
    )

    $inheritance = Get-GPInheritance `
        -Target $Target `
        -Domain $Domain

    $existingLink = $inheritance.GpoLinks |
        Where-Object {
            $_.DisplayName -eq $Name
        }

    if ($null -eq $existingLink) {

        Write-Host "Creating GPO link: $Name -> $Target"

        New-GPLink `
            -Name $Name `
            -Target $Target `
            -LinkEnabled Yes `
            -Enforced No `
            -Domain $Domain
    }
    else {
        Write-Host "GPO link already exists: $Name -> $Target"
    }
}


# ==============================================================================
# Validate Active Directory Structure
# ==============================================================================

Write-Host ""
Write-Host "Validating Active Directory structure..."
Write-Host ""

Get-ADDomain -Identity $Domain | Out-Null

$requiredOUs = @(
    $EngineeringOU,
    $UsersOU,
    $WorkstationsOU
)

foreach ($ou in $requiredOUs) {

    Get-ADOrganizationalUnit `
        -Identity $ou `
        -ErrorAction Stop | Out-Null

    Write-Host "Verified OU: $ou"
}


# ==============================================================================
# Create Domain Baseline
# ==============================================================================

Write-Host ""
Write-Host "Configuring Domain Baseline..."
Write-Host ""

Ensure-GPO `
    -Name $DomainBaselineGPO

Ensure-GPLink `
    -Name $DomainBaselineGPO `
    -Target $DomainDN


# ==============================================================================
# Configure Domain Password / Account Policy
# ==============================================================================

Write-Host ""
Write-Host "Configuring domain password and account lockout policy..."
Write-Host ""

Set-ADDefaultDomainPasswordPolicy `
    -Identity $Domain `
    -MinPasswordLength 6 `
    -PasswordHistoryCount 5 `
    -ComplexityEnabled $true `
    -MinPasswordAge (New-TimeSpan -Days 0) `
    -MaxPasswordAge (New-TimeSpan -Days 0) `
    -LockoutThreshold 5 `
    -LockoutDuration (New-TimeSpan -Minutes 1) `
    -LockoutObservationWindow (New-TimeSpan -Minutes 1)


# ==============================================================================
# Create Workstation Baseline
# ==============================================================================

Write-Host ""
Write-Host "Configuring Workstation Baseline..."
Write-Host ""

Ensure-GPO `
    -Name $WorkstationBaselineGPO

Ensure-GPLink `
    -Name $WorkstationBaselineGPO `
    -Target $WorkstationsOU


# ==============================================================================
# Configure Windows Defender Firewall
# ==============================================================================

Write-Host ""
Write-Host "Configuring Windows Defender Firewall baseline..."
Write-Host ""

$firewallSettings = @(
    @{
        Key = "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile"
        Name = "EnableFirewall"
        Value = 1
    },
    @{
        Key = "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile"
        Name = "EnableFirewall"
        Value = 1
    },
    @{
        Key = "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile"
        Name = "EnableFirewall"
        Value = 1
    }
)

foreach ($setting in $firewallSettings) {

    Set-GPRegistryValue `
        -Name $WorkstationBaselineGPO `
        -Domain $Domain `
        -Key $setting.Key `
        -ValueName $setting.Name `
        -Type DWord `
        -Value $setting.Value
}


# ==============================================================================
# Create User Baseline
# ==============================================================================

Write-Host ""
Write-Host "Configuring User Baseline..."
Write-Host ""

Ensure-GPO `
    -Name $UserBaselineGPO

Ensure-GPLink `
    -Name $UserBaselineGPO `
    -Target $UsersOU


# ==============================================================================
# Configure User Restrictions
# ==============================================================================

Write-Host ""
Write-Host "Configuring user restrictions..."
Write-Host ""


# ------------------------------------------------------------------------------
# Prohibit access to Control Panel and PC Settings
# ------------------------------------------------------------------------------

Set-GPRegistryValue `
    -Name $UserBaselineGPO `
    -Domain $Domain `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" `
    -Type DWord `
    -Value 1


# ------------------------------------------------------------------------------
# Remove Task Manager
# ------------------------------------------------------------------------------

Set-GPRegistryValue `
    -Name $UserBaselineGPO `
    -Domain $Domain `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "DisableTaskMgr" `
    -Type DWord `
    -Value 1


# ------------------------------------------------------------------------------
# Remove Change Password
# ------------------------------------------------------------------------------

Set-GPRegistryValue `
    -Name $UserBaselineGPO `
    -Domain $Domain `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "DisableChangePassword" `
    -Type DWord `
    -Value 1


# ------------------------------------------------------------------------------
# Remove Logoff
# ------------------------------------------------------------------------------

Set-GPRegistryValue `
    -Name $UserBaselineGPO `
    -Domain $Domain `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoLogoff" `
    -Type DWord `
    -Value 1


# ==============================================================================
# Verify GPO Inventory
# ==============================================================================

Write-Host ""
Write-Host "Verifying GPO inventory..."
Write-Host ""

Get-GPO -All -Domain $Domain |
    Select-Object DisplayName, Id, GpoStatus |
    Format-Table -AutoSize


# ==============================================================================
# Verify Domain GPO Inheritance
# ==============================================================================

Write-Host ""
Write-Host "Verifying domain GPO inheritance..."
Write-Host ""

Get-GPInheritance `
    -Target $DomainDN `
    -Domain $Domain


# ==============================================================================
# Verify Workstation GPO Inheritance
# ==============================================================================

Write-Host ""
Write-Host "Verifying workstation GPO inheritance..."
Write-Host ""

Get-GPInheritance `
    -Target $WorkstationsOU `
    -Domain $Domain


# ==============================================================================
# Verify User GPO Inheritance
# ==============================================================================

Write-Host ""
Write-Host "Verifying user GPO inheritance..."
Write-Host ""

Get-GPInheritance `
    -Target $UsersOU `
    -Domain $Domain


# ==============================================================================
# Verify Effective Domain Password Policy
# ==============================================================================

Write-Host ""
Write-Host "Verifying effective domain password policy..."
Write-Host ""

Get-ADDefaultDomainPasswordPolicy `
    -Identity $Domain |
    Select-Object `
        ComplexityEnabled,
        MinPasswordLength,
        PasswordHistoryCount,
        MinPasswordAge,
        MaxPasswordAge,
        LockoutThreshold,
        LockoutDuration,
        LockoutObservationWindow |
    Format-List


# ==============================================================================
# Generate GPO Reports
# ==============================================================================

$ReportDirectory = "C:\Temp\Engineering-GPO-Reports"

if (-not (Test-Path $ReportDirectory)) {
    New-Item `
        -ItemType Directory `
        -Path $ReportDirectory `
        -Force | Out-Null
}

Write-Host ""
Write-Host "Generating GPO reports..."
Write-Host ""

Get-GPOReport `
    -Name $DomainBaselineGPO `
    -Domain $Domain `
    -ReportType Xml `
    -Path "$ReportDirectory\Engineering-Domain-Baseline.xml"

Get-GPOReport `
    -Name $WorkstationBaselineGPO `
    -Domain $Domain `
    -ReportType Xml `
    -Path "$ReportDirectory\Engineering-Workstation-Baseline.xml"

Get-GPOReport `
    -Name $UserBaselineGPO `
    -Domain $Domain `
    -ReportType Xml `
    -Path "$ReportDirectory\Engineering-User-Baseline.xml"


# ==============================================================================
# Final State
# ==============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "GPO CONFIGURATION COMPLETE"
Write-Host "============================================================"
Write-Host ""

Write-Host "Domain:"
Write-Host "    $Domain"

Write-Host ""
Write-Host "Configured GPOs:"
Write-Host "    $DomainBaselineGPO"
Write-Host "    $WorkstationBaselineGPO"
Write-Host "    $UserBaselineGPO"

Write-Host ""
Write-Host "GPO reports:"
Write-Host "    $ReportDirectory"

Write-Host ""
Write-Host "Domain baseline:"
Write-Host "    Password complexity: Enabled"
Write-Host "    Minimum password length: 6"
Write-Host "    Password history: 5"
Write-Host "    Account lockout threshold: 5"
Write-Host "    Account lockout duration: 1 minute"
Write-Host "    Lockout observation window: 1 minute"

Write-Host ""
Write-Host "Workstation baseline:"
Write-Host "    Windows Defender Firewall: Enabled"
Write-Host "    Domain profile: Enabled"
Write-Host "    Private profile: Enabled"
Write-Host "    Public profile: Enabled"

Write-Host ""
Write-Host "User baseline:"
Write-Host "    Control Panel / PC Settings: Restricted"
Write-Host "    Task Manager: Restricted"
Write-Host "    Change Password: Removed"
Write-Host "    Logoff: Removed"

Write-Host ""
Write-Host "GPO baseline configuration completed."
Write-Host ""
