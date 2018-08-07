provider "aws" {
  version = "~> 1.24"
  region  = "us-west-1"
  profile = "aws-my-terraform-profile"
}

// any modules
# module "module_name" {
#  source = "path_to_the_module"
# }

