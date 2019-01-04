provider "null" {
  version = "~> 1.0"
}

provider "external" {
  version = "~> 1.0"
}

resource "null_resource" "start" {
  triggers {
    depends_id = "${var.depends_id}"
  }
}

locals {
  command_chomped              = "${chomp(var.command)}"
  command_when_destroy_chomped = "${chomp(var.command_when_destroy)}"
}

resource "null_resource" "shell" {
  triggers = {
    string = "${var.trigger}"
  }

  provisioner "local-exec" {
    command = "${local.command_chomped} 2>\"${path.module}/stderr.${null_resource.start.id}\" >\"${path.module}/stdout.${null_resource.start.id}\"; echo $? >\"${path.module}/exitstatus.${null_resource.start.id}\""
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${local.command_when_destroy_chomped == "" ? ":" : local.command_when_destroy_chomped}"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "rm \"${path.module}/stdout.${null_resource.start.id}\""
    on_failure = "continue"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "rm \"${path.module}/stderr.${null_resource.start.id}\""
    on_failure = "continue"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "rm \"${path.module}/exitstatus.${null_resource.start.id}\""
    on_failure = "continue"
  }
}

data "external" "stdout" {
  depends_on = ["null_resource.shell"]
  program    = ["sh", "${path.module}/read.sh", "${path.module}/stdout.${null_resource.start.id}"]
}

data "external" "stderr" {
  depends_on = ["null_resource.shell"]
  program    = ["sh", "${path.module}/read.sh", "${path.module}/stderr.${null_resource.start.id}"]
}

data "external" "exitstatus" {
  depends_on = ["null_resource.shell"]
  program    = ["sh", "${path.module}/read.sh", "${path.module}/exitstatus.${null_resource.start.id}"]
}

resource "null_resource" "contents" {
  depends_on = ["null_resource.shell"]

  triggers = {
    stdout     = "${data.external.stdout.result["content"]}"
    stderr     = "${data.external.stderr.result["content"]}"
    exitstatus = "${data.external.exitstatus.result["content"]}"
    string     = "${var.trigger}"
  }

  lifecycle {
    ignore_changes = [
      "triggers",
    ]
  }
}
