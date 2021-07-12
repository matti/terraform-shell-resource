output "id" {
  value = random_uuid.uuid.result
}

output "stdout" {
  value = local.outputs.stdout
}

output "stderr" {
  value = local.outputs.stderr
}

output "exitstatus" {
  value = tonumber(local.outputs.exitstatus)
}
