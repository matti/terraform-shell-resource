module "stdout" {
  source = "../.."

  command = "./test.sh"
  working_dir = "${path.module}/bin"
}

output "output" {
  value = {
    stdout     = module.stdout.stdout
    stderr     = module.stdout.stderr
    exitstatus = module.stdout.exitstatus
  }
}

