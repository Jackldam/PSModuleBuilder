BeforeAll {
    # Import the script containing the function to test
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "New-PSModuleProject" {
    Context "When providing valid module name and path" {
        BeforeAll {
            $script:moduleName = "TestModule"
            $script:testPath = $TestDrive
            New-PSModuleProject -ModuleName $script:moduleName -Path $script:testPath
        }

        It "Creates the Build directory" {
            Test-Path -Path (Join-Path $script:testPath "$script:moduleName\Build") | Should -BeTrue
        }

        It "Creates the Release directory" {
            Test-Path -Path (Join-Path $script:testPath "$script:moduleName\Release") | Should -BeTrue
        }

        It "Creates the Src\Private directory" {
            Test-Path -Path (Join-Path $script:testPath "$script:moduleName\Src\Private") | Should -BeTrue
        }

        It "Creates the Src\Public directory" {
            Test-Path -Path (Join-Path $script:testPath "$script:moduleName\Src\Public") | Should -BeTrue
        }
    }

    Context "When not providing a path" {
        BeforeEach {
            $script:moduleName = "DefaultPathModule"
            $script:expectedPath = Join-Path (Get-Location).Path $script:moduleName
        }

        AfterEach {
            if (Test-Path $script:expectedPath) {
                Remove-Item -Path $script:expectedPath -Recurse -Force
            }
        }

        It "Creates the module project structure in the current directory" {
            New-PSModuleProject -ModuleName $script:moduleName

            Test-Path -Path (Join-Path $script:expectedPath 'Build') | Should -BeTrue
            Test-Path -Path (Join-Path $script:expectedPath 'Release') | Should -BeTrue
            Test-Path -Path (Join-Path $script:expectedPath 'Src\Private') | Should -BeTrue
            Test-Path -Path (Join-Path $script:expectedPath 'Src\Public') | Should -BeTrue
        }
    }
}