module "error" {
  source = "../.."

  command = "(echo herror >&2)"
}

output "output" {
  value = {
    stdout     = module.error.stdout
    stderr     = module.error.stderr
    exitstatus = module.error.exitstatus
  }
}
