# terraform-shell-resource

[![Build Status](https://travis-ci.org/matti/terraform-shell-resource.svg?branch=master)](https://travis-ci.org/matti/terraform-shell-resource)

This module runs a command as a `null_resource` and makes the stdout, stderr and exit status available as outputs (with temporary files stored in the module). See an external data source version with more features at https://github.com/matti/terraform-shell-outputs (that runs on every apply, this one only runs once when the resource is created).

*warning* there is a support for `trigger` to re-run the module, but while it runs the command it does not update the outputs! There is nothing we can do before related issues (see below) are fixed.

```
module "files" {
  source  = "matti/resource/shell"
  command = "ls -l"
}

output "my_files" {
  value = "${module.files.stdout}
}
```

## Additional examples

See [tests](tests)

## Related issues:

 - https://github.com/hashicorp/terraform/issues/17337
 - https://github.com/hashicorp/terraform/issues/6830
 - https://github.com/hashicorp/terraform/issues/17034
 - https://github.com/hashicorp/terraform/issues/10878
 - https://github.com/hashicorp/terraform/issues/8136
 - https://github.com/hashicorp/terraform/issues/18197
 - https://github.com/hashicorp/terraform/issues/17862
