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

resource "null_resource" "contents" {
  depends_on = ["null_resource.shell"]

  triggers = {
    stdout     = "${file("${path.module}/stdout.${null_resource.start.id}")}"
    stderr     = "${file("${path.module}/stderr.${null_resource.start.id}")}"
    exitstatus = "${file("${path.module}/exitstatus.${null_resource.start.id}")}"
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
