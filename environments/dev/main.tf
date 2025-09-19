locals {
  common_tags = {
    "ManagedBy"   = "Terraform"
    "Owner"       = "TodoAppTeam"
    "Environment" = "dev"
  }
}

module "rg" {
  source      = "../../modules/azurerm_resource_group"
  rg_name     = "rg-dev-todoapp-03"
  rg_location = "West US"
  rg_tags     = local.common_tags
}

module "acr" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_container_registry"
  acr_name   = "acrrahul2"
  rg_name    = "rg-dev-todoapp-03"
  location   = "West US"
  tags       = local.common_tags
}

module "sql_server" {
  depends_on      = [module.rg]
  source          = "../../modules/azurerm_sql_server"
  sql_server_name = "sql-dev-todoapp-03"
  rg_name         = "rg-dev-todoapp-03"
  location        = "West US"
  admin_username  = "devopsadmin"
  admin_password  = "P@ssw01rd@123"
  tags            = local.common_tags
}

module "sql_db" {
  depends_on  = [module.sql_server]
  source      = "../../modules/azurerm_sql_database"
  sql_db_name = "sqldb-dev-todoapp2"
  server_id   = module.sql_server.server_id
  max_size_gb = "2"
  tags        = local.common_tags
}

module "aks" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_kubernetes_cluster"
  aks_name   = "aks-dev-todoapp2"
  location   = "West US"
  rg_name    = "rg-dev-todoapp-03"
  dns_prefix = "aks-dev-todoapp"
  tags       = local.common_tags
  node_count = 1
  vm_size = "Standard_B2s"
}


module "pip" {
  depends_on = [module.rg ]
  source   = "../../modules/azurerm_public_ip"
  pip_name = "pip-dev-todoapp2"
  rg_name  = "rg-dev-todoapp-03"
  location = "West US"
  sku      = "Standard"
  tags     = local.common_tags
}
