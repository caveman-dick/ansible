# Testing Windows modules

## Requirements

To run the tests for the windows modules you will need to have the [Pester](https://github.com/pester/Pester) framework installed.

The easiest way to install is with [chocolatey](https://chocolatey.org):

```bash
choco install pester
```

## Running tests

To run the test suite, just navigate to the root of the repo in a PowerShell window and execute:

```powershell
Invoke-Pester
```

### Running inside VSCode

#### Task Setup

Add the following to your tasks.json:

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "0.1.0",
    "command": "powershell.exe",
    "isShellCommand": true,
    "showOutput": "always",
    "suppressTaskName": true,
    "args": [
        "-NoProfile", "-ExecutionPolicy", "Bypass"
    ],
    "tasks": [
        {
            "taskName": "Run Pester",
            "isTestCommand": true,
            "args": [
                "Write-Host 'Invoking Pester...'; Invoke-Pester -PesterOption @{IncludeVSCodeMarker=$true};",
                "Invoke-Command { Write-Host 'Completed Test task in task runner.' }"
            ],
            "problemMatcher": [
                {
                    "owner": "powershell",
                    "fileLocation": ["absolute"],
                    "severity": "error",
                    "pattern": [
                        {
                            "regexp": "^\\s*(\\[-\\]\\s*.*?)(\\d+)ms\\s*$",
                            "message": 1
                        },
                        {
                            "regexp": "^\\s+at\\s+[^,]+,\\s*(.*?):\\s+line\\s+(\\d+)$",
                            "file": 1,
                            "line": 2
                        }
                    ]
                }
            ]
        }
    ]
}

```

#### Debugging Setup

Add the following to your launch.json (when you have the PowerShell extention installed) :

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "PowerShell",
            "request": "launch",
            "name": "PowerShell Run Tests",
            "script": "Invoke-Pester",
            "args": [],
            "cwd": "${workspaceRoot}"
        }
    ]
}
```

##### Debugging Caveats

As the file under test is actually a tempfile generated on each run if you try and make changes to it these won't be reflected on the next test run.
To try and prevent this, the file is named `[ModuleName].TempGenerated.ps1` and marked as ReadOnly so that if you do try and edit it you won't be able
to without taking off this flag.

## Developing tests

Unit tests for modules should be contained within a folder named the same as the module. i.e. `test\units\modules\windows\win_nssm`

Once installed Pester enables a helper command that can setup a templated test (run in the folder `test\units\modules\windows\` otherwise you will need to specify the full path):

```powershell
New-Fixture -Path win_nssm -Name Nssm-Install
```

This will create a new folder if it doesn't exist and then add 2 new files.
Just delete the one that is named the same as the `-Name` param above. This is a implementation template and we don't need this.

Then replace the top 3 lines in the [Name].Tests.ps1 file with the following snippet:

```powershell
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleName = Split-Path -Leaf $here
$sut = '..\Load-Module.ps1'
. "$here\$sut" -ModuleName $moduleName
```

this snippet will automatically load the module based on the folder name the tests are in.

Then just add the Pester tests to verify the method. For more info on creating Pester tests have a gander [here](https://github.com/PowerShell/PowerShell/blob/master/docs/testing-guidelines/WritingPesterTests.md).