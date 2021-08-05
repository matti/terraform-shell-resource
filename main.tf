locals {
  is_windows                   = dirname("/") == "\\"
  command_unix                 = chomp(var.command != null ? var.command : ":")
  command_windows              = chomp(var.command_windows != null ? var.command_windows : (var.command != null ? var.command : "% ':'"))
  command_when_destroy_unix    = chomp(var.command_when_destroy != null ? var.command_when_destroy : ":")
  command_when_destroy_windows = chomp(var.command_when_destroy_windows != null ? var.command_when_destroy_windows : (var.command_when_destroy != null ? var.command_when_destroy : "% ':'"))
  temporary_dir                = abspath(path.module)
  interpreter                  = local.is_windows ? ["powershell.exe", "${abspath(path.module)}/run.ps1"] : ["${abspath(path.module)}/run.sh"]
}

resource "random_uuid" "uuid" {
  depends_on = [var.depends]
}

resource "null_resource" "shell" {
  triggers = {
    trigger                      = var.trigger
    command_unix                 = local.command_unix
    command_windows              = local.command_windows
    command_when_destroy_unix    = local.command_when_destroy_unix
    command_when_destroy_windows = local.command_when_destroy_windows
    environment_keys             = join("__TF_SHELL_RESOURCE_MAGIC_STRING", keys(var.environment))
    environment_values           = join("__TF_SHELL_RESOURCE_MAGIC_STRING", values(var.environment))
    sensitive_environment_keys   = join("__TF_SHELL_RESOURCE_MAGIC_STRING", keys(var.sensitive_environment))
    sensitive_environment_values = sha256(join("__TF_SHELL_RESOURCE_MAGIC_STRING", values(var.sensitive_environment)))
    working_dir                  = var.working_dir
    random_uuid                  = random_uuid.uuid.result
    fail_on_error                = var.fail_on_error
  }

  provisioner "local-exec" {
    command = local.is_windows ? self.triggers.command_windows : self.triggers.command_unix

    // Due to the join/split of environment keys/vars, we need to check for empty strings to prevent an env var of ""="", which Powershell does not like
    environment = merge(zipmap(
      self.triggers.environment_keys == "" ? [] : split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_keys),
      self.triggers.environment_values == "" ? [] : split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_values)
    ), var.sensitive_environment, var.triggerless_environment)
    working_dir = self.triggers.working_dir

    interpreter = concat(local.interpreter, [
      local.temporary_dir,
      self.triggers.random_uuid,
      self.triggers.fail_on_error ? "true" : "false"
    ])
  }

  provisioner "local-exec" {
    when    = destroy
    command = dirname("/") == "\\" ? self.triggers.command_when_destroy_windows : self.triggers.command_when_destroy_unix
    environment = zipmap(
      split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_keys),
      split("__TF_SHELL_RESOURCE_MAGIC_STRING", self.triggers.environment_values)
    )
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    working_dir = self.triggers.working_dir
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    command     = "rm 'stdout.${self.triggers.random_uuid}'"
    on_failure  = continue
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    command     = "rm 'stderr.${self.triggers.random_uuid}'"
    on_failure  = continue
    working_dir = path.module
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = dirname("/") == "\\" ? ["powershell.exe"] : []
    command     = "rm 'exitstatus.${self.triggers.random_uuid}'"
    on_failure  = continue
    working_dir = path.module
  }
}

locals {
  stdout     = "${local.temporary_dir}/stdout.${random_uuid.uuid.result}"
  stderr     = "${local.temporary_dir}/stderr.${random_uuid.uuid.result}"
  exitstatus = "${local.temporary_dir}/exitstatus.${random_uuid.uuid.result}"
}

resource "null_resource" "contents_if_missing" {
  depends_on = [
    null_resource.shell
  ]

  lifecycle {
    ignore_changes = [
      triggers
    ]
  }

  triggers = {
    stdout     = fileexists(local.stdout) ? (var.sensitive_outputs ? sensitive(chomp(file(local.stdout))) : chomp(file(local.stdout))) : null
    stderr     = fileexists(local.stderr) ? (var.sensitive_outputs ? sensitive(chomp(file(local.stderr))) : chomp(file(local.stdout))) : null
    exitstatus = fileexists(local.exitstatus) ? chomp(file(local.exitstatus)) : null
  }
}

resource "null_resource" "contents" {
  depends_on = [
    null_resource.contents_if_missing
  ]
  triggers = {
    # when the shell resource changes (var.trigger etc), this causes evaluation to happen after
    # using depends_on would be true for the subsequent apply causing terraform to explode
    id = null_resource.shell.id

    # the lookup values are actually never returned, they just need to be there (!)
    stdout = var.sensitive_outputs ? (
      sensitive(fileexists(local.stdout) ? chomp(file(local.stdout)) : (null_resource.contents_if_missing.triggers == null ? "" : lookup(null_resource.contents_if_missing.triggers, "stdout", "")))
      ) : (
      fileexists(local.stdout) ? chomp(file(local.stdout)) : (null_resource.contents_if_missing.triggers == null ? "" : lookup(null_resource.contents_if_missing.triggers, "stdout", ""))
    )
    stderr = var.sensitive_outputs ? (
      sensitive(fileexists(local.stderr) ? chomp(file(local.stderr)) : (null_resource.contents_if_missing.triggers == null ? "" : lookup(null_resource.contents_if_missing.triggers, "stderr", "")))
      ) : (
      fileexists(local.stderr) ? chomp(file(local.stderr)) : (null_resource.contents_if_missing.triggers == null ? "" : lookup(null_resource.contents_if_missing.triggers, "stderr", ""))
    )
    exitstatus = fileexists(local.exitstatus) ? chomp(file(local.exitstatus)) : (null_resource.contents_if_missing.triggers == null ? -1 : lookup(null_resource.contents_if_missing.triggers, "exitstatus", -1))
  }
}
