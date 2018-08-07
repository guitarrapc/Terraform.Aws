variable "environment" {
  default = "production"
}

variable common_tags {
  type = "map"

  default {
    is_terraform = "true"
  }
}

variable "project_code" {
  type    = "string"
  default = "my_project_name"
}

variable "cidr" {
  type = "map"

  default = {
    ap-northeast-1 = "10.0.0.0/16"
    us-west-2      = "10.1.0.0/16"
    us-east-1      = "10.2.0.0/16"
  }
}

variable "fixed_ipv4" {
  type = "map"

  default = {
    all    = "0.0.0.0/0"
    office = "xx.xx.xx.xx/32"
  }
}
