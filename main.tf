resource "null_resource" "start" {
  provisioner "local-exec" {
    command = "echo depends_id=${var.depends_id}"
  }
}

resource "null_resource" "shell" {
  depends_on = ["null_resource.start"]

  triggers {
    command              = "${var.command}"
    command_when_destroy = "${var.command_when_destroy}"
  }

  provisioner "local-exec" {
    command = "${chomp(var.command)} 2>${path.module}/stderr.${self.id} >${path.module}/stdout.${self.id}; echo $? >${path.module}/exitstatus.${self.id}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "${var.command_when_destroy == "" ? ":" : chomp(var.command_when_destroy)}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm ${path.module}/stdout.${self.id}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm ${path.module}/stderr.${self.id}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm ${path.module}/exitstatus.${self.id}"
  }
}

data "local_file" "stdout" {
  filename = "${path.module}/stdout.${null_resource.shell.id}"
}

data "local_file" "stderr" {
  filename = "${path.module}/stderr.${null_resource.shell.id}"
}

data "local_file" "exitstatus" {
  filename = "${path.module}/exitstatus.${null_resource.shell.id}"
}
