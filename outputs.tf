output "id" {
  value = random_uuid.uuid.result
}

output "stdout" {
  value     = null_resource.contents.triggers == null ? null : lookup(null_resource.contents.triggers, "stdout", null)
  sensitive = var.sensitive_output
}

output "stderr" {
  value = null_resource.contents.triggers == null ? null : lookup(null_resource.contents.triggers, "stderr", null)
}

output "exitstatus" {
  value = null_resource.contents.triggers == null ? null : (
    lookup(null_resource.contents.triggers, "exitstatus", null) == null ? null : (
      tonumber(
        lookup(null_resource.contents.triggers, "exitstatus", null)
      )
    )
  )
}
