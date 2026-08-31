#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Configures the Engineering Company IT Lab DHCP server.

.DESCRIPTION
    Installs and configures the Windows DHCP Server role on DC01.

    Configuration:

        Server:
            DC01
            192.168.100.20

        Scope:
            Engineering Lab
            192.168.100.0/24

        Dynamic range:
            192.168.100.50 - 192.168.100.100

        DHCP options:
            Router:       192.168.100.1
            DNS Server:   192.168.100.20
            DNS Domain:   engineering.local

        Reservation:
            WIN01
            52-54-00-CD-78-97
            192.168.100.30

.NOTES
    Intended for the Engineering Company IT Lab.

    Run on DC01 with an elevated PowerShell session.

    Review the values before executing against a different environment.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"


# =============================================================================
# CONFIGURATION
# =============================================================================

$ServerName = "DC01"

$ScopeId = "192.168.100.0"
$ScopeName = "Engineering Lab"

$SubnetMask = "255.255.255.0"

$StartRange = "192.168.100.50"
$EndRange = "192.168.100.100"

$Gateway = "192.168.100.1"
$DnsServer = "192.168.100.20"
$DnsDomain = "engineering.local"

$ReservationName = "WIN01"
$ReservationIp = "192.168.100.30"
$ReservationMac = "52-54-00-CD-78-97"


# =============================================================================
# DHCP SERVER ROLE
# =============================================================================

Write-Host "Checking DHCP Server role..."

$dhcpFeature = Get-WindowsFeature -Name DHCP

if (-not $dhcpFeature.Installed) {

    Write-Host "Installing DHCP Server role..."

    Install-WindowsFeature `
        -Name DHCP `
        -IncludeManagementTools

    Write-Host "DHCP Server role installed."
}
else {
    Write-Host "DHCP Server role is already installed."
}


# =============================================================================
# DHCP SERVER AUTHORIZATION
# =============================================================================

Write-Host "Checking DHCP authorization..."

$authorizedServers = Get-DhcpServerInDC

$alreadyAuthorized = $authorizedServers |
    Where-Object {
        $_.DnsName -eq "$ServerName.$DnsDomain" -or
        $_.IPAddress -eq $DnsServer
    }

if (-not $alreadyAuthorized) {

    Write-Host "Authorizing DHCP server in Active Directory..."

    Add-DhcpServerInDC `
        -DnsName "$ServerName.$DnsDomain" `
        -IPAddress $DnsServer

    Write-Host "DHCP server authorized."
}
else {
    Write-Host "DHCP server is already authorized."
}


# =============================================================================
# DHCP SCOPE
# =============================================================================

Write-Host "Checking DHCP scope..."

$scope = Get-DhcpServerv4Scope |
    Where-Object {
        $_.ScopeId -eq [IPAddress]$ScopeId
    }

if (-not $scope) {

    Write-Host "Creating DHCP scope..."

    Add-DhcpServerv4Scope `
        -Name $ScopeName `
        -StartRange $StartRange `
        -EndRange $EndRange `
        -SubnetMask $SubnetMask `
        -State Active

    Write-Host "DHCP scope created."
}
else {
    Write-Host "DHCP scope already exists."
}


# =============================================================================
# DHCP SCOPE OPTIONS
# =============================================================================

Write-Host "Configuring DHCP scope options..."

Set-DhcpServerv4OptionValue `
    -ScopeId $ScopeId `
    -Router $Gateway `
    -DnsServer $DnsServer `
    -DnsDomain $DnsDomain

Write-Host "DHCP scope options configured."


# =============================================================================
# WIN01 RESERVATION
# =============================================================================

Write-Host "Checking WIN01 DHCP reservation..."

$reservation = Get-DhcpServerv4Reservation `
    -ScopeId $ScopeId `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IPAddress -eq [IPAddress]$ReservationIp
    }

if (-not $reservation) {

    Write-Host "Creating WIN01 DHCP reservation..."

    Add-DhcpServerv4Reservation `
        -ScopeId $ScopeId `
        -IPAddress $ReservationIp `
        -ClientId $ReservationMac `
        -Name $ReservationName `
        -Description "Engineering Company employee workstation"

    Write-Host "WIN01 reservation created."
}
else {

    Write-Host "WIN01 reservation already exists."

    if ($reservation.ClientId -ne $ReservationMac) {

        Write-Warning `
            "Reservation $ReservationIp already exists with a different MAC address."
    }
}


# =============================================================================
# VERIFICATION
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DHCP CONFIGURATION VERIFICATION"
Write-Host "============================================================"

Write-Host ""
Write-Host "DHCP scopes:"
Get-DhcpServerv4Scope |
    Format-Table ScopeId, Name, StartRange, EndRange, State

Write-Host ""
Write-Host "DHCP scope options:"
Get-DhcpServerv4OptionValue `
    -ScopeId $ScopeId |
    Format-Table OptionId, Name, Value

Write-Host ""
Write-Host "DHCP reservations:"
Get-DhcpServerv4Reservation `
    -ScopeId $ScopeId |
    Format-Table IPAddress, ClientId, Name, Description

Write-Host ""
Write-Host "Current leases:"
Get-DhcpServerv4Lease `
    -ScopeId $ScopeId |
    Format-Table IPAddress, HostName, ClientId, AddressState


# =============================================================================
# COMPLETION
# =============================================================================

Write-Host ""
Write-Host "============================================================"
Write-Host "DHCP CONFIGURATION COMPLETE"
Write-Host "============================================================"

Write-Host ""
Write-Host "Server:"
Write-Host "    $ServerName"

Write-Host ""
Write-Host "Scope:"
Write-Host "    $ScopeName"
Write-Host "    $ScopeId/24"

Write-Host ""
Write-Host "Dynamic range:"
Write-Host "    $StartRange - $EndRange"

Write-Host ""
Write-Host "Gateway:"
Write-Host "    $Gateway"

Write-Host ""
Write-Host "DNS:"
Write-Host "    $DnsServer"

Write-Host ""
Write-Host "DNS domain:"
Write-Host "    $DnsDomain"

Write-Host ""
Write-Host "WIN01 reservation:"
Write-Host "    $ReservationIp"
Write-Host "    $ReservationMac"

Write-Host ""
Write-Host "DHCP configuration completed successfully."
