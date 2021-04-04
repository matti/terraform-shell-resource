module "stdout" {
  source = "../.."

  command = "echo hello"

  sensitive_output = true
}

output "output" {
  value = {
    stdout     = module.stdout.stdout
    stderr     = module.stdout.stderr
    exitstatus = module.stdout.exitstatus
  }
}

