#!/usr/bin/env sh
set -eu

_path=$1; shift
_id=$1; shift
_failonerr=$1; shift

_stderrfile="$_path/stderr.$_id"
_stdoutfile="$_path/stdout.$_id"
_exitcodefile="$_path/exitstatus.$_id"

set +e
  2>"$_stderrfile" >"$_stdoutfile" sh -c "$@"
  _exitcode=$?
set -e

>"$_exitcodefile" echo $_exitcode

if [ "$_failonerr" = "true" ] && ! [ -z $_exitcode ]; then
  # If it should fail on an error, and it did fail, read the stderr file
  _stderr=$(cat "$_stderrfile")
  # Exit with the error message and code
  >&2 echo "$_stderr"
  exit $_exitcode
fi
