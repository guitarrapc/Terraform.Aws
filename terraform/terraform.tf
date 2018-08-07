terraform {
  required_version = "> 0.11.0"

  backend "s3" {
    bucket  = "my-terraform-state"
    key     = "aws/global.terraform.tfstate"
    region  = "us-east-1"
    profile = "aws-my-terraform-profile"
  }
}
