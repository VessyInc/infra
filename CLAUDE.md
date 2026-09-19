# infra

Terraform for Vessy's Azure environment. Stacks live under `<location_shortcode>/<stack>/`
(currently `swc/` = Sweden Central), e.g. `swc/networking`, `swc/tfstate_storage`, `swc/aks`.

## Conventions

Each stack folder follows the same shape:

- `provider.tf` — `terraform` block (`required_version`, `required_providers`, `backend "azurerm"`)
  plus the `provider "azurerm"` block. Backend uses OIDC (`use_oidc = true`,
  `use_azuread_auth = true`) against the storage account provisioned in `swc/tfstate_storage`,
  with a container named after the stack and key `<stack>.tfstate`.
- `local.tf` — a `locals` block that loads `../common.yml` via `yamldecode(file(...))` into
  `local.common` (gives `location`, `location_shortcode`, `uniqueidentifier`) and sets
  `appname` for that stack.
- `main.tf` — the actual resources, built exclusively from modules.

Resource naming is always built from locals, following Azure CAF-ish prefixes, e.g.:

```
name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
name = substr("st${local.common.location_shortcode}${local.common.uniqueidentifier}${local.appname}", 0, 24)
```

## Modules — always use github.com/VessyInc/modules

Every Azure resource is created via a module from `github.com/VessyInc/modules`, never inline
`resource` blocks. Source references look like:

```
source = "github.com/VessyInc/modules//azurerm-<resource-name>?ref=vX.Y.Z"
```

Module names map 1:1 to Azure resource types, e.g. `azurerm-resource-group`,
`azurerm-storage-account`, `azurerm-virtual-network`, `azurerm-kubernetes-cluster`,
`azurerm-key-vault`. Browse `github.com/VessyInc/modules` (via `gh api repos/VessyInc/modules/contents/`
or `gh repo view`/clone) to confirm the exact module name and the current latest tag before
pinning `?ref=`.

**When asked to write a new Azure resource:**

1. Find the matching module in `github.com/VessyInc/modules` and read its `variables.tf` and
   `outputs.tf` to know what inputs are required/available and what it exposes.
2. **Do not read or copy from that module's own `example/` folder.** It's generic, not written
   in this repo's style.
3. Instead, look at how sibling stacks in *this* repo already consume modules — start with
   `swc/tfstate_storage/main.tf` (resource group + storage account, incl. `role_assignments`,
   `network_rules`, `containers` map usage) and any other populated `main.tf` in `swc/*`. Match
   their formatting, naming pattern, tagging, and how optional blocks/maps are structured.
4. Wire the new resource into the target stack's existing `local.tf`/`provider.tf` pattern
   (reuse `local.common` + `local.appname`, don't invent a new naming scheme).

If no other stack in this repo yet uses a given module, fall back to the module's `variables.tf`
for required inputs, but still follow this repo's naming/locals/tagging conventions rather than
the module's example defaults.
