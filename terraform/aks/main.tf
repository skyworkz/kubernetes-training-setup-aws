module "rg" {
  source = "./modules/resource_group"

  name     = "${var.identifier}-example"
  location = var.location
}