## This loads the provided module with dummy data so that we can test the functions in the module

Param(
    [Parameter(Mandatory=$True)]
    [string]$ModuleName
)

Write-Host "Loading ansible Module - $ModuleName"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$powershell_path = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'test\\units\\modules\\windows', 'lib\ansible\module_utils\powershell.ps1'

# It won't load as a module unless the ext is .psm1
$powershell_module_path = $powershell_path.Replace(".ps1", ".psm1")
Copy-Item $powershell_path $powershell_module_path
$sut = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'test\\units\\modules\\windows', "lib\ansible\modules\windows\$ModuleName.ps1"

$complex_args = @'
{"name": "TaskName", "state": "noop" }
'@

$global:complex_args = @{ 
    name = 'TaskName'
    state = 'noop'
}

Import-Module -Name $powershell_module_path -DisableNameChecking -Force
Import-Module -Name $sut