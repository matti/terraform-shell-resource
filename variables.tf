variable "depends_id" {
  default = ""
}

variable "command" {
  default = ":"
}

variable "command_when_destroy" {
  default = ":"
}

variable "triggers" {
  default = {
    command              = true
    command_when_destroy = true
  }
}
