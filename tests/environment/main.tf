module "stdout" {
  source = "../.."

  command = "echo $foo $BAR"
  environment = {
    foo = "BAR"
    BAR = "beer"
  }
}

output "output" {
  value = {
    stdout     = module.stdout.stdout
    stderr     = module.stdout.stderr
    exitstatus = module.stdout.exitstatus
  }
}

