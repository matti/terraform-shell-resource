module "error" {
  source = "../.."

  command = "non_existing_command"
}

output "output" {
  value = {
    stdout     = "${module.error.stdout}"
    stderr     = "${module.error.stderr}"
    exitstatus = "${module.error.exitstatus}"
  }
}
