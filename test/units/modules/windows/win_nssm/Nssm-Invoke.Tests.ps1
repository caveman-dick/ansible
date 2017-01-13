$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleName = Split-Path -Leaf $here
$sut = '..\Load-Module.ps1'
. "$here\$sut" -ModuleName $moduleName

Describe "Nssm-Invoke" {    
    It "calls invoke-command with the supplied parameters" {

        Mock Invoke-Expression { return $Command }
        Nssm-Invoke -cmd "somecommand" | Should Be "nssm somecommand"
    }
}
