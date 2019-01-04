variable "depends_id" {
  default = ""
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
