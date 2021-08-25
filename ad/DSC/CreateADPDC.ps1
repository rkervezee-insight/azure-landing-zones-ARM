configuration CreateADPDC
{
    param
    (

        [Int]$RetryCount = 20,
        [Int]$RetryIntervalSec = 30
    )

    Import-DscResource -ModuleName xActiveDirectory, xStorage, xNetworking, PSDesiredStateConfiguration, xPendingReboot
    $Interface = Get-NetAdapter | Where Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    Node localhost
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature DNS {
            Ensure = "Present"
            Name   = "DNS"
        }

        Script EnableDNSDiags {
            SetScript  = {
                Set-DnsServerDiagnostics -All $true
                Write-Verbose -Verbose "Enabling DNS client diagnostics"
            }
            GetScript  = { @{} }
            TestScript = { $false }
            DependsOn  = "[WindowsFeature]DNS"
        }

        WindowsFeature DnsTools {
            Ensure    = "Present"
            Name      = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn      = "[WindowsFeature]DNS"
        }

        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk ADDataDisk {
            DiskNumber  = 2
            DriveLetter = "F"
            DependsOn   = "[xWaitForDisk]Disk2"
        }

        WindowsFeature ADDSInstall {
            Ensure    = "Present"
            Name      = "AD-Domain-Services"
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature ADDSTools {
            Ensure    = "Present"
            Name      = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter {
            Ensure    = "Present"
            Name      = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSTools"
        }

        xPendingReboot RebootAfterPromotion {
            Name      = "RebootAfterPromotion"
            DependsOn = "[WindowsFeature]ADAdminCenter"
        }

    }
}