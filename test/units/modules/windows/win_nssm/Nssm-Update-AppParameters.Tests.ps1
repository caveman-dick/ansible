﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
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
}
