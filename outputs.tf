output "id" {
  value = "${null_resource.shell.id}"
}

output "stdout" {
  value = "${chomp(data.local_file.stdout.content)}"
}

output "stderr" {
  value = "${chomp(data.local_file.stderr.content)}"
}

output "exitstatus" {
  value = "${chomp(data.local_file.exitstatus.content)}"
}
