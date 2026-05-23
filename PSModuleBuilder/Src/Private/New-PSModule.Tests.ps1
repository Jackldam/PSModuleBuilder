BeforeAll {
    # Import the script containing the function to test
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "New-PSModule" {
    Context "When source contains public and private functions" {
        BeforeAll {
            $script:srcPath = Join-Path $TestDrive 'Src'
            New-Item -Path "$script:srcPath\Public" -ItemType Directory -Force | Out-Null
            New-Item -Path "$script:srcPath\Private" -ItemType Directory -Force | Out-Null
            Set-Content -Path "$script:srcPath\Public\Get-Something.ps1" -Value "function Get-Something { 'hello' }"
            Set-Content -Path "$script:srcPath\Private\Invoke-Helper.ps1" -Value "function Invoke-Helper { 'helper' }"
            $script:destPath = Join-Path $TestDrive 'Build'
            New-Item -Path $script:destPath -ItemType Directory -Force | Out-Null
        }

        It "Creates the .psm1 file at the destination" {
            New-PSModule -Author 'TestAuthor' -ModuleName 'TestModule' -Source $script:srcPath -Destination $script:destPath
            Test-Path -Path (Join-Path $script:destPath 'TestModule.psm1') | Should -BeTrue
        }

        It "Returns only public function names" {
            $result = New-PSModule -Author 'TestAuthor' -ModuleName 'TestModule' -Source $script:srcPath -Destination $script:destPath
            $result | Should -Contain 'Get-Something'
            $result | Should -Not -Contain 'Invoke-Helper'
        }

        It "Includes all function code in the generated module file" {
            New-PSModule -Author 'TestAuthor' -ModuleName 'TestModule' -Source $script:srcPath -Destination $script:destPath
            $content = Get-Content -Path (Join-Path $script:destPath 'TestModule.psm1') -Raw
            $content | Should -Match 'Get-Something'
            $content | Should -Match 'Invoke-Helper'
        }
    }

    Context "When source has no .ps1 files" {
        BeforeAll {
            $script:emptySrc = Join-Path $TestDrive 'EmptySrc'
            New-Item -Path $script:emptySrc -ItemType Directory -Force | Out-Null
            $script:emptyDest = Join-Path $TestDrive 'EmptyBuild'
            New-Item -Path $script:emptyDest -ItemType Directory -Force | Out-Null
        }

        It "Throws an error" {
            { New-PSModule -Author 'TestAuthor' -ModuleName 'TestModule' -Source $script:emptySrc -Destination $script:emptyDest } |
                Should -Throw
        }
    }

    Context "When source contains Tests.ps1 and WIP_ files" {
        BeforeAll {
            $script:filteredSrc = Join-Path $TestDrive 'FilteredSrc'
            New-Item -Path "$script:filteredSrc\Public" -ItemType Directory -Force | Out-Null
            Set-Content -Path "$script:filteredSrc\Public\Get-Real.ps1" -Value "function Get-Real { }"
            Set-Content -Path "$script:filteredSrc\Public\Get-Real.Tests.ps1" -Value "Describe 'test' { }"
            Set-Content -Path "$script:filteredSrc\Public\WIP_Get-Draft.ps1" -Value "function WIP_Get-Draft { }"
            $script:filteredDest = Join-Path $TestDrive 'FilteredBuild'
            New-Item -Path $script:filteredDest -ItemType Directory -Force | Out-Null
        }

        It "Excludes Tests.ps1 and WIP_ files from the generated module" {
            $result = New-PSModule -Author 'TestAuthor' -ModuleName 'TestModule' -Source $script:filteredSrc -Destination $script:filteredDest
            $result | Should -Contain 'Get-Real'
            $result | Should -Not -Contain 'Get-Real.Tests'
            $result | Should -Not -Contain 'WIP_Get-Draft'
        }
    }
}
