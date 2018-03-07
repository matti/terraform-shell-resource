module "stdout_output_path" {
  source = ".."

  command = "ls -l"

  #remember that path.module refers to THIS file, not the module
  output_path = "${path.module}/outputs"
}

output "stdout_output_path" {
  value = {
    stdout     = "${module.stdout_output_path.stdout}"
    stderr     = "${module.stdout_output_path.stderr}"
    exitstatus = "${module.stdout_output_path.exitstatus}"
  }
}

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

locals {
  depends_trigger_dependency_command = "echo changeme"
}

module "depends_trigger_dependency" {
  source = ".."

  trigger = "${local.depends_trigger_dependency_command}"
  command = "${local.depends_trigger_dependency_command}"
}

module "depends_trigger" {
  source = ".."

  depends_id = "${module.depends_trigger_dependency.id}"
  trigger    = "${module.depends_trigger_dependency.id}"

  command = "echo triggered $(date)"
}

output "depends_trigger" {
  value = {
    stdout = "${module.depends_trigger.stdout}"
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
