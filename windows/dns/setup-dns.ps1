#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Configures and verifies DNS for the Engineering Company IT Lab.

.DESCRIPTION
    Validates the DNS configuration created during Active Directory
    Domain Services deployment.

    The DNS server and the engineering.local Active Directory zone are
    created as part of DC01 domain controller promotion.

    This script therefore does NOT independently create the AD forest.

    Configuration:

        Server:
            DC01
            192.168.100.20

        Domain:
            engineering.local

        DNS:
            Active Directory-integrated DNS

.NOTES
    Intended for the Engineering Company IT Lab.

    Run on DC01 with an elevated PowerShell session.
#>

#Requires -Modules DnsServer

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"


# =============================================================================
# CONFIGURATION
# =============================================================================

$ServerName = "DC01"
$DnsServer = "192.168.100.20"
$DomainName = "engineering.local"

$ExpectedHostName = "dc01"
$ExpectedHostFqdn = "dc01.engineering.local"


# =============================================================================
# HELPER
# =============================================================================

function Assert-Condition {
    param (
        [bool]$Condition,
        [string]$SuccessMessage,
        [string]$FailureMessage
    )

    if ($Condition) {
        Write-Host "[OK] $SuccessMessage"
    }
    else {
        throw "[FAIL] $FailureMessage"
    }
}


# =============================================================================
# DNS SERVER
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DNS SERVER"
Write-Host "============================================================"

$dnsFeature = Get-WindowsFeature -Name DNS

Assert-Condition `
    -Condition $dnsFeature.Installed `
    -SuccessMessage "DNS Server role is installed." `
    -FailureMessage "DNS Server role is not installed."


$dnsService = Get-Service -Name DNS

Assert-Condition `
    -Condition ($dnsService.Status -eq "Running") `
    -SuccessMessage "DNS service is running." `
    -FailureMessage "DNS service is not running."


# =============================================================================
# ACTIVE DIRECTORY DNS ZONE
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "ACTIVE DIRECTORY DNS ZONE"
Write-Host "============================================================"

$zone = Get-DnsServerZone `
    -Name $DomainName `
    -ErrorAction SilentlyContinue

Assert-Condition `
    -Condition ($null -ne $zone) `
    -SuccessMessage "$DomainName zone exists." `
    -FailureMessage "$DomainName zone does not exist."


Assert-Condition `
    -Condition ($zone.IsDsIntegrated -eq $true) `
    -SuccessMessage "$DomainName is Active Directory-integrated." `
    -FailureMessage "$DomainName is not Active Directory-integrated."


# =============================================================================
# DC01 HOST RECORD
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DC01 HOST RECORD"
Write-Host "============================================================"

$hostRecord = Get-DnsServerResourceRecord `
    -ZoneName $DomainName `
    -Name $ExpectedHostName `
    -RRType "A" `
    -ErrorAction SilentlyContinue

Assert-Condition `
    -Condition ($null -ne $hostRecord) `
    -SuccessMessage "$ExpectedHostFqdn A record exists." `
    -FailureMessage "$ExpectedHostFqdn A record does not exist."


$matchingAddress = $hostRecord |
    Where-Object {
        $_.RecordData.IPv4Address.IPAddressToString -eq $DnsServer
    }

Assert-Condition `
    -Condition ($null -ne $matchingAddress) `
    -SuccessMessage "$ExpectedHostFqdn resolves to $DnsServer." `
    -FailureMessage "$ExpectedHostFqdn does not resolve to $DnsServer."


# =============================================================================
# DNS RESOLUTION
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DNS RESOLUTION"
Write-Host "============================================================"

$dcResolution = Resolve-DnsName `
    -Name $ExpectedHostFqdn `
    -Server $DnsServer `
    -ErrorAction Stop

Assert-Condition `
    -Condition ($null -ne $dcResolution) `
    -SuccessMessage "$ExpectedHostFqdn resolves successfully." `
    -FailureMessage "Failed to resolve $ExpectedHostFqdn."


$domainResolution = Resolve-DnsName `
    -Name $DomainName `
    -Server $DnsServer `
    -ErrorAction Stop

Assert-Condition `
    -Condition ($null -ne $domainResolution) `
    -SuccessMessage "$DomainName resolves successfully." `
    -FailureMessage "Failed to resolve $DomainName."


# =============================================================================
# ACTIVE DIRECTORY SRV RECORDS
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "ACTIVE DIRECTORY SERVICE RECORDS"
Write-Host "============================================================"

$ldapSrvName = "_ldap._tcp.dc._msdcs.$DomainName"

$ldapSrv = Resolve-DnsName `
    -Name $ldapSrvName `
    -Type SRV `
    -Server $DnsServer `
    -ErrorAction Stop

Assert-Condition `
    -Condition ($null -ne $ldapSrv) `
    -SuccessMessage "LDAP domain controller SRV record resolves." `
    -FailureMessage "LDAP domain controller SRV record could not be resolved."


# =============================================================================
# DOMAIN CONTROLLER DISCOVERY
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DOMAIN CONTROLLER DISCOVERY"
Write-Host "============================================================"

$dcDiscovery = nltest /dsgetdc:$DomainName 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Domain controller discovery succeeded."
    $dcDiscovery | ForEach-Object {
        Write-Host "    $_"
    }
}
else {
    throw "[FAIL] Domain controller discovery failed."
}


# =============================================================================
# DNS CACHE / REGISTRATION
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DNS REGISTRATION"
Write-Host "============================================================"

Write-Host "Refreshing DNS client registration..."

ipconfig /registerdns | Out-Null

Write-Host "[OK] DNS registration refresh requested."


# =============================================================================
# VERIFICATION SUMMARY
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DNS CONFIGURATION SUMMARY"
Write-Host "============================================================"

Write-Host ""
Write-Host "Server:"
Write-Host "    $ServerName"

Write-Host ""
Write-Host "DNS server:"
Write-Host "    $DnsServer"

Write-Host ""
Write-Host "Active Directory DNS zone:"
Write-Host "    $DomainName"

Write-Host ""
Write-Host "DC01 FQDN:"
Write-Host "    $ExpectedHostFqdn"

Write-Host ""
Write-Host "DNS role:"
Write-Host "    Installed"

Write-Host ""
Write-Host "DNS service:"
Write-Host "    Running"

Write-Host ""
Write-Host "AD-integrated zone:"
Write-Host "    Verified"

Write-Host ""
Write-Host "DC01 host record:"
Write-Host "    Verified"

Write-Host ""
Write-Host "AD SRV records:"
Write-Host "    Verified"

Write-Host ""
Write-Host "Domain controller discovery:"
Write-Host "    Verified"


# =============================================================================
# COMPLETION
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DNS CONFIGURATION VERIFIED"
Write-Host "============================================================"

Write-Host ""
Write-Host "DNS is correctly integrated with the Active Directory"
Write-Host "environment."
