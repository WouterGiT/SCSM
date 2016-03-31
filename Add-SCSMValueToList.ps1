Function Add-SCSMValueToList {
    <#
    .SYNOPSIS
        Add a new value to a SCSM list
 
    .DESCRIPTION
        Add a new value to an existing list in SCSM
        The value needs to be unique

    .PARAMETER ComputerName
        Specifies the SCSM server, as default localhost is used.

    .PARAMETER AddToList
        The name of the list were to add a new value/entry to. Use a $ at the end to specify the list name.
        If the lists MyListRules and MyListRules2 exist in SCSM the MyList will result in an error.
 
    .PARAMETER DisplayName
        Specifies the value/name of the new list entry.
    
    .PARAMETER AddToManagementPack
        Specifies the name of the management pack were to add value/entry.
        It's advisable to add the entries to a separate management pack so they won't be overwritten on re-import Custom MP.
        
    .EXAMPLE
         Add-SCSMValueToList -ComputerName MyComputer -AddToList Customer$ -DisplayName 'Test 123' -AddToManagementPack 'My List Management Pack'

    .EXAMPLE
         Add-SCSMValueToList -AddToList MyList$ -DisplayName '123 Test' -AddToManagementPack 'Management Pack For My List'

    .INPUTS
        String
 
    .OUTPUTS
        Adds a new value/entry in the specified list
        Status is outputted to screen
 
    .NOTES
        Author:  Wouter de Dood
        Website: 
        Twitter: @WMouter
    #>

    [cmdletbinding()]
    param (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$ComputerName = 'localhost',

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$AddToList,
        
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$DisplayName,
        
        [Parameter(Mandatory=$true)]
        [string]$AddToManagementPack
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
        $ErrorActionPreference = 'Stop'
        Try {
            #Create unique Enum ID for new entry
            $enumId          = ((((Get-SCSMEnumeration -ComputerName $ComputerName -Name $AddToList).id) -replace "-","") + (Get-Date).ToUniversalTime().Ticks)
            $Name            = "enum.$enumId"
            #Get last ordinal and add 1
            $Ordinal         = (Get-SCSMEnumeration -ComputerName $ComputerName -Name $AddToList | Get-SCSMChildEnumeration -ComputerName $ComputerName | Sort-Object Ordinal -Descending | Select-Object Ordinal -First 1).Ordinal+1
            #ManagemantPack were values are added to
            $ManagementPack  = Get-SCSMManagementPack -ComputerName $ComputerName | where { $_.DisplayName -eq $AddToManagementPack }
            #Get Parent Enum
            $Parent          = Get-SCSMEnumeration -ComputerName $ComputerName -Name $AddToList
            $SCSMEnumHash    = @{
                Ordinal        = $Ordinal
                ManagementPack = $ManagementPack
                Name           = $Name
                DisplayName    = $DisplayName
                parent         = $Parent
                ComputerName   = $ComputerName
            }
            Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Action] Add $($SCSMEnumHash.DisplayName) to $AddToList list"
            if (!(Get-SCSMEnumeration -ComputerName $ComputerName -Name $AddToList | Get-SCSMChildEnumeration -ComputerName $ComputerName | where { $_.DisplayName -eq $displayName })) {
                Try {
                    Add-SCSMEnumeration @SCSMEnumHash
                    Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [Status] Added to list"
                }
                Catch {
                    Write-Output "[$(Get-Date -UFormat "%Y-%m-%d %H:%M:%S")] - [ERROR] $($_.Exception.Message)"
                }
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
        Remove-Variable SCSMEnumHash, ComputerName, Parent, DisplayName, Name, ManagementPack, Ordinal, enumId, AddToManagementPack
    }
} #end Function Add-SCSMValueToList