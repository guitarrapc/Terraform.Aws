locals {
  common_tags {
    environment = "production"
  }
}

locals {
  region = "us-west-1"
}

locals {
  route53_ttl {
    a     = 300
    cname = 300
    mx    = 3600
    ns    = 172800
    txt   = 3600
    test  = 60
  }
}
