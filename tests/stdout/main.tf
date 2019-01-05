module "stdout" {
  source = "../.."

  command = "echo hello"
}

output "output" {
  value = {
    stdout     = "${module.stdout.stdout}"
    stderr     = "${module.stdout.stderr}"
    exitstatus = "${module.stdout.exitstatus}"
  }
}
