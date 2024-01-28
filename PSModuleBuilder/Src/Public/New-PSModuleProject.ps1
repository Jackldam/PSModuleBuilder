function New-PSModuleProject {
    <#
    .SYNOPSIS
        Creates the folder structure required for a PowerShell module project using PSModuleBuilder.
    .DESCRIPTION
        The New-PSModuleProject function creates the necessary folder structure for a PowerShell module project using PSModuleBuilder.
        It sets up the standard directories such as Build, Release, Src\Private, and Src\Public. This function is designed to streamline the module development process by providing a consistent project structure.
    .NOTES
        - This function requires the PSModuleBuilder module to be installed.
        - PSModuleBuilder is a community-supported module that helps automate the creation of PowerShell module projects.
        - For more information about PSModuleBuilder, visit https://github.com/jackldam/PSModuleBuilder.
    .LINK
        https://github.com/jackldam/PSModuleBuilder
    .EXAMPLE
        New-PSModuleProject -ModuleName MyModule -Path "C:\Projects"
        Creates a new PowerShell module project named MyModule in the C:\Projects directory.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ModuleName,
        [Parameter()]
        [string]
        $Path = (Get-Location).Path
    )

    begin {
        #* Begin block
        #region
        Write-Verbose "Starting New-PSModuleProject"
        $Path = Join-Path -Path $Path -ChildPath $ModuleName
        #endregion
        
    }

    process {
        #* Process block
        #region
        Write-Verbose "Processing New-PSModuleProject"

        @(
            , "$Path\Build"
            , "$Path\Release"
            , "$Path\Src\Private"
            , "$Path\Src\Public"
        ) | ForEach-Object {
            Write-Verbose "Creating folder $_"
            New-Item -Path $_ -ItemType Directory -Force | Out-Null
        }
        #endregion
    }

    end {
        #* End block
        #region
        Write-Verbose "Ending New-PSModuleProject"
        #endregion
    }
}
