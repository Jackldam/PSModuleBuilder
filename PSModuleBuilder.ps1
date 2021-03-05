function Update-Module {
    <#
    .SYNOPSIS
        This will allow you to quickly create your own custom Powershell Module's
    .DESCRIPTION
        Given a version number Major.Minor.Build, increment the:

        Major version when you make incompatible changes,
        Minor version when you add functionality in a backwards compatible manner, and
        Build version when you make backwards compatible bug fixes.
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
        $Functions,
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $Destination,
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,
        # Parameter help description
        [Parameter()]
        [ValidateSet('None', 'Build', 'Minor', "Major")]
        [string]
        $Increment
    )

    try { Set-ExecutionPolicy -ExecutionPolicy:"Bypass" -Scope:"Process" }catch {}

    #Functions used By PSModulebuilder.
    function Update-FileVersion {
        <#
        .SYNOPSIS
            A FileVersion update function that will allow you to quickly update a file using Semantic Versioning.
        .DESCRIPTION
            A FileVersion update function that will allow you to quickly update a file using Semantic Versioning.
    
            Given a version number Major.Minor.Build, increment the:
    
                Major version when you make incompatible changes,
                Minor version when you add functionality in a backwards compatible manner, and
                Build version when you make backwards compatible bug fixes.
    
            Source https://semver.org/
        .EXAMPLE
            PS C:\> Update-FileVersion -FileName:"TestVersion.1.1.1.ps1" -Build
            TestVersion.1.1.2.ps1
        .EXAMPLE
            PS C:\> Update-FileVersion -FileName:"TestVersion.1.1.1.ps1" -Minor
            TestVersion.1.2.0.ps1
        .EXAMPLE
            PS C:\> Update-FileVersion -FileName:"TestVersion.1.1.1.ps1" -Major
            TestVersion.2.0.0.ps1
        .INPUTS
            FileName: string
            IncrementalType: Major', 'Minor', "Build"
        .OUTPUTS
            String
        .NOTES
            2021-01-29 Jack den Ouden Function Created
        #>
        param (
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $FileName,
            [Parameter(ParameterSetName = 'Build', Mandatory = $true)]
            [Switch]
            $Build,
            [Parameter(ParameterSetName = 'Minor', Mandatory = $true)]
            [Switch]
            $Minor,
            [Parameter(ParameterSetName = 'Major', Mandatory = $true)]
            [Switch]
            $Major
        )
    
        #Using regex to split the name in to 3 groups
        #Fist group everyting prior to
        #Number('s) dot Number('s) dot Number('s)
        $PreVersion = $([regex]::Match($FileName, '(.*\D)(\d+\.\d+\.\d+)(.*)').Groups[1].value)
        #Second group version number can be
        #Number('s) dot Number('s) dot Number('s)
        [version]$Version = $([regex]::Match($FileName, '(.*\D)(\d+\.\d+\.\d+)(.*)').Groups[2].value)
        #Third group anything after
        ##Number('s) dot Number('s) dot Number('s)
        $PostVersion = $([regex]::Match($FileName, '(.*\D)(\d+\.\d+\.\d+)(.*)').Groups[3].value)
        
        switch ($PSCmdlet.ParameterSetName) {
            Build { $Version = "{0}.{1}.{2}" -f $($Version.Major), $($Version.Minor), $($Version.Build + 1) }
            Minor { $Version = "{0}.{1}.{2}" -f $($Version.Major), $($Version.Minor + 1), 0 }
            Major { $Version = "{0}.{1}.{2}" -f $($Version.Major + 1), 0, 0 }
        }
        
        return "$PreVersion" + "$Version" + "$PostVersion"
    }
    
    Function Get-MostRecentFile {
        <#
        .SYNOPSIS
            Get-MostRecentFile allow's you to get the most recent file in a folder.
        .DESCRIPTION
            Get-MostRecentFile allow's you to get the most recent file in a folder.
            When you have multiple files with similar names you can also filter on a part of the name to make sure you get the correct file
        .EXAMPLE
            PS C:\> Get-MostRecentFile -Path "C:\Test" -Filter ""
            Explanation of what the example does
        .INPUTS
            Inputs (if any)
        .OUTPUTS
            Output (if any)
        .NOTES
            2021-01-21 Jack den Ouden Created Function
        #>
        [CmdletBinding()]
        param (
            [Parameter()]
            [String]
            $Path,
            [Parameter()]
            [String]
            $Filter
        )
    
        $Params = @{
            Path   = $Path
            Filter = $Filter
        }
        
        (Get-ChildItem @Params | Sort-Object LastWriteTime)[-1]
    }

    #test if an module with Name already exists
    try {
        $ModuleTest = Get-MostRecentFile -Path:$Destination -Filter:"$ModuleName*" -ErrorAction:Stop
    }
    catch {
        Write-Warning "No File Found $ModuleName"
    }

    if ($Null -eq $ModuleTest) {
        Write-Verbose "File not found: $DestinationFullName"
        #If FileName doesn't contain correct extension it will be added.
        if (-not ($ModuleName -like "*1.0.0.psm1")) {
            $ModuleName = "$ModuleName.1.0.0.psm1"
        }
    }
    else {
        #If Increment is set to Build,Minor or Major then update file version accordingly if not keep current Name.
        switch ($Increment) {
            None { $ModuleName = $ModuleTest }
            Build { $ModuleName = $(Update-FileVersion -FileName:$($ModuleTest) -Build) }
            Minor { $ModuleName = $(Update-FileVersion -FileName:$($ModuleTest) -Minor) }
            Major { $ModuleName = $(Update-FileVersion -FileName:$($ModuleTest) -Major) }
        }

    }

    #Tempory File in Temp location needs to be removed when finisched.
    $TempFile = "$($env:TEMP)\$ModuleName"
    
    #Create Variable for Full Destination Path
    $DestinationFullName = "$Destination\$ModuleName"
        
    #Get Source folder content.
    $ListFiles = $((Get-ChildItem -Path:"$Functions" -Recurse -Filter:"*.ps1").FullName)

    #Default parameters for writing to file
    $Params = @{
        FilePath = "$TempFile"
        #Encoding = "utf8"
        #Force    = $true
    }
    #Add info about last update and whome pushed it.
    Out-File @Params -InputObject:"<$([char]0x0023)`nUpdated: $(Get-Date)`nPerformed by: $($env:USERName)`n$([char]0x0023)>"

    #Add a new line
    Out-File @Params -Append -InputObject:""

    #Test if Source folder is empty.
    if (-not ($null -eq $ListFiles)) {
        $ListFiles | ForEach-Object {
            $FunctionName = $((Split-Path -Path:$_ -Leaf).Replace(".ps1", ""))
            Write-Verbose "Store function $FunctionName"
            #Add #Region <VariableName> line
            Out-File @Params -Append -InputObject:"$([char]0x0023)region $FunctionName"
            #Add Function to Module
            Out-File @Params -Append -InputObject:$(Get-Content -Path:"$_" -Raw)
            #Add #EndRegion <VariableName> line
            Out-File @Params -Append -InputObject:"$([char]0x0023)endregion $FunctionName"
            #Add a new line
            Out-File @Params -Append -InputObject:""
                
        }
                
        Write-Verbose "Copying $TempFile to $DestinationFullName"
                
        #If Destination folder isn't present create it.
        if (-not (Test-Path "$Destination")) {
            #Folder creation
            New-Item -Path:$Destination -ItemType:Directory -Force
        }


        #Get-ChildItem -Path:"$DestinationFullName"

        #Copy Local TempFile to destination.
        Copy-Item -Path:$TempFile -Destination:"$DestinationFullName" -Force

        #Remove LocalTempFile
        Remove-Item -Path:$TempFile -Force
    }


            

    else {
        Write-Verbose "No Functions found to import"
    }    
        

}

#Splated overview to perform 
$Params = @{
    #Specify the location or your Functions
    Functions   = "Location"
    #Specify the location where to put the Module
    Destination = "Destination"
    #Actual Module name
    ModuleName  = "ModuleName"
    #Select if build "None,Major,Minor & Build"
    Increment   = None
}

Update-Module @Params
