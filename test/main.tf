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

module "depends_on_stdout" {
  source = ".."

  command              = "echo on create module.stdout.stdout, because of https://github.com/hashicorp/terraform/issues/17337"
  command_when_destroy = "echo on destroy 👹 👹 👹 👹 👹 : ${module.stdout.stdout}"
}

output "depends_on_stdout" {
  value = {
    stdout     = "${module.depends_on_stdout.stdout}"
    stderr     = "${module.depends_on_stdout.stderr}"
    exitstatus = "${module.depends_on_stdout.exitstatus}"
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
