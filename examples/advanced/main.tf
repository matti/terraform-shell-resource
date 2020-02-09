module "first" {
  source = "../.."

  command = ">/tmp/first echo I was here first"
}

module "greeting" {
  source = "../.."

  # workaround for missing depends_on in modules
  depends = [
    module.first.id
  ]

  environment = {
    GREETING = "hello"
  }

  command              = "echo $GREETING world from $(pwd) where /tmp/first has content: $(cat /tmp/first)"
  command_when_destroy = "echo $GREETING and good bye from $(pwd)"

  # runs on every apply
  trigger = timestamp()

  working_dir = "/tmp"
}

output "greeting" {
  value = module.greeting.stdout
}
