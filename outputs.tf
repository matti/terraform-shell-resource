output "id" {
  value = "${null_resource.shell.id}"
}

output "stdout" {
  value = "${chomp(null_resource.contents.triggers["stdout"])}"

  #value = "${data.external.stdout.result["content"]}"
}

output "stderr" {
  value = "${chomp(null_resource.contents.triggers["stderr"])}"

  #value = "${data.external.stderr.result["content"]}"
}

output "exitstatus" {
  value = "${chomp(null_resource.contents.triggers["exitstatus"])}"

  #value = "${data.external.exitstatus.result["content"]}"
}
