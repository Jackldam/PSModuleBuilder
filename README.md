
# PSModuleBuilder

## Description
`PSModuleBuilder` is a tool designed to streamline the process of creating custom PowerShell modules. It simplifies the module creation process by automating the compilation of individual PowerShell script files (`.ps1`) into a unified module file (`.psm1`). Users simply need to specify the source directory containing their script files and the desired output file path.

## Features
- **Ease of Use**: Automatically compiles multiple script files into a single module.
- **Customization**: Allows for flexible module creation based on user-defined scripts.

## How to Use
To use the `PSModuleBuilder`, follow these steps:
1. Ensure all your individual function scripts (`.ps1`) are stored in a single directory.
2. Run the builder script with the necessary parameters.

### Example command:
```powershell
$PSModuleParams = @{
    Author          = "Jack den Ouden"
    CompanyName     = "SysadminHeaven"
    ModuleName      = "PSModuleBuilder"
    Copyright       = "© 2020-$(Get-Date -Format "yyyy") SysadminHeaven. All rights reserved."
    Source          = ".\PSModuleBuilder\Src" #Location functions and tests
    BuildFolder     = ".\PSModuleBuilder\Build"
    ReleaseFolder   = ".\PSModuleBuilder\Release"
    RequiredModules = ("Pester")
    BuildType       = "build"
}

Build-PSModule @PSModuleParams -Verbose 
```

## Disclaimer
`PSModuleBuilder` is provided "as is," with no warranties, express or implied. The author is not liable for any claims, damages, or other liabilities, whether in a contract, tort, or other forms of action, arising from, out of, or in connection with the module or its use.

## Copyright
© 2020-2024 SysadminHeaven. All rights reserved.

