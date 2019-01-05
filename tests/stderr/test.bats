load ../helper

@test "only stderr" {
  assert_tf_output ".output.value.stdout" ""
  assert_tf_output ".output.value.stderr" "herror"
  assert_tf_output ".output.value.exitstatus" "0"
}
