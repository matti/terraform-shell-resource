load ../helper

@test "creates did_destroy on destroy" {
  run rm did_destroy
  [ ! -e "did_destroy" ]

  run terraform destroy -force
  assert $status 0
  [ -e "did_destroy" ]

  rm did_destroy
}
