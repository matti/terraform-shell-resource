variable "trigger" {
  default = "1"
}

module "test" {
  source = "../.."

  trigger = var.trigger

  command = "date"
}

output "output" {
  value = {
    stdout     = module.test.stdout
    stderr     = module.test.stderr
    exitstatus = module.test.exitstatus
  }
}
