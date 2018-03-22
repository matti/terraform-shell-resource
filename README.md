# terraform-shell-resource

This module runs a command as a `null_resource` and makes the stdout, stderr and exit status available as outputs (with temporary files stored in the module). See an external data source version with more features at https://github.com/matti/terraform-shell-outputs (that runs on every apply, this one only runs once when the resource is created).

Currently requires ruby - it would be great if somebody would write [read.rb](read.rb) in shell script without any dependencies (like jq) .

```
module "files" {
  source  = "matti/resource/shell"
  version = "0.0.1"

  command = "ls -l"
}

output "my_files" {
  value = "${module.files.stdout}
}
```

## Additional example with two resources

See [test/main.tf](test/main.tf)

```
$ cd test
$ terraform init
$ terraform apply
  Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

  Outputs:

  error = {
    exitstatus = 127

    stderr = /bin/sh: /bin/false: No such file or directory

    stdout =
  }
  stdout = {
    exitstatus = 0

    stderr =
    stdout = hello stdout

  }
```

## Related issues:

 - https://github.com/hashicorp/terraform/issues/17337
 - https://github.com/hashicorp/terraform/issues/6830
