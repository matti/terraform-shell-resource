module "stdout" {
  source = ".."

  command = "ls -l"
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

  command              = "echo on create: \"${module.stdout.stdout}\""
  command_when_destroy = "echo on destroy: \"${module.stdout.stdout}\""
}

output "depends_on_stdout" {
  value = {
    stdout     = "${module.depends_on_stdout.stdout}"
    stderr     = "${module.depends_on_stdout.stderr}"
    exitstatus = "${module.depends_on_stdout.exitstatus}"
  }
}

module "do_not_trigger" {
  source = ".."

  triggers = {
    command              = false
    command_when_destroy = false
  }

  command              = "echo changeme"
  command_when_destroy = "echo changeme"
}

output "do_not_trigger" {
  value = {
    stdout = "${module.do_not_trigger.stdout}"
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
