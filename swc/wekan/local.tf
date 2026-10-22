locals {
  common  = yamldecode(file("../common.yml"))
  appname = "wekan"

  mongo_administrator_username = "wekanadmin"

  # Cosmos DB for MongoDB vCore only publishes SRV strings with <user> and
  # <password> placeholders, and Wekan needs the database in the path, so the
  # usable MONGO_URL is assembled here. retrywrites=false is required: Cosmos
  # rejects retryable writes and Meteor would fail every insert without it.
  mongo_url = format(
    "mongodb+srv://%s:%s@%s.mongocluster.cosmos.azure.com/%s?tls=true&authMechanism=SCRAM-SHA-256&retrywrites=false&maxIdleTimeMS=120000",
    local.mongo_administrator_username,
    # urlencode escapes everything userinfo needs, but renders a space as "+",
    # which a URI userinfo field reads literally rather than as a space.
    replace(urlencode(data.azurerm_key_vault_secret.mongo_administrator_password.value), "+", "%20"),
    module.mongo_cluster.name,
    local.appname,
  )
}
