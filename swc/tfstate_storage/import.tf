import {
  to = module.resource_group.azurerm_resource_group.this
  id = "/subscriptions/7d1c5864-c4b6-4404-be9e-4b7a353996ff/resourceGroups/rg-swc-vessyinc-tfstate"
}

import {
  to = module.storage_account.azurerm_storage_account.this
  id = "/subscriptions/7d1c5864-c4b6-4404-be9e-4b7a353996ff/resourceGroups/rg-swc-vessyinc-tfstate/providers/Microsoft.Storage/storageAccounts/stswcvessyinctfstate"
}

import {
  to = module.storage_account.azurerm_role_assignment.this["storage_blob_data_owner"]
  id = "/subscriptions/7d1c5864-c4b6-4404-be9e-4b7a353996ff/resourceGroups/rg-swc-vessyinc-tfstate/providers/Microsoft.Storage/storageAccounts/stswcvessyinctfstate/providers/Microsoft.Authorization/roleAssignments/82f03b0b-27a5-4b2e-b5fa-a5c29559a360"
}

import {
  to = module.storage_account.module.storage_containers["tfstate-storage"].azurerm_storage_container.this
  id = "/subscriptions/7d1c5864-c4b6-4404-be9e-4b7a353996ff/resourceGroups/rg-swc-vessyinc-tfstate/providers/Microsoft.Storage/storageAccounts/stswcvessyinctfstate/blobServices/default/containers/tfstate-storage"
}