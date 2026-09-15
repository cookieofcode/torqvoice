locals {
  postgres_server_name = trimspace(var.postgres_server_name) != "" ? var.postgres_server_name : "psql-torqvoice-${random_string.unique.result}"

  better_auth_secret = trimspace(var.better_auth_secret) != "" ? var.better_auth_secret : random_password.better_auth.result

  database_url = format(
    "postgresql://%s:%s@%s:5432/%s?sslmode=require",
    var.postgres_administrator_login,
    urlencode(random_password.postgres.result),
    azurerm_postgresql_flexible_server.this.fqdn,
    var.postgres_database_name,
  )

  app_url = trimspace(var.app_url) != "" ? var.app_url : "http://${azurerm_public_ip.app.ip_address}"

  k8s_labels = {
    app     = "torqvoice"
    part-of = "torqvoice"
  }
}
