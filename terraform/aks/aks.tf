module "aks" {
  source = "./modules/aks"

  name                = "aks${var.identifier}"
  resource_group_name = module.rg.name
  dns_prefix          = "some-lab"

  default_pool_name = "default"

  user_assigned_identity_id = azurerm_user_assigned_identity.main.id

  enable_azure_active_directory   = true
  rbac_aad_managed                = true
  rbac_aad_admin_group_object_ids = [azuread_group.k8sadmins.object_id]

  private_dns_zone_id = azurerm_private_dns_zone.main.id

  node_resource_group = "aks-${var.identifier}-example"

  private_cluster_enabled = true

  availability_zones   = ["1", "2", "3"]
  enable_auto_scaling  = true
  max_pods             = 100
  orchestrator_version = "1.26.10"
  vnet_subnet_id       = module.subnet.id
  max_count            = 3
  min_count            = 1
  node_count           = 1

  enable_log_analytics_workspace = true

  network_plugin = "azure"
  network_policy = "calico"

  kubernetes_version = "1.26.10"

  only_critical_addons_enabled = true

  node_pools = [
    {
      name                 = "generic-apps"
      availability_zones   = ["1", "2", "3"]
      enable_auto_scaling  = true
      max_pods             = 100
      orchestrator_version = "1.26.10"
      priority             = "Regular"
      max_count            = 2
      min_count            = 1
      node_count           = 1
    },
    {
      name                 = "generic-spot"
      max_pods             = 100
      orchestrator_version = "1.26.10"
      priority             = "Spot"
      eviction_policy      = "Delete"
      spot_max_price       = 0.5 # note: this is the "maximum" price
      node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot"
      }
      node_taints = [
        "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
      ]
      node_count = 1
    }
  ]

  tags = {
    "ManagedBy" = "Terraform"
  }

  depends_on = [
    module.rg,
    module.subnet,
    azurerm_role_assignment.dns,
    azurerm_role_assignment.network
  ]
}