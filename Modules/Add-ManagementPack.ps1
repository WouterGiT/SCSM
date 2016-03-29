Function Add-ManagementPack {
    <#
    .SYNOPSIS
        Create a new management pack
 
    .DESCRIPTION
        Create a new management pack
 
    .PARAMETER mpName
        The name of the new management pack.

    .PARAMETER computerName
        Specifies the SCSM server.
 
    .EXAMPLE
         Add-ManagementPack -computerName 'Server1' -mpName 'My new Management Pack'

    .INPUTS
        String
 
    .OUTPUTS
        Create a new Management Pack in SCSM
        Status is outputted to screen
 
    .NOTES
        Author:  Wouter de Dood
        Website: 
        Twitter: @WMouter
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$mpName,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$computerName
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Try {
            Import-Module SMLets
        }
        Catch {
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] Module not loaded, SMLets Module is mandatory."
            Throw
        }
    }
    Process {
        Try {
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Action] Create $mpName Management Pack"
            if (!(Get-SCManagementPack -ComputerName $computerName | where {$_.DisplayName -eq $mpName} )) {
                $newManagemenPackHash = @{
                    ComputerName       = $computerName
                    FriendlyName       = $mpName
                    DisplayName        = $mpName
                    ManagementPackName = "managementpack.LC$((Get-Date).ToUniversalTime().Ticks)" #Create unique ID
                }
                New-SCManagementPack @newManagemenPackHash
                Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Status] Created"
            } else {
                Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Status] No need to add already exists"
            }
        }
        Catch {
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] Not created!"
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Error] $($_.Exception.Message)"
        }
    }
    End {
    }
} #end Function Add-ManagementPack