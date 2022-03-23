variable "vpc_cidr" {
  type    = string
  default = "10.15.0.0/16"
}

variable "public_sub_cidr" {
  type    = list(string)
  default = ["10.15.1.0/24", "10.15.2.0/24"]
}

variable "private_sub_cidr" {
  type    = list(string)
  default = ["10.15.3.0/24", "10.15.4.0/24"]
}

variable "az" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b"]
}

variable "public_sb_count" {
  type    = number
  default = 2
}

variable "private_sb_count" {
  type    = number
  default = 2
}

variable "tg_count" {
  type    = number
  default = 2
}


variable "containers_name" {
  type    = list(string)
  default = ["service1", "service2"]
}
