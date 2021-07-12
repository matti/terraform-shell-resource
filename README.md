# Terraform Shell (Resource)

This module allows generic shell commands to be run as a resource (will only re-run when an input variable changes). It supports both Linux and Windows (Mac currently untested, but *should* be supported) and requires no external dependencies. This is an updated and heavily revised version of the [original module from Matti Paksula](https://github.com/matti/terraform-shell-resource) that cleans up the code by using modern Terraform functions and fixes one of the major issues with the old module, which was that the outputs would not be updated on a trigger change.

This module is a workaround for https://github.com/hashicorp/terraform/issues/610, please give it a 👍 so we don't need this workaround anymore.

For a module that has the same functionality but runs as a data source instead (re-runs every plan/apply), see [this module](https://registry.terraform.io/modules/Invicton-Labs/shell-data/external/latest).

## Example use cases
- Integration of existing shell scripts that you use regularly
- Use of the AWS CLI to do things that the Terraform AWS provider does not yet support
- Integration of other installed tools such as `openssl`
- Whatever your heart desires

## Usage

```
module "shell_resource_hello" {
  source  = "Invicton-Labs/shell-resource/external"

  // The command to run on resource creation on Unix machines
  command_unix         = "echo \"$TEXT $MORETEXT from $ORIGINAL_CREATED_TIME\""

  // The command to run on resource creation on Windows machines
  command_windows = "Write-Host \"$env:TEXT $env:MORETEXT from $env:ORIGINAL_CREATED_TIME\""

  // The command to run on resource destruction on Unix machines
  command_when_destroy_unix         = "echo \"$TEXT $MORETEXT\""

  // The command to run on resource destruction on Windows machines
  command_when_destroy_windows = "Write-Host \"$env:TEXT $env:MORETEXT\""

  // The directory to run the command in
  working_dir     = path.root

  // Whether Terraform should exit with an error message if the command returns a non-zero exit status
  fail_on_error   = true

  // Environment variables (will appear in plain text in the Terraform plan output)
  environment = {
    TEXT     = "Hello"
    DESTROY_TEXT = "Goodbye"
  }

  // Environment variables (will be hidden in the Terraform plan output)
  sensitive_environment = {
    MORETEXT = "World"
  }

  // Environment variables that, when changed, will not trigger a re-create
  triggerless_environment = {
    ORIGINAL_CREATED_TIME = timestamp()
  }
}

output "stdout" {
  value = module.shell_resource_hello.stdout
}
output "stderr" {
  value = module.shell_resource_hello.stderr
}
output "exitstatus" {
  value = module.shell_resource_hello.exitstatus
}
```

```
...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

exitstatus = 0
stderr = ""
stdout = "Hello World from 2021-07-11T18:58:05Z"
```

## Breaking changes from Matti's version:
- `command` input variable renamed to `command_unix` for specificity
- `trigger` input variable renamed to `triggers` to match Terraform convention and to better represent the fact that a map of triggers is now accepted
- Changes to the `trigger` input variable will now result in a changed output
- `depends` input variable removed, as modules in modern Terraform versions now support `depends_on` natively

## Non-breaking changes from Matti's version:
- Temporary output files are now immediately deleted after reading them, to keep them from lingering around.
- The `trigger` input variable can now be any type, not just a string

## Related issues:
 - https://github.com/hashicorp/terraform/issues/610
 - https://github.com/hashicorp/terraform/issues/17337
 - https://github.com/hashicorp/terraform/issues/6830
 - https://github.com/hashicorp/terraform/issues/17034
 - https://github.com/hashicorp/terraform/issues/10878
 - https://github.com/hashicorp/terraform/issues/8136
 - https://github.com/hashicorp/terraform/issues/18197
 - https://github.com/hashicorp/terraform/issues/17862
