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
  depends_on = ["null_resource.start"]

  triggers = {
    string = "${var.trigger}"
  }

  provisioner "local-exec" {
    command = "${local.command_chomped} 2>\"${path.module}/stderr.${self.id}\" >\"${path.module}/stdout.${self.id}\"; echo $? >\"${path.module}/exitstatus.${self.id}\""
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${local.command_when_destroy_chomped == "" ? ":" : local.command_when_destroy_chomped}"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "rm \"${path.module}/stdout.${self.id}\""
    on_failure = "continue"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "rm \"${path.module}/stderr.${self.id}\""
    on_failure = "continue"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "rm \"${path.module}/exitstatus.${self.id}\""
    on_failure = "continue"
  }
}

data "external" "read" {
  program = ["ruby", "${path.module}/read.rb"]

  query = {
    stdout     = "${path.module}/stdout.${null_resource.shell.id}"
    stderr     = "${path.module}/stderr.${null_resource.shell.id}"
    exitstatus = "${path.module}/exitstatus.${null_resource.shell.id}"
  }
}

resource "null_resource" "contents" {
  triggers = {
    stdout     = "${data.external.read.result["stdout"]}"
    stderr     = "${data.external.read.result["stderr"]}"
    exitstatus = "${data.external.read.result["exitstatus"]}"
  }

  lifecycle {
    ignore_changes = [
      "triggers",
    ]
  }
}

output "stdout" {
  value = "${chomp(null_resource.contents.triggers["stdout"])}"
}

output "stderr" {
  value = "${chomp(null_resource.contents.triggers["stderr"])}"
}

output "exitstatus" {
  value = "${chomp(null_resource.contents.triggers["exitstatus"])}"
}
