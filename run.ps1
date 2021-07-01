
# Equivalent of set -e
$ErrorActionPreference = "Stop"

# Equivalent of set -u (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.1)
set-strictmode -version 3.0
$_path = $args[0]
$_id = $args[1]
$_failonerr = $args[2]
$_cmd = $args[3..($args.length - 1)]

$_stderrfile = "$_path/stderr.$_id"
$_stdoutfile = "$_path/stdout.$_id"
$_exitcodefile = "$_path/exitstatus.$_id"

# Equivalent of set +e
$ErrorActionPreference = "Continue"
$_process = Start-Process powershell.exe -ArgumentList "$_cmd" -Wait -PassThru -NoNewWindow -RedirectStandardError "$_stderrfile" -RedirectStandardOutput "$_stdoutfile"
$_exitcode = $_process.ExitCode
$ErrorActionPreference = "Stop"

[System.IO.File]::WriteAllText("$_exitcodefile", "$_exitcode", [System.Text.Encoding]::ASCII)

if (( "$_failonerr" -eq "true" ) -and $_exitcode) {
    # If it should fail on an error, and it did fail, read the stderr file
    # Exit with the error message and code
    Write-Error [IO.File]::ReadAllText("$_stderrfile")
    exit $_exitcode
}
