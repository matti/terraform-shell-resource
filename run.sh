#!/usr/bin/env sh
set -euo pipefail

_path=$1; shift
_id=$1; shift

set +e
  2>"$_path/stderr.$_id" >"$_path/stdout.$_id" sh -c "$@"
  >"$_path/exitstatus.$_id" echo $?
set -e
