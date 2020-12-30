<#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
[CmdletBinding()]
param (
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    $Source,
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    $Destination,
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]
    $Name,
    # Parameter help description
    [Parameter(Mandatory = $false)]
    [Switch][bool]
    $Force
        
)

#Create TemfileVariable
$TemfileVariable = "$($env:TEMP)\$Name"

#Get Source folder content.
Write-Verbose "SourceFolder `"$Source`""
$ListFiles = $((Get-ChildItem -Path:$Source -Filter:"*.ps1").FullName)

#If Filename doesn't contain correct extension it will be added.
if (-not ($name -like "*.psm1")) {
    $name = "$name.psm1"
}
        

#test if an module with name already exists
if (Test-Path -Path:"$Destination\$Name") {
    if (($Force)) {
        Remove-Item "$Destination\$Name" -Force
    }
    else {
        Write-Verbose "$("$Destination\$Name") Already exists and no force parameter has been used"
        exit
    }
}

#Default parameters for writing to file
$Params = @{
    Path  = "$TemfileVariable"
    Force = $true
}
#Add info about last update and whome pushed it.
Set-Content @Params -Value:"<$([char]0x0023)`nUpdated: $(Get-Date)`nPerformed by: $($env:USERNAME)`n$([char]0x0023)>"
#Add a new line
Add-Content @Params -Value:""

#Test if Source folder is empty.
if (-not ($null -eq $ListFiles)) {
    $ListFiles | ForEach-Object {
        $FunctionName = $((Split-Path -Path:$_ -Leaf).Replace(".ps1", ""))
        Write-Verbose "Store function $FunctionName"
        #Add #Region <Variablename> line
        Add-Content @Params -Value:"$([char]0x0023)region $FunctionName"
        #Start-Sleep -Milliseconds:"100"
        #Add Function to Module
        Add-Content @Params -Value:$(Get-Content -Path:"$_" -Raw)
        #Add #EndRegion <Variablename> line
        Add-Content @Params -Value:"$([char]0x0023)endregion $FunctionName"
        #Add a new line
        Add-Content @Params -Value:""
                
    }
    Write-Verbose "Copying $TemfileVariable to $Destination\$Name"
    if (-not (Test-Path "$Destination")) {
        New-Item -Path:$Destination -ItemType:Directory -Force
    }

    Copy-Item -Path:$TemfileVariable -Destination:"$Destination\$Name" -Force
}
else {
    Write-Verbose "No Functions found to import"
    exit
}



