resource "null_resource" "start" {
  triggers {
    depends_id = "${var.depends_id}"
  }
}

locals {
  command_chomped              = "${chomp(var.command)}"
  command_when_destroy_chomped = "${chomp(var.command_when_destroy)}"
}

# these provide an empty file for data sources to read without exploding
resource "local_file" "stdout" {
  content  = ""
  filename = "${path.module}/stdout.${null_resource.start.id}"
}

resource "local_file" "stderr" {
  content  = ""
  filename = "${path.module}/stderr.${null_resource.start.id}"
}

resource "local_file" "exitstatus" {
  content  = ""
  filename = "${path.module}/exitstatus.${null_resource.start.id}"
}

# this overwrites local_files
resource "null_resource" "shell" {
  depends_on = ["local_file.stdout", "local_file.stderr", "local_file.exitstatus"]

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

# on the first apply these will get the overridden contents
data "local_file" "stdout" {
  filename   = "${path.module}/stdout.${null_resource.start.id}"
  depends_on = ["null_resource.shell", "local_file.stdout"]
}

data "local_file" "stderr" {
  filename   = "${path.module}/stderr.${null_resource.start.id}"
  depends_on = ["null_resource.shell", "local_file.stderr"]
}

data "local_file" "exitstatus" {
  filename   = "${path.module}/exitstatus.${null_resource.start.id}"
  depends_on = ["null_resource.shell", "local_file.exitstatus"]
}

# first apply stores contents and then ignores the later empty contents
resource "null_resource" "contents" {
  triggers = {
    stdout     = "${data.local_file.stdout.content}"
    stderr     = "${data.local_file.stderr.content}"
    exitstatus = "${data.local_file.exitstatus.content}"
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
