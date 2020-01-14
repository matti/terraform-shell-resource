provider "null" {
  version = "~> 2.1"
}

provider "external" {
  version = "~> 1.0"
}

resource "null_resource" "start" {
  triggers = {
    depends_id = var.depends_id
  }
}

locals {
  command_chomped              = chomp(var.command)
  command_when_destroy_chomped = chomp(var.command_when_destroy)
  module_path                  = abspath(path.module)
}

resource "null_resource" "shell" {
  triggers = {
    string = var.trigger
  }

  provisioner "local-exec" {
    command     = "${local.command_chomped} 2>\"${local.module_path}/stderr.${null_resource.start.id}\" >\"${local.module_path}/stdout.${null_resource.start.id}\"; echo $? >\"${local.module_path}/exitstatus.${null_resource.start.id}\""
    environment = var.environment_variables
    working_dir = var.working_dir
  }

  provisioner "local-exec" {
    when        = destroy
    command     = local.command_when_destroy_chomped == "" ? ":" : local.command_when_destroy_chomped
    environment = var.environment_variables
    working_dir = var.working_dir
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm \"${local.module_path}/stdout.${null_resource.start.id}\""
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm \"${local.module_path}/stderr.${null_resource.start.id}\""
    on_failure = continue
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm \"${local.module_path}/exitstatus.${null_resource.start.id}\""
    on_failure = continue
  }
}

data "external" "stdout" {
  depends_on = [null_resource.shell]
  program    = ["sh", "${local.module_path}/read.sh", "${local.module_path}/stdout.${null_resource.start.id}"]
}

data "external" "stderr" {
  depends_on = [null_resource.shell]
  program    = ["sh", "${local.module_path}/read.sh", "${local.module_path}/stderr.${null_resource.start.id}"]
}

data "external" "exitstatus" {
  depends_on = [null_resource.shell]
  program    = ["sh", "${local.module_path}/read.sh", "${local.module_path}/exitstatus.${null_resource.start.id}"]
}

resource "null_resource" "contents" {
  depends_on = [null_resource.shell]

  triggers = {
    stdout     = data.external.stdout.result["content"]
    stderr     = data.external.stderr.result["content"]
    exitstatus = data.external.exitstatus.result["content"]
    string     = var.trigger
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}
