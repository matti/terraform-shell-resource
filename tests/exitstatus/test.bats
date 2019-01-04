load ../helper

@test "stderr and exitstatus set" {
  assert_tf_output ".output.value.stdout" ""
  assert_match_tf_output ".output.value.stderr" "non_existing_command: command not found"
  assert_tf_output ".output.value.exitstatus" "127"
}
