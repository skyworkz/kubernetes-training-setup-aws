locals {
  name            = "skyworkz-k8s-training-${random_string.suffix.result}"
  cluster_version = "1.28"
  region          = "eu-west-1"
}