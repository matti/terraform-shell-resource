variable "depends" {
  default = []
}

variable "command" {
  default = ":"
}

variable "command_when_destroy" {
  default = ":"
}

# warning! the outputs are not updated even if the trigger re-runs the command!
variable "trigger" {
  default = ""
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "(Optional) Map of environment variables to pass to the command"
}

variable "working_dir" {
  type        = string
  default     = ""
  description = "(Optional) the working directory where command will be executed"
}
