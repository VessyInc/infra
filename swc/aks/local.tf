locals {
  common  = yamldecode(file("../common.yml"))
  appname = "aks"

  workload_uais = {
    argocd = {
      federated_identity_credentials = {
        argocd-application-controller = {
          issuer   = module.aks.oidc_issuer_url
          subject  = "system:serviceaccount:argocd:argocd-application-controller"
          audience = ["api://AzureADTokenExchange"]
          name     = "argocd-application-controller"
        }
        argocd-server = {
          issuer   = module.aks.oidc_issuer_url
          subject  = "system:serviceaccount:argocd:argocd-server"
          audience = ["api://AzureADTokenExchange"]
          name     = "argocd-server"
        }
      }
      role_assignments = {
        acr_pull = {
          scope                            = data.azurerm_container_registry.acr.id
          role_definition_name             = "AcrPull"
          skip_service_principal_aad_check = false
        }
      }
    }
  }
}