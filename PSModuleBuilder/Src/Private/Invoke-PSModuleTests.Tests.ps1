BeforeAll {
    # Import the script containing the function to test
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Invoke-PSModuleTests" {
    Context "When all tests pass" {
        BeforeAll {
            Mock Invoke-Pester { return [PSCustomObject]@{ Result = 'Passed' } }
        }

        It "Returns 'Passed'" {
            $result = Invoke-PSModuleTests -Source 'TestDrive:\FakeSrc'
            $result | Should -Be 'Passed'
        }

        It "Calls Invoke-Pester with the provided source path" {
            Invoke-PSModuleTests -Source 'TestDrive:\FakeSrc'
            Should -Invoke Invoke-Pester -Times 1 -ParameterFilter { $Path -eq 'TestDrive:\FakeSrc' }
        }
    }

    Context "When tests fail" {
        BeforeAll {
            Mock Invoke-Pester { return [PSCustomObject]@{ Result = 'Failed' } }
        }

        It "Returns 'Failed'" {
            $result = Invoke-PSModuleTests -Source 'TestDrive:\FakeSrc'
            $result | Should -Be 'Failed'
        }
    }
}
