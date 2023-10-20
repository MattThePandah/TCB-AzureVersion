# Creation of a Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name = "luxxyContainerRegistry"
  resource_group_name = var.az_resource_group_name
  location = var.az_location
  sku = "Premium"
}

# Lines to create a Cloud SQL instance and database
resource "azurerm_mysql_server" "server" {
  name = "luxxy-covid-testing-system-database-en"
  resource_group_name = var.az_resource_group_name
  location = var.az_location
  version = "5.7"
  sku_name = "B_Gen5_2"
  ssl_enforcement_enabled = true
}

resource "azurerm_mysql_database" "database" {
  name              = "dbcovidtesting"
  resource_group_name = var.az_resource_group_name
  server_name = azurerm_mysql_server.server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

#Creation of firewall rule to allow local ip
resource "azurerm_mysql_firewall_rule" "allowlocal" {
  name = "allow-local"
  resource_group_name = var.az_resource_group_name
  server_name = azurerm_mysql_server.server.name
  start_ip_address = var.public_ip_address
  end_ip_address = var.public_ip_address
}

# Lines to create a Managed Identity (Azure)
resource "azurerm_user_assigned_identity" "identity" {
  name = "luxxyManagedIdentity"
  resource_group_name = var.az_resource_group_name
  location = var.az_location
}

# Lines to create a Azure Kubernates Service (AKS)

resource "azurerm_kubernetes_cluster" "primary" {
  name = "luxxy-kubernetes-cluster-en"
  location = var.az_location
  resource_group_name = var.az_resource_group_name
  dns_prefix = "luxxy"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_role_assignment" "example" {
  principal_id = azurerm_kubernetes_cluster.primary.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# resource "google_container_cluster" "primary" {
#   name               = "luxxy-kubernetes-cluster-en"
#   location           = var.gcp_region
#   initial_node_count = 1
#   ip_allocation_policy {
#   }
#   enable_autopilot = true
#   node_config {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#     labels = {
#       environment = "training"
#     }
#     tags = ["environment", "training"]
#   }
#   timeouts {
#     create = "30m"
#     update = "40m"
#   }
# }