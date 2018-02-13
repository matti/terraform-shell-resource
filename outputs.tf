output "stdout" {
  value = "${data.local_file.stdout.content}"
}

output "stderr" {
  value = "${data.local_file.stderr.content}"
}

output "exitstatus" {
  value = "${data.local_file.exitstatus.content}"
}
