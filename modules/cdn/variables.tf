variable "domain" {}

variable "certdomain" {
  default = ""
}

variable "mx_hosts" {
  type    = "list"
  default = []
}

variable "login_origin" {}
variable "source_origin" {}
variable "web_origin" {}
variable "processed_origin" {}
