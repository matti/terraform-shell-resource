module "when_destroy" {
  source               = "../.."
  command_when_destroy = "touch did_destroy"
}

output "output" {
  value = {
    stdout     = "${module.when_destroy.stdout}"
    stderr     = "${module.when_destroy.stderr}"
    exitstatus = "${module.when_destroy.exitstatus}"
  }
}
