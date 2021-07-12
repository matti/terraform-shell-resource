locals {
  is_windows                   = dirname("/") == "\\"
  command_unix                 = chomp(var.command_unix != null ? var.command_unix : (var.command_windows != null ?  var.command_windows : ":"))
  command_windows              = chomp(var.command_windows != null ? var.command_windows : (var.command_unix != null ? var.command_unix : "% ':'"))
  command_when_destroy_unix    = chomp(var.command_when_destroy_unix != null ? var.command_when_destroy_unix : (var.command_when_destroy_windows != null ?  var.command_when_destroy_windows : ":"))
  command_when_destroy_windows = chomp(var.command_when_destroy_windows != null ? var.command_when_destroy_windows : (var.command_when_destroy_unix != null ? var.command_when_destroy_unix : "% ':'"))
  temporary_dir                = abspath(path.module)
  triggers                      = try(tostring(var.triggers), jsonencode(var.triggers))
  output_separator = "__TF_MAGIC_RANDOM_SEP"
  interpreter                  = local.is_windows ? ["powershell.exe", "${abspath(path.module)}/run.ps1"] : ["${abspath(path.module)}/run.sh"]
}

resource "random_uuid" "uuid" {}

resource "null_resource" "shell" {
  triggers = {
    triggers                     = local.triggers
    command_unix                 = local.command_unix
    command_windows              = local.command_windows
    command_when_destroy_unix    = local.command_when_destroy_unix
    command_when_destroy_windows = local.command_when_destroy_windows
    environment                  = jsonencode(var.environment)
    sensitive_environment        = sensitive(jsonencode(var.sensitive_environment))
    working_dir                  = var.working_dir
    random_uuid                  = random_uuid.uuid.result
    fail_on_error                = var.fail_on_error
    stdout_file                  = "stdout.${random_uuid.uuid.result}"
    stderr_file                  = "stderr.${random_uuid.uuid.result}"
    exitstatus_file              = "exitstatus.${random_uuid.uuid.result}"
  }

  provisioner "local-exec" {
    when        = create
    command = local.is_windows ? self.triggers.command_windows : self.triggers.command_unix
    environment = merge(var.environment, var.sensitive_environment, var.triggerless_environment)
    working_dir = self.triggers.working_dir
    interpreter = concat(local.interpreter, [
      local.temporary_dir,
      self.triggers.random_uuid,
      self.triggers.fail_on_error ? "true" : "false"
    ])
  }

  provisioner "local-exec" {
    when        = destroy
    command     = dirname("/") == "\\" ? self.triggers.command_when_destroy_windows : self.triggers.command_when_destroy_unix
    environment = merge(jsondecode(self.triggers.environment), jsondecode(self.triggers.sensitive_environment))
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    working_dir = self.triggers.working_dir
  }
}

locals {
  stdout_file     = "${local.temporary_dir}/${null_resource.shell.triggers.stdout_file}"
  stderr_file     = "${local.temporary_dir}/${null_resource.shell.triggers.stderr_file}"
  exitstatus_file = "${local.temporary_dir}/${null_resource.shell.triggers.exitstatus_file}"
}

data "local_file" "stdout" {
  depends_on = [null_resource.shell]
  filename = fileexists(local.stdout_file) ? local.stdout_file : "${path.module}/empty"
}
data "local_file" "stderr" {
  depends_on = [null_resource.shell]
  filename = fileexists(local.stdout_file) ? local.stderr_file : "${path.module}/empty"
}
data "local_file" "exitstatus" {
  depends_on = [null_resource.shell]
  filename = fileexists(local.stdout_file) ? local.exitstatus_file : "${path.module}/empty"
}

// Use this as a resourced-based method to take an input that might change when the output files are missing,
// but the triggers haven't changed, and maintain the same output.
resource "random_id" "outputs" {
  // Reload the data when any of the main triggers change
  keepers = null_resource.shell.triggers
  byte_length = 8
  // Feed the output values in as prefix. Then we can extract them from the output of this resource,
  // which will only change when the input triggers change
  prefix = "${jsonencode({
    stdout = chomp(data.local_file.stdout.content)
    stderr = chomp(data.local_file.stderr.content)
    exitstatus = chomp(data.local_file.exitstatus.content)
  })}${local.output_separator}"
  // Changes to the prefix shouldn't trigger a recreate, because when run again somewhere where the
  // original output files don't exist (but the shell triggers haven't changed), we don't want to
  // regenerate the output from non-existant files
  lifecycle {
    ignore_changes = [
      prefix
    ]
  }

  // Delete the files right away so they're not lingering on any local machine. The data has now
  // been saved in the state so we no longer need them.
  provisioner "local-exec" {
    when        = create
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    command     = "rm '${self.keepers.stdout_file}'"
    on_failure  = continue
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = create
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    command     = "rm '${self.keepers.stderr_file}'"
    on_failure  = continue
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = create
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    command     = "rm '${self.keepers.exitstatus_file}'"
    on_failure  = continue
    working_dir = path.module
  }
}

locals {
  // Remove the random ID off the random ID and extract only the prefix
  outputs = jsondecode(split(local.output_separator, random_id.outputs.b64_std)[0])
}
