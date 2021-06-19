variable "depends" {
  description = "Equivalent to the `depends_on` input for a data/resource."
  default = []
}

variable "command" {
  description = "The command to run on creation when the module is used on a Unix machine."
  default = ":"
}
variable "command_windows" {
  description = "(Optional) The command to run on creation when the module is used on a Windows machine. If not specified, will default to be the same as the `command` variable."
  default = ""
}

variable "command_when_destroy" {
  description = "The command to run on destruction when the module is used on a Unix machine."
  default = ":"
}
variable "command_when_destroy_windows" {
  description = "(Optional) The command to run on destruction when the module is used on a Windows machine. If not specified, will default to be the same as the `command_when_destroy` variable."
  default = ""
}

# warning! the outputs are not updated even if the trigger re-runs the command!
variable "trigger" {
  description = "When any of these values change, re-run the script (will first run the destroy command if this module already exists in the state)."
  default = ""
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "(Optional) Map of environment variables to pass to the command"
}

variable "sensitive_environment" {
  type        = map(string)
  default     = {}
  description = "(Optional) Map of (sentitive) environment variables to pass to the command"
}

variable "working_dir" {
  type        = string
  default     = ""
  description = "(Optional) the working directory where command will be executed"
}
