$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleName = Split-Path -Leaf $here
$sut = '..\Load-Module.ps1'
. "$here\$sut" -ModuleName $moduleName

Describe "Nssm-Update-AppParameters" {
    BeforeEach {
        $Global:LastExitCode = 0;
    }
    
    It "calls Nssm-Invoke getting the AppParameters with the correct name" {
        Mock Nssm-Invoke {} -Verifiable -ParameterFilter { $cmd -eq "get `"SomeService`" AppParameters"}
        Mock Nssm-Invoke { return $cmd }
        Nssm-Update-AppParameters -name "SomeService" -appParameters "-name=value; -name2=value2"
        Assert-VerifiableMocks
    }

    It "throws an error if fetching the AppParameters returns > 0" {
        Mock Nssm-Invoke { $Global:LastExitCode = 1; return $cmd }
        { Nssm-Update-AppParameters -name "SomeService" -appParameters "name=value name2=value2" } | Should Throw "Error updating AppParameters for service ""SomeService"""
    }

    It "should set the AppParameters if they are different to what is already set" {        
        Mock Nssm-Invoke { return $cmd }
        Mock Nssm-Invoke {} -Verifiable -ParameterFilter { $cmd.StartsWith("set `"SomeService`" AppParameters")}
        Nssm-Update-AppParameters -name "SomeService" -appParameters "-name=value; -name2=value2"
        Assert-VerifiableMocks
    }    
}
