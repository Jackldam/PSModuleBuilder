#region Functions
if (Test-Path -Path:".\Functions\PSModuleBuilder\Save-PSModule.ps1") {
    . ".\Functions\PSModuleBuilder\Save-PSModule.ps1"
}

if (Test-Path -Path:".\Functions\PSModuleBuilder\Save-PSModuleManifest.ps1") {
    . ".\Functions\PSModuleBuilder\Save-PSModuleManifest.ps1"
}
if (Test-Path -Path:".\Functions\PSModuleBuilder\Update-Version.ps1") {
    . ".\Functions\PSModuleBuilder\Update-Version.ps1"
}
#endregion Functions

. ".\Functions\PSModuleBuilder\Publish-PSModule.ps1" 
#test
Publish-PSModule `
    -Author "Jack den Ouden" `
    -Company "SysAdminHeaven"`
    -ModuleName "PSModuleBuilder"`
    -BuildCategory:"Build" `
    -Source ".\Functions" `
    -Destination "$PSScriptRoot" -Verbose