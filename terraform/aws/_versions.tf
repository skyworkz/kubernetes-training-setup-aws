terraform {
  required_version = ">= 0.13.1"

  # backend "s3" {
  #   bucket = "skyworkz-tf-state-k8s-training"
  #   key    = "terraform.tfstate"
  #   region = "eu-west-1"
  # }


  required_providers {
    aws        = ">= 5.24.0"
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = ">= 2.6"
  }
}
