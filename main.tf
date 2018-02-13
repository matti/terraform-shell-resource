resource "null_resource" "shell" {
  triggers {
    command = "${var.command}"
  }

  provisioner "local-exec" {
    command = "${var.command} 2>${path.module}/stderr.${self.id} >${path.module}/stdout.${self.id}; echo $? >${path.module}/exitstatus.${self.id}"
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
  depends_on = ["null_resource.shell"]
  filename   = "${path.module}/stdout.${null_resource.shell.id}"
}

data "local_file" "stderr" {
  depends_on = ["null_resource.shell"]
  filename   = "${path.module}/stderr.${null_resource.shell.id}"
}

data "local_file" "exitstatus" {
  depends_on = ["null_resource.shell"]
  filename   = "${path.module}/exitstatus.${null_resource.shell.id}"
}
