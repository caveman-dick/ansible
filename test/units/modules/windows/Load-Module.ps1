## This loads the provided module with dummy data so that we can test the functions in the module

Param(
    [Parameter(Mandatory=$True)]
    [string]$ModuleName
)

Write-Host "Loading Module - $ModuleName"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$powershell_path = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'test\\units\\modules\\windows', 'lib\ansible\module_utils\powershell.ps1'
$sut = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'test\\units\\modules\\windows', "lib\ansible\modules\windows\$ModuleName.ps1"

$powershell_common = Get-Content $powershell_path -Raw
$module = Get-Content $sut -Raw

$complex_args = @'
{"name": "TaskName", "state": "noop" }
'@

$powershell_common = $powershell_common -replace "<<INCLUDE_ANSIBLE_MODULE_JSON_ARGS>>", $complex_args
$powershell_text = $module -replace "# POWERSHELL_COMMON", $powershell_common
$powershell_tempfile = [System.IO.Path]::GetTempFileName() + ".ps1"
Set-Content -Path $powershell_tempfile $powershell_text

. $powershell_tempfile