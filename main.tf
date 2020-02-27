provider "null" {
  version = "~> 2.1"
}

locals {
  command_chomped              = chomp(var.command)
  command_when_destroy_chomped = chomp(var.command_when_destroy)
  module_path                  = path.module
  absolute_path                = abspath(path.module)
}

resource "random_uuid" "uuid" {
  depends_on = [var.depends]
}

resource "null_resource" "shell" {
  triggers = {
    trigger                      = var.trigger
    command_chomped              = local.command_chomped
    command_when_destroy_chomped = local.command_when_destroy_chomped
    environment_keys             = join("__TF_SHELL_RESOURCE_MAGIC_STRING", keys(var.environment))
    environment_values           = join("__TF_SHELL_RESOURCE_MAGIC_STRING", values(var.environment))
    module_path                  = local.module_path
    working_dir                  = var.working_dir
    random_uuid                  = random_uuid.uuid.result
  }

  provisioner "local-exec" {
    command = local.command_chomped

    environment = zipmap(
      split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_keys),
      split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_values)
    )
    working_dir = self.triggers.working_dir

    interpreter = [
      "${local.absolute_path}/run.sh",
      local.absolute_path,
      self.triggers.random_uuid
    ]
  }

  provisioner "local-exec" {
    when    = destroy
    command = self.triggers.command_when_destroy_chomped == "" ? ":" : self.triggers.command_when_destroy_chomped
    environment = zipmap(
      split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_keys),
      split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_values)
    )
    working_dir = self.triggers.working_dir
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm '${self.triggers.absolute_path}/stdout.${self.triggers.random_uuid}'"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm '${self.triggers.absolute_path}/stderr.${self.triggers.random_uuid}'"
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm '${self.triggers.absolute_path}/exitstatus.${self.triggers.random_uuid}'"
    on_failure = continue
  }
}

locals {
  stdout     = "${local.absolute_path}/stdout.${random_uuid.uuid.result}"
  stderr     = "${local.absolute_path}/stderr.${random_uuid.uuid.result}"
  exitstatus = "${local.absolute_path}/exitstatus.${random_uuid.uuid.result}"
}

resource "null_resource" "contents" {
  triggers = {
    # when the shell resource changes (var.trigger etc), this causes evaluation to happen after
    # using depends_on would be true for the subsequent apply causing terraform to explode
    id = null_resource.shell.id

    stdout     = fileexists(local.stdout) ? chomp(file(local.stdout)) : null
    stderr     = fileexists(local.stderr) ? chomp(file(local.stderr)) : null
    exitstatus = fileexists(local.exitstatus) ? chomp(file(local.exitstatus)) : null
  }
}
