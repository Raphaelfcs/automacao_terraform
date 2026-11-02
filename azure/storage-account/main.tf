# Storage Account seguro: TLS 1.2, sem acesso público a blobs, sem chave compartilhada
# (Entra ID), cifra com chave do cliente (CMK) no Key Vault via identidade gerenciada,
# soft delete de blobs/containers, versionamento e containers privados.
# Substitui o antigo "local-exec az storage account update" por recursos nativos.

resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"
  is_hns_enabled           = var.hierarchical_namespace

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = var.public_network_access

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage.id]
  }

  dynamic "customer_managed_key" {
    for_each = var.cmk_key_vault_key_id == null ? [] : [1]
    content {
      key_vault_key_id          = var.cmk_key_vault_key_id
      user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
    }
  }

  blob_properties {
    versioning_enabled = var.versioning

    delete_retention_policy {
      days = var.soft_delete_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_days
    }
  }

  network_rules {
    default_action             = var.public_network_access ? "Allow" : "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

resource "azurerm_storage_container" "this" {
  for_each = toset(var.containers)

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
