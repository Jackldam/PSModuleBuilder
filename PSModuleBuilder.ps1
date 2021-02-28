<#
    .SYNOPSIS
        This will allow you to quickly create your own custom Powershell Module's
    .DESCRIPTION
        This will allow you to quickly create your own custom Powershell Module's
        Just select a Source Path were you saved all your functions in separate .ps1 files
        and select an output filePath.

        And this script will do the rest.
    .EXAMPLE
        PS C:\> & ".\PSModuleBuilder.ps1" -SourcePath ".\Functions" -FilePath ".\Test.psm1" -ModifiedBy "Jack den Ouden"
        PS C:\>
    .INPUTS
        Source Path where all *.ps1 files are located
    .OUTPUTS
        a *.psm1 File specified at the location
    .NOTES
        2021-02-28 Jack den Ouden Created and updated this Script.
    #>
[CmdletBinding()]
param (
    # Parameter help description
    [Parameter(Position = 0, Mandatory = $true)]
    [string]
    $SourcePath,
    # Parameter help description
    [Parameter(Position = 1, Mandatory = $true)]
    [string]
    $FilePath,
    # Parameter help description
    [Parameter(Position = 2, Mandatory = $false)]
    [string]
    $ModifiedBy = $env:USERNAME
)

#Region PreChecks

#Perform first tests to see if script can actually work.
#Test if SourcePath exists if not throw error
$TestPath = Test-Path -Path:$(Split-Path $SourcePath)
if (!$TestPath) {
    Throw "Source path not found `"$($SourcePath)`""
}

#Test if Path exists if not throw error
$TestPath = Test-Path -Path:$(Split-Path $FilePath -Parent)
if (!$TestPath) {
    Throw "Destination Path not found `"$(Split-Path $FilePath -Parent)`""
}
    
#endregion

#We want to store a temp file on a local location prior to writing the complete module to the destination.
#This will ensure a complete file.

#Create TemfileVariable
$TemfileVariable = "$($env:TEMP)\$((New-Guid).Guid)"

#Get Source folder content.
Write-Verbose "SourceFolder `"$Source`""
$ListFiles = $((Get-ChildItem -Path:$SourcePath -Filter:"*.ps1").FullName)

#If Filename doesn't contain correct extension it will be added.
if (-not ($name -like "*.psm1")) {
    $name = "$name.psm1"
}



#Default parameters for writing to file
$Params = @{
    FilePath = "$TemfileVariable"
    Encoding = "utf8"
}

#Add info about last update and who modified it.
Out-File @Params -InputObject:"<$([char]0x0023)`nUpdated: $(Get-Date)`nModified by: $($ModifiedBy)`n$([char]0x0023)>"

#Add Append Parameter to the Params so we won't overwrite the file but just add data.
$Params.Add("Append", $true)

#Add a new line
Out-File @Params -InputObject:""

#Test if Source folder is empty.
if (-not ($null -eq $ListFiles)) {
    $ListFiles | ForEach-Object {
        $FunctionName = $((Split-Path -Path:$_ -Leaf).Replace(".ps1", ""))
        Write-Verbose "Store function $FunctionName"
        
        #Add #Region <Variablename> line
        Out-File @Params -InputObject:"$([char]0x0023)region $FunctionName"
                
        #Add Function to Module
        Out-File @Params -InputObject:$(Get-Content -Path:"$_" -Raw)
        
        #Add #EndRegion <Variablename> line
        Out-File @Params -InputObject:"$([char]0x0023)endregion $FunctionName"
        
        #Add a new line
        Out-File @Params -InputObject:""
                
    }

    #Copy the temporaryfile to the Destination.
    Copy-Item -Path:$TemfileVariable -Destination:$FilePath

    #Remove the temporaryfile to keep everything nice and tidy.
    Remove-Item -Path:"$TemfileVariable"
}
else {
    Write-Verbose "No Functions found to import"
    exit
}
