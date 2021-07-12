variable "command_unix" {
  description = "The command to run on creation when the module is used on a Unix machine. If not specified, will default to be the same as the `command_windows` variable."
  type        = string
  default     = null
}

variable "command_windows" {
  description = "The command to run on creation when the module is used on a Windows machine. If not specified, will default to be the same as the `command_unix` variable."
  type        = string
  default     = null
}

variable "command_when_destroy_unix" {
  description = "The command to run on destruction when the module is used on a Unix machine. If not specified, will default to be the same as the `command_when_destroy_windows` variable."
  default     = null
}

variable "command_when_destroy_windows" {
  description = "The command to run on destruction when the module is used on a Windows machine. If not specified, will default to be the same as the `command_when_destroy_unix` variable."
  default     = null
}

variable "triggers" {
  description = "A value (of any type) that, when changed, will cause the script to be re-run (will first run the destroy command if this module already exists in the state)."
  type = any
  default     = ""
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "Map of environment variables to pass to the command. Will be merged with `sensitive_environment` and `triggerless_environment` (if either of them has the same key, those values will overwrite these values)."
}

variable "sensitive_environment" {
  type        = map(string)
  default     = {}
  description = "Map of (sentitive) environment variables to pass to the command. Will be merged with `environment` (this overwrites those values with the same key) and `triggerless_environment` (those values overwrite these values with the same key)."
}

variable "triggerless_environment" {
  type        = map(string)
  default     = {}
  description = "Map of environment variables to pass to the command, which will NOT trigger a resource re-create if changed. Will be merged with `environment` and `sensitive_environment` (if either of them has the same key, these values will overwrite those values) for resource creation, but WILL NOT be provided for the destruction command."
}

variable "working_dir" {
  type        = string
  default     = ""
  description = "The working directory where command will be executed."
}

variable "fail_on_error" {
  type        = bool
  default     = false
  description = "Whether a Terraform error should be thrown if the command throws an error. If true, nothing will be returned from this module and Terraform will fail the apply. If false, the error message will be returned in `stderr` and the error code will be returned in `exitcode`. Default: `false`."
}
