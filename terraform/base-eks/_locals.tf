locals {
  name            = "skyworkz-k8s-training-${random_string.suffix.result}"
  cluster_version = "1.27"
  region          = "eu-west-1"
}