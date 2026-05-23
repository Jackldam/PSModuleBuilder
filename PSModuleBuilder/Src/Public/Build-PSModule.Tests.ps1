BeforeAll {
    # Load private dependencies
    $srcRoot = Split-Path (Split-Path $PSCommandPath -Parent) -Parent
    . "$srcRoot\Private\New-PSModule.ps1"
    . "$srcRoot\Private\Invoke-PSModuleTests.ps1"
    . (Join-Path (Split-Path $PSCommandPath -Parent) 'Update-Version.ps1')
    # Load function under test
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Build-PSModule" {
    BeforeEach {
        # Set up a minimal source tree
        $script:srcPath = Join-Path $TestDrive "Src_$([guid]::NewGuid().ToString('N'))"
        New-Item -Path "$script:srcPath\Public" -ItemType Directory -Force | Out-Null
        Set-Content -Path "$script:srcPath\Public\Get-Something.ps1" -Value "function Get-Something { }"

        $script:params = @{
            Author        = 'TestAuthor'
            CompanyName   = 'TestCompany'
            Copyright     = '2024 TestCompany'
            ModuleName    = 'TestModule'
            Source        = $script:srcPath
            BuildFolder   = Join-Path $TestDrive "Build_$([guid]::NewGuid().ToString('N'))"
            ReleaseFolder = Join-Path $TestDrive "Release_$([guid]::NewGuid().ToString('N'))"
            BuildType     = 'Build'
        }
        New-Item -Path $script:params.ReleaseFolder -ItemType Directory -Force | Out-Null

        Mock Find-Module { return $null }
        Mock New-ModuleManifest { }
        Mock Invoke-PSModuleTests { return 'Passed' }
    }

    Context "When building a new module with no existing version" {
        It "Creates the versioned build folder" {
            Build-PSModule @script:params
            Test-Path -Path (Join-Path $script:params.BuildFolder 'TestModule\0.0.1') | Should -BeTrue
        }

        It "Creates the module .psm1 file" {
            Build-PSModule @script:params
            Test-Path -Path (Join-Path $script:params.BuildFolder 'TestModule\0.0.1\TestModule.psm1') | Should -BeTrue
        }

        It "Calls New-ModuleManifest once" {
            Build-PSModule @script:params
            Should -Invoke New-ModuleManifest -Times 1
        }

        It "Invokes tests against the source" {
            Build-PSModule @script:params
            Should -Invoke Invoke-PSModuleTests -Times 1 -ParameterFilter { $Source -eq $script:params.Source }
        }
    }

    Context "When tests fail" {
        BeforeEach {
            Mock Invoke-PSModuleTests { return 'Failed' }
        }

        It "Throws an error" {
            { Build-PSModule @script:params } | Should -Throw
        }
    }

    Context "When a repository is provided and the module already exists" {
        BeforeEach {
            Mock Find-Module { return [PSCustomObject]@{ Version = [version]'1.2.3'; Name = 'TestModule' } }
            Mock Uninstall-Module { }
            Mock Install-Module { }
            Mock Get-Module { return [PSCustomObject]@{ Guid = [guid]::NewGuid() } }
            Mock Publish-Module { }
        }

        It "Publishes the module to the repository" {
            Build-PSModule @script:params -Repository 'TestRepo'
            Should -Invoke Publish-Module -Times 1
        }

        It "Increments the version from the existing release" {
            Build-PSModule @script:params -Repository 'TestRepo'
            Test-Path -Path (Join-Path $script:params.BuildFolder 'TestModule\1.2.4') | Should -BeTrue
        }

        It "Removes the module folder from PSModulePath after publishing" {
            $moduleFolder = Join-Path $script:params.BuildFolder 'TestModule'
            Build-PSModule @script:params -Repository 'TestRepo'
            ($env:PSModulePath -split ';') | Should -Not -Contain $moduleFolder
        }
    }

    Context "When a repository is provided but the module does not exist yet" {
        BeforeEach {
            Mock Find-Module { return $null }
            Mock Publish-Module { }
        }

        It "Starts versioning from 0.0.1" {
            Build-PSModule @script:params -Repository 'TestRepo'
            Test-Path -Path (Join-Path $script:params.BuildFolder 'TestModule\0.0.1') | Should -BeTrue
        }
    }

    Context "When the Zip switch is provided" {
        BeforeEach {
            Mock Compress-Archive { }
        }

        It "Compresses the module folder to the release folder" {
            Build-PSModule @script:params -Zip
            Should -Invoke Compress-Archive -Times 1 -ParameterFilter {
                $DestinationPath -like "*TestModule*0.0.1*"
            }
        }
    }
}
