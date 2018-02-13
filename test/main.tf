module "stdout" {
  source = ".."

  command = "echo hello stdout"
}

output "stdout" {
  value = {
    stdout     = "${module.stdout.stdout}"
    stderr     = "${module.stdout.stderr}"
    exitstatus = "${module.stdout.exitstatus}"
  }
}

module "error" {
  source = ".."

  command              = "/bin/false"
  command_when_destroy = "echo destroyed!"
}

output "error" {
  value = {
    stdout     = "${module.error.stdout}"
    stderr     = "${module.error.stderr}"
    exitstatus = "${module.error.exitstatus}"
  }
}
