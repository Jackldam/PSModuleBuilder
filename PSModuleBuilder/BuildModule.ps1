
$Author = "Jack den Ouden"
$CompanyName = "SysAdmin Heaven"

$Repository = "ReleaseGallery"
$RepositoryPath = "$PSScriptRoot\Release"

if (!(Get-PSRepository -Name $Repository -ErrorAction Continue)) {
    Register-PSRepository -Name $Repository `
        -SourceLocation $RepositoryPath `
        -PublishLocation $RepositoryPath `
        -InstallationPolicy Trusted
}


$PSModuleParams = @{
    Author          = $Author
    CompanyName     = $CompanyName
    ModuleName      = "PSModuleBuilder"
    Copyright       = "© 2020-$(Get-Date -Format "yyyy") $CompanyName. All rights reserved."
    Source          = "$PSScriptRoot\Src"
    BuildFolder     = "$PSScriptRoot\Build"
    ReleaseFolder   = "$PSScriptRoot\Release"
    RequiredModules = @()
    BuildType       = "Major"
}

Build-PSModule @PSModuleParams -Repository $Repository -Verbose