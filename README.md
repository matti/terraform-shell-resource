# terraform-shell-resource

[![Build Status](https://travis-ci.org/matti/terraform-shell-resource.svg?branch=master)](https://travis-ci.org/matti/terraform-shell-resource)

A workaround for https://github.com/hashicorp/terraform/issues/610 <-- please 👍, meanwhile:

This module runs a command as a `null_resource` and makes the stdout, stderr and exit status available as outputs (stored in triggers map). It runs once when the resource is created and again if input variables are changed.

External data source modules (run on each plan/apply):
- An [module by the same author](https://github.com/matti/terraform-shell-outputs) that is mature and tested (requires Ruby).
- An [module by a different author](https://github.com/Invicton-Labs/terraform-external-shell-data) that is new and not as well tested, but is compatible with Windows and has no external requirements.

## Usage

```
module "files" {
  source  = "matti/resource/shell"
  command = "ls -l"
}

output "my_files" {
  value = module.files.stdout
}
```

```
...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

my_files = total 16
-rw-r--r--  1 mpa  staff   112 Feb  9 09:06 main.tf
-rw-r--r--  1 mpa  staff  1007 Feb  9 09:07 terraform.tfstate
```

## Full usage

```
module "first" {
  source = "matti/resource/shell"

  command = ">/tmp/first echo I was here first"
}

module "greeting" {
  source = "matti/resource/shell"

  # workaround for missing depends_on in modules
  depends = [
    module.first.id
  ]

  environment = {
    GREETING = "hello"
  }

  command              = "echo $GREETING world from $(pwd) where /tmp/first has content: $(cat /tmp/first)"
  command_when_destroy = "echo $GREETING and good bye from $(pwd)"

  # runs on every apply
  trigger = timestamp()

  working_dir = "/tmp"
}

output "greeting" {
  value = module.greeting.stdout
}
```

```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

greeting = hello world from /private/tmp where /tmp/first has content: I was here first
```

## Windows support
This module also supports being run on Windows machines (assuming they support Powershell). If the `command_windows` and/or `command_when_destroy_windows` inputs are specified, they will be used instead of `command`/`command_when_destroy` when Terraform is run on Windows. If they are not specified, the `command`/`command_when_destroy` commands will be run regardless of the operating system.

## Additional examples

See [tests](tests) and [examples](examples)

## Related issues:
 - https://github.com/hashicorp/terraform/issues/610
 - https://github.com/hashicorp/terraform/issues/17337
 - https://github.com/hashicorp/terraform/issues/6830
 - https://github.com/hashicorp/terraform/issues/17034
 - https://github.com/hashicorp/terraform/issues/10878
 - https://github.com/hashicorp/terraform/issues/8136
 - https://github.com/hashicorp/terraform/issues/18197
 - https://github.com/hashicorp/terraform/issues/17862
