
# Equivalent of set -e
$ErrorActionPreference = "Stop"

# Equivalent of set -u (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.1)
set-strictmode -version 3.0
$_path = $args[0]
$_id = $args[1]
$_cmd = $args[2..($args.length - 1)]

# Equivalent of set +e
$ErrorActionPreference = "Continue"
$exitcode = 0
try {
    powershell.exe @_cmd 2>"$_path/stderr.$_id" >"$_path/stdout.$_id"
    if ($LASTEXITCODE) { 
        $exitcode = $LASTEXITCODE
        #throw $er 
    }
}
catch {
    #$exitcode = $_
}
[System.IO.File]::WriteAllText("$_path/exitstatus.$_id", "$exitcode", [System.Text.Encoding]::ASCII)
$ErrorActionPreference = "Stop"
