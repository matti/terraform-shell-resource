module "stdout" {
  source = "../.."

  command = "echo $foo $bar"
  environment = {
    foo = "bar"
    bar = "BAZ"
  }
}

output "output" {
  value = {
    stdout     = module.stdout.stdout
    stderr     = module.stdout.stderr
    exitstatus = module.stdout.exitstatus
  }
}

