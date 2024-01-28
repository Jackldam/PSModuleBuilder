function Update-Version {
    <#
    .SYNOPSIS
        Updates the version of a file using Semantic Versioning.
    .DESCRIPTION
        A function that updates the version of a file using Semantic Versioning. Given a version number Major.Minor.Build, the function increments the:

            - Major version when making incompatible changes,
            - Minor version when adding functionality in a backwards compatible manner, and
            - Build version when making backwards compatible bug fixes.

        For more information on Semantic Versioning, refer to https://semver.org/.
    .EXAMPLE
        PS C:\> Update-Version -Version 1.1.1 -Buildtype Build
        1.1.2
    .EXAMPLE
        PS C:\> Update-Version -Version 1.1.1 -Buildtype Minor
        1.2.0
    .EXAMPLE
        PS C:\> Update-Version -Version 1.1.1 -Buildtype Major
        2.0.0
    .INPUTS
        -Version [version]: The version number to update.
        -Buildtype [string]: The type of increment to perform. Valid values are 'Build', 'Minor', or 'Major'.
    .OUTPUTS
        [string]: The updated version number.
    .NOTES
        2021-01-29 Jack den Ouden <jack@ldam.nl>
            Script created
        2024-01-27 Jack den Ouden <jack@ldam.nl
            Changed the function to use buildtype with validateSet instead of separate switches.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [version]
        $Version,
        [Parameter(Mandatory = $false)]
        [string]
        [ValidateSet('Build', 'Minor', "Major")]
        $BuildType = "Build"
    )

    switch ($PSBoundParameters.Buildtype) {
        Build { $Version = "{0}.{1}.{2}" -f $($Version.Major), $($Version.Minor), $($Version.Build + 1) }
        Minor { $Version = "{0}.{1}.{2}" -f $($Version.Major), $($Version.Minor + 1), 0 }
        Major { $Version = "{0}.{1}.{2}" -f $($Version.Major + 1), 0, 0 }
    }
    
    return "$Version"
}