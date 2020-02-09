output "id" {
  value = random_uuid.uuid.result
}

output "stdout" {
  value = null_resource.contents.triggers == null ? null : null_resource.contents.triggers.stdout
}

output "stderr" {
  value = null_resource.contents.triggers == null ? null : null_resource.contents.triggers.stderr
}

output "exitstatus" {
  value = null_resource.contents.triggers == null ? null : (
    null_resource.contents.triggers.exitstatus == null ? null : (
      tonumber(null_resource.contents.triggers.exitstatus)
    )
  )
}
