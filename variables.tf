variable "depends" {
  description = "(Optional) Equivalent to the `depends_on` input for a data/resource."
  default     = []
}

variable "command" {
  description = "(Optional) The command to run on creation when the module is used on a Unix machine."
  default     = null
}
variable "command_windows" {
  description = "(Optional) The command to run on creation when the module is used on a Windows machine. If not specified, will default to be the same as the `command` variable."
  default     = null
}

variable "command_when_destroy" {
  description = "(Optional) The command to run on destruction when the module is used on a Unix machine."
  default     = null
}

variable "command_when_destroy_windows" {
  description = "(Optional) The command to run on destruction when the module is used on a Windows machine. If not specified, will default to be the same as the `command_when_destroy` variable."
  default     = null
}

# warning! the outputs are not updated even if the trigger re-runs the command!
variable "trigger" {
  description = "(Optional) A string value that, when changed, will cause the script to be re-run (will first run the destroy command if this module already exists in the state)."
  default     = ""
}

variable "triggers" {
  type        = any
  default     = {}
  description = "(Optional) A map value that, when changed, will cause the script to be re-run (will first run the destroy command if this module already exists in the state)."
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "(Optional) Map of environment variables to pass to the command. Will be merged with `sensitive_environment` and `triggerless_environment`."
}

variable "sensitive_environment" {
  type        = map(string)
  default     = {}
  description = "(Optional) Map of (sentitive) environment variables to pass to the command. Will be merged with `environment` and `triggerless_environment`."
}

variable "triggerless_environment" {
  type        = map(string)
  default     = {}
  description = "(Optional) Map of environment variables to pass to the command, which will NOT trigger a resource re-create if changed. Will be merged with `environment` and `sensitive_environment`."
}

variable "working_dir" {
  type        = string
  default     = ""
  description = "(Optional) The working directory where command will be executed."
}

variable "fail_on_error" {
  type        = bool
  default     = false
  description = "(Optional) Whether a Terraform error should be thrown if the command throws an error. If true, nothing will be returned from this module and Terraform will fail the apply. If false, the error message will be returned in `stderr` and the error code will be returned in `exitcode`. Default: `false`."
}

variable "sensitive_outputs" {
  type        = bool
  default     = false
  description = "(Optional) Whether the outputs of `stdout` and `stderr` should be marked as sensitive."
}
