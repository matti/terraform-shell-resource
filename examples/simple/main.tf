module "stdout" {
  source = "../.."

  command = "date"
}

output "stdout" {
  value = module.stdout
}

module "stderr" {
  source = "../.."

  command = "(date >&2)"
}

output "stderr" {
  value = module.stderr
}

module "status_err" {
  source = "../.."

  command = "__this_command_does_not_exist"
}

output "status_err" {
  value = module.status_err
}

module "env" {
  source = "../.."

  environment = {
    GREETING = "hello"
  }
  command = "echo $GREETING world"
}

output "env" {
  value = module.env
}

module "whendestroy" {
  source = "../.."

  command_when_destroy = "echo DESTROY"
}

output "whendestroy" {
  value = module.whendestroy
}
