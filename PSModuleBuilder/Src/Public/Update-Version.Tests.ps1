BeforeAll {
    # Import the script containing the function to test
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Update-Version" {
    context "When the Buildtype is 'Build'" {
        It "Increments the build number" {
            $version = [version]"1.2.3"
            $result = Update-Version -Version $version -Buildtype 'Build'
            $result | Should -Be "1.2.4"
        }
    }

    Context "When the Buildtype is 'Minor'" {
        It "Increments the minor version and resets the build number" {
            $version = [version]"1.2.3"
            $result = Update-Version -Version $version -Buildtype 'Minor'
            $result | Should -Be "1.3.0"
        }
    }

    context "When the Buildtype is 'Major'" {
        It "Increments the major version and resets the minor and build numbers" {
            $version = [version]"1.2.3"
            $result = Update-Version -Version $version -Buildtype 'Major'
            $result | Should -Be "2.0.0"
        }
    }

}