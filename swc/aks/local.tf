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
  workload_uais = {
    # AKS nodes use this identity to pull images - separate from any pod's own
    # workload identity, which only authenticates in-pod app code. Referenced
    # directly by module.aks (kubelet_identity) and by control_plane_identity's
    # kubelet_identity_operator role assignment in main.tf.
    kubelet = {
      federated_identity_credentials = {}
      role_assignments = {
        acr_pull = {
          scope                            = data.azurerm_container_registry.acr.id
          role_definition_name             = "AcrPull"
          skip_service_principal_aad_check = true
        }
      }
    }
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