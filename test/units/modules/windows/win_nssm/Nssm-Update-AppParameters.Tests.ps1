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

    It "should set the AppParameters in the same order that they were sent in as" {
        Mock Nssm-Invoke { return $cmd } -Verifiable -ParameterFilter { $cmd -eq 'set "SomeService" AppParameters -name2 "value2" -name "value" -name3 "value3"' }
        Nssm-Update-AppParameters -name "SomeService" -appParameters "-name2=value2; -name=value; -name3=value3"
        Assert-VerifiableMocks        
    }

    It "should put the app paramter which has a key of _ at the beginning of the command" {
        Mock Nssm-Invoke { return $cmd } -Verifiable -ParameterFilter { $cmd -eq 'set "SomeService" AppParameters command -name1 "value1" -name2 "value2"' }
        Nssm-Update-AppParameters -name "SomeService" -appParameters "_=command; -name1=value1; -name2=value2"
        Assert-VerifiableMocks        
    }

    It "should put the app paramter which has a key of _ at the beginning of the command even if the parameter is not the first in the list" {
        Mock Nssm-Invoke { return $cmd } -Verifiable -ParameterFilter { $cmd -eq 'set "SomeService" AppParameters command -name1 "value1" -name2 "value2"' }
        Nssm-Update-AppParameters -name "SomeService" -appParameters "-name1=value1; -name2=value2; _=command"
        Assert-VerifiableMocks        
    }

    It "should pass the appParametersFree verbatim to Nssm-Invoke" {
        Mock Nssm-Invoke { return $cmd } -Verifiable -ParameterFilter { $cmd -eq 'set "SomeService" AppParameters -jar C:\jenkins\jenkins-swarm.jar -fsroot C:\jenkins\ws' }
        Nssm-Update-AppParameters -name "SomeService" -appParameters '' -appParametersFree '-jar C:\jenkins\jenkins-swarm.jar -fsroot C:\jenkins\ws'
        Assert-VerifiableMocks        
}
