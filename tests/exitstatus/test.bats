load ../helper

@test "stderr and exitstatus set" {
  assert_tf_output ".output.value.stdout" ""
  assert_match_tf_output ".output.value.stderr" "not found"
  assert_tf_output ".output.value.exitstatus" "127"
}
