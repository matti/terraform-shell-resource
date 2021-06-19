
# Equivalent of set -e
$ErrorActionPreference = "Stop"

# Equivalent of set -u (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.1)
set-strictmode -version 3.0
$_path = $args[0]
$_id = $args[1]
$_cmd = $args[2..($args.length - 1)]

# Equivalent of set +e
$ErrorActionPreference = "Continue"
$process = Start-Process powershell.exe -ArgumentList "$($_cmd -join " ")" -Wait -PassThru -NoNewWindow -RedirectStandardError "$_path/stderr.$_id" -RedirectStandardOutput "$_path/stdout.$_id"
$exitcode = $process.ExitCode
[System.IO.File]::WriteAllText("$_path/exitstatus.$_id", "$exitcode", [System.Text.Encoding]::ASCII)
$ErrorActionPreference = "Stop"
