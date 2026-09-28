locals {
  common  = yamldecode(file("../common.yml"))
  appname = "aks"

  # Additional User Assigned Identities, looped through by module.uai in
  # main.tf. Keyed by a short suffix appended to the uai-<loc>-<uid>-<appname>-
  # name. Add one entry per identity needed, e.g.:
  # some-app = {
  #   federated_identity_credentials = {
  #     app = {
  #       issuer   = module.aks.oidc_issuer_url
  #       subject  = "system:serviceaccount:<namespace>:<service-account>"
  #       audience = ["api://AzureADTokenExchange"]
  #       name     = "app"
  #     }
  #   }
  #   role_assignments = {
  #     acr_pull = {
  #       scope                            = data.azurerm_container_registry.acr.id
  #       role_definition_name             = "AcrPull"
  #       skip_service_principal_aad_check = false
  #     }
  #   }
  # }
  workload_uais = {}
  # workload_uais = {
  #   argocd = {
  #     federated_identity_credentials = {
  #       argocd = {
  #         issuer   = module.aks.oidc_issuer_url
  #         subject  = "system:serviceaccount:argocd:argocd-application-controller"
  #         audience = ["api://AzureADTokenExchange"]
  #         name     = "argocd"
  #       }
  #     }
  #     role_assignments = {
  #       acr_pull = {
  #         scope                            = data.azurerm_container_registry.acr.id
  #         role_definition_name             = "AcrPull"
  #         skip_service_principal_aad_check = false
  #       }
  #     }
  #   }
  # }
}