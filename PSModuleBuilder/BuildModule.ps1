$PSModuleParams = @{
    Author          = "Jack den Ouden" #Author of the module
    CompanyName     = "SysadminHeaven" #Company name
    ModuleName      = "PSModuleBuilder"
    Copyright       = "© 2020-$(Get-Date -Format "yyyy") SysadminHeaven. All rights reserved."
    Source          = ".\PSModuleBuilder\Src"
    BuildFolder     = ".\PSModuleBuilder\Build"
    ReleaseFolder   = ".\PSModuleBuilder\Release"
    RequiredModules = ("Pester")
    BuildType       = "build"
}

Build-PSModule @PSModuleParams -Verbose 