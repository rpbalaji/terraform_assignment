variable "albname" {
  type = string
}

variable "albsg" {
  type = list(string)
}

variable "alb_subnet" {
  type = list
}

#has to be set true if it is an internal alb
variable "albtype" {
  type = bool
}