data "terraform_remote_state" "us-east-1" {
  backend = "s3"

  config {
    bucket  = "my-terraform-state"
    key     = "aws/ap-northeast-1/terraform.tfstate"
    region  = "us-east-1"
    profile = "aws-my-terraform-profile"
  }
}

data "terraform_remote_state" "ap-northeast-1" {
  backend = "s3"

  config {
    bucket  = "my-terraform-state"
    key     = "aws/ap-northeast-1/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "aws-my-terraform-profile"
  }
}
