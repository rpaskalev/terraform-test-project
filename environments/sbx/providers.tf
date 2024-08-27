provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "Terraform-Final-Project"
      Team    = "Code-Killers"
      Class   = "026DO"
    }
  }
}

# terraform {
#   backend "s3" {
#     bucket  = "terraform-state-file-code-killers"
#     key     = "terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#     # dynamodb_table = "terraform-state-lock"
#   }
# }