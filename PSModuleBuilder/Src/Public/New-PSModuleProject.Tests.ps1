BeforeAll {
    # Import the script containing the function to test
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "New-PSModuleProject" {
    Context "When providing valid module name and path" {
        It "Creates the module project structure" {
            # Arrange
            $moduleName = "MyModule"
            $path = "C:\Projects"

            # Act
            New-PSModuleProject -ModuleName $moduleName -Path $path

            # Assert
            $expectedBuildPath = "${Path}\${ModuleName}\Build"
            $expectedReleasePath = "${Path}\${ModuleName}\Release"
            $expectedPrivateSrcPath = "${Path}\${ModuleName}\Src\Private"
            $expectedPublicSrcPath = "${Path}\${ModuleName}\Src\Public"

            $buildPathExists = Test-Path -Path $expectedBuildPath
            $releasePathExists = Test-Path -Path $expectedReleasePath
            $privateSrcPathExists = Test-Path -Path $expectedPrivateSrcPath
            $publicSrcPathExists = Test-Path -Path $expectedPublicSrcPath

            $buildPathExists | Should -Be $true
            $releasePathExists | Should -Be $true
            $privateSrcPathExists | Should -Be $true
            $publicSrcPathExists | Should -Be $true
        }

    }

    Context "When not providing a path" {
        It "Creates the module project structure in the current directory" {
            # Arrange
            $moduleName = "MyModule"
            $Path = (Get-Location).Path

            # Act
            New-PSModuleProject -ModuleName $moduleName

            # Assert
            $expectedBuildPath = "${Path}\${ModuleName}\Build"
            $expectedReleasePath = "${Path}\${ModuleName}\Release"
            $expectedPrivateSrcPath = "${Path}\${ModuleName}\Src\Private"
            $expectedPublicSrcPath = "${Path}\${ModuleName}\Src\Public"

            $buildPathExists = Test-Path -Path $expectedBuildPath
            $releasePathExists = Test-Path -Path $expectedReleasePath
            $privateSrcPathExists = Test-Path -Path $expectedPrivateSrcPath
            $publicSrcPathExists = Test-Path -Path $expectedPublicSrcPath

            $buildPathExists | Should -Be $true
            $releasePathExists | Should -Be $true
            $privateSrcPathExists | Should -Be $true
            $publicSrcPathExists | Should -Be $true
        }
        
    }

    AfterEach {
        Remove-Item -Path "${Path}\${ModuleName}" -Recurse -Force
    }
}