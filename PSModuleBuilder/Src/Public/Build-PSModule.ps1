function Build-PSModule {
    <#
    .SYNOPSIS
        Builds a PowerShell module using the PSModuleBuilder tool.
    .DESCRIPTION
        The Build-PSModule function is used to create a PowerShell module using the PSModuleBuilder tool.
        This function automates the process of generating a module structure, including the necessary files and folders, based on a predefined template.
        It provides a convenient way to scaffold a new module and get started quickly with module development.
    .NOTES
        - This function requires the PSModuleBuilder tool to be installed on the system.
        - PSModuleBuilder is a community-supported tool and is not officially supported by Microsoft.
    .LINK
        For more information about PSModuleBuilder, visit the official GitHub repository:
        https://github.com/jackldam/PSModuleBuilder
    .EXAMPLE
        $PSModuleParams = @{
            Author          = "Jack den Ouden"
            CompanyName     = "SysadminHeaven"
            ModuleName      = "PSModuleBuilder"
            Copyright       = "© 2020-$(Get-Date -Format "yyyy") SysadminHeaven. All rights reserved."
            Source          = ".\PSModuleBuilder\Src"
            BuildFolder     = ".\PSModuleBuilder\Build"
            ReleaseFolder   = ".\PSModuleBuilder\Release"
            RequiredModules = ("Pester")
            BuildType       = "build"
        }

        Build-PSModule @PSModuleParams -Verbose 
    #>
    
    [CmdletBinding()]
    param (
        # Author of the Module
        [Parameter(Mandatory)]
        [string]
        $Author,
        # Company name
        [Parameter(Mandatory)]
        [string]
        $CompanyName,
        # Copyright
        [Parameter(Mandatory)]
        [string]
        $Copyright,
        # #Name of the module
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,
        # Required modules
        [Parameter()]
        [array]
        $RequiredModules,
        # This parameter needs to point to the path that contains all the function files.
        # Tests.ps1 & WIP_* files will be ignored.
        [Parameter(Mandatory = $true)]
        [string]
        $Source,
        # Path to the build folder
        [Parameter(Mandatory)]
        [string]
        $BuildFolder,
        # Path to the release folder
        [Parameter(Mandatory)]
        [string]
        $ReleaseFolder,
        #BuildType
        [Parameter()]
        [ValidateSet('Build', 'Minor', 'Major')]
        [string]
        $BuildType = 'Build'
    )

    begin {
        #* Begin block
        #region
        Write-Verbose "Begin block"

        #endregion
    }

    process {
        #* Process block
        #region
        Write-Verbose "Process block"

        #* Check if any version of the module already exists
        #region

        Write-Verbose "Checking if module $($ModuleName) already exists"
        $LastRelease = Get-ChildItem -Path $ReleaseFolder -ErrorAction SilentlyContinue | 
        Sort-Object -Descending | 
        Select-Object -First 1
        
        if ($LastRelease) {
            Expand-Archive -Path $LastRelease.FullName `
                -DestinationPath "$BuildFolder" `
                -Force
        }
        else {
            Write-Verbose "No previous release found"
        }

        $ModuleTest = Get-Module -ListAvailable -Name $buildfolder\$ModuleName -ErrorAction SilentlyContinue | Sort-Object Version -Descending | Select-Object -First 1 

        if ($ModuleTest) {
            Write-Verbose "Module $($ModuleName) already exists"
            $Version = $ModuleTest | Select-Object -ExpandProperty Version
            Write-Verbose "Version: $($Version)"
            $Version = Update-Version -Version $Version -Buildtype $BuildType
            Write-Verbose "New version: $($Version)"
            $ModuleGuid = $ModuleTest.Guid
            Write-Verbose "ModuleGuid: $($ModuleGuid)"
        }
        else {
            Write-Verbose "Module $($ModuleName) does not exist"
            $Version = [version]"0.0.0"
            Write-Verbose "Version: $($Version)"
            $Version = Update-Version -Version $Version -Buildtype $BuildType
            Write-Verbose "New version: $($Version)"
            $ModuleGuid = New-Guid
            Write-Verbose "ModuleGuid: $($ModuleGuid)"
        }
        #endregion

        #* Clean up build folder
        #region

        Write-Verbose "Cleaning up build folder `"$BuildFolder\$ModuleName`""
        If (Test-Path -Path "$BuildFolder\$ModuleName") {
            Remove-Item -Path "$BuildFolder\$ModuleName" -Recurse -Force
        }
        else {
            Write-Verbose "Build folder `"$BuildFolder\$ModuleName`" does not exist"
        }
        #endregion

        #* Make sure the build folder exists and if version folder exists delete it and create a new one.
        #region

        $BuildFolder = "$BuildFolder\$ModuleName\$Version"
        if (-not (Test-Path -Path $BuildFolder)) {
            Write-Verbose "Build folder `"$BuildFolder`" does not exist"
            Write-Verbose "Creating build folder `"$BuildFolder`""
            New-Item -Path $BuildFolder -ItemType Directory -Force | Out-Null
        }
        else {
            Write-Verbose "Build folder `"$BuildFolder`" already exists"
            Remove-Item -Path $BuildFolder -Recurse -Force
            Write-Verbose "Creating build folder `"$BuildFolder`""
            New-Item -Path $BuildFolder -ItemType Directory -Force | Out-Null

        }

        #endregion

        #* Perform Tests of the functions
        #region

        Write-Verbose "Performing tests of the functions"
        $TestResult = Invoke-Pester -Path "$Source" -PassThru -Quiet
        
        if ($TestResult.result -eq "Failed") {
            Write-Verbose "Tests failed"
            throw "Tests failed"
        }
        else {
            Write-Verbose "Tests passed"
        }

        #endregion

        #* Get Source folder content.
        #region

        $ListFiles = Get-ChildItem -Path:"$Source" -Recurse -Filter:"*.ps1" | 
        Where-Object { ($_.Name -NotLike "*Tests.ps1") -and ($_.Name -NotLike "WIP_*") } | Sort-Object

        If ($ListFiles) {
            Write-Verbose "Found $($ListFiles.Count) functions to add"
        }
        else {
            Write-Verbose "No functions to add found in $Source"
            throw "No functions to add found in $Source"
        }

        #endregion
        
        #* Create module file and define functions to export
        #region

        Write-Verbose "Creating module file"
        $FunctionsToExport = New-PSModule -Author $Author `
            -ModuleName $ModuleName `
            -Source $Source `
            -Destination $BuildFolder

        #endregion

        #* create module manifest
        #region

        Write-Verbose "Creating module manifest"
        $ModuleManifest = @{
            Guid              = $ModuleGuid
            
            Author            = $Author
            CompanyName       = $CompanyName
            Copyright         = $Copyright
            
            RootModule        = "$ModuleName.psm1"
            ModuleVersion     = $Version.ToString()
            Description       = "Modulefile for module '$ModuleName'"
            Path              = "$BuildFolder\$ModuleName.psd1"
            RequiredModules   = $RequiredModules
            FunctionsToExport = $FunctionsToExport

            AliasesToExport   = @($null)
            CmdletsToExport   = @($null)
            VariablesToExport = @($null)

            PrivateData       = ${PrivateData}
            
        } 
        
        New-ModuleManifest @ModuleManifest

        #endregion

        #* Zip module and export to release folder
        #region

        Write-Verbose "Zipping module and export to release folder"
        $Zipfilename = "$ReleaseFolder\$ModuleName-$Version.zip"
        Compress-Archive -Path $(Split-Path $BuildFolder -Parent) -DestinationPath $Zipfilename -Force

        #endregion
    }

    end {
        #* End block
        #region
        Write-Verbose "End block"
        #endregion
    }
}

