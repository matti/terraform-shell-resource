#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

output() {
  echo "# $@" >&3
}

output_raw() {
  printf "$@" >&3
}

runner() {
  output "running: $@"
  run bash -c "$@"
}

tf_output() {
  runner "terraform output -json | jq -r $1"
}

assert_tf_output() {
  tf_output $1
  assert "$output" "$2"
}

assert_match_tf_output() {
  tf_output $1
  assert_match "$output" "$2"
}

assert() {
  output_raw "# assert '$1' = '$2'"
  if [ "$1" = "$2" ]; then
    output_raw " .. ok\n"
  else
    output_raw " .. fail\n"
    exit 1
  fi
}

assert_not() {
  output_raw "# assert_not '$1' != '$2'"
  if [ "$1" != "$2" ]; then
    output_raw " .. ok\n"
  else
    output_raw " .. fail\n"
    exit 1
  fi
}

assert_match() {
  output_raw "# assert_match '$1' =~ '$2'"
  if [[ "$1" =~ "$2" ]]; then
    output_raw " .. ok\n"
  else
    output_raw " .. fail\n"
    exit 1
  fi
}


cleanup() {
  set +e
    rm $DIR/../stdout.* >/dev/null 2>&1
    rm $DIR/../stderr.* >/dev/null 2>&1
    rm $DIR/../exitstatus.* >/dev/null 2>&1
  set -e

  set +e
    rm -rf .terraform >/dev/null 2>&1
    rm terraform.tfstate >/dev/null 2>&1
    rm terraform.tfstate.backup >/dev/null 2>&1
  set -e
}

setup() {
  cd $BATS_TEST_DIRNAME
  cleanup
  output "running: $BATS_TEST_DIRNAME $BATS_TEST_NAME"

  terraform init >/dev/null
  terraform apply -auto-approve >/dev/null
}

teardown() {
  cleanup
}
