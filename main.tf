resource "null_resource" "start" {
  triggers {
    depends_id = "${var.depends_id}"
  }
}

locals {
  command_chomped              = "${chomp(var.command)}"
  command_when_destroy_chomped = "${chomp(var.command_when_destroy)}"
  output_path                  = "${var.output_path == "" ? path.module : var.output_path}"
}

resource "null_resource" "shell" {
  depends_on = ["null_resource.start"]

  triggers = {
    string = "${var.trigger}"
  }

  provisioner "local-exec" {
    command = "${local.command_chomped} 2>\"${local.output_path}/stderr.${self.id}\" >\"${local.output_path}/stdout.${self.id}\"; echo $? >\"${local.output_path}/exitstatus.${self.id}\""
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${local.command_when_destroy_chomped == "" ? ":" : local.command_when_destroy_chomped}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm \"${local.output_path}/stdout.${self.id}\""
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm \"${local.output_path}/stderr.${self.id}\""
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm \"${local.output_path}/exitstatus.${self.id}\""
  }
}

data "local_file" "stdout" {
  filename = "${local.output_path}/stdout.${null_resource.shell.id}"
}

data "local_file" "stderr" {
  filename = "${local.output_path}/stderr.${null_resource.shell.id}"
}

data "local_file" "exitstatus" {
  filename = "${local.output_path}/exitstatus.${null_resource.shell.id}"
}
