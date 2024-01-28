Function Invoke-PSModuleTests {
    <#
    .SYNOPSIS
        Invokes Pester tests for a PowerShell module and returns the test results.

    .DESCRIPTION
        This function is used to execute Pester tests for a PowerShell module and retrieve the test results. Pester is a testing framework for PowerShell that allows you to write and run tests to validate the functionality of your PowerShell modules. By using this function, you can easily automate the execution of Pester tests and obtain the test results.

    .NOTES
        - This function requires the Pester module to be installed. You can install it by running 'Install-Module -Name Pester' in PowerShell.
        - Make sure that the module you want to test is imported before invoking this function.

    .LINK
        For more information about Pester, visit: https://github.com/pester/Pester

    .EXAMPLE
        Invoke-PSModuleTests -Source .\src
        Passed
    .EXAMPLE
        Invoke-PSModuleTests -Source .\src
        Failed

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Source
    )

    Write-Verbose "Invoking Pester tests"
    $PesterResults = Invoke-Pester -Path $Source `
        -PassThru -Quiet -WarningAction SilentlyContinue

    return $PesterResults.Result

}