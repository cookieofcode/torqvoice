run "dev0_http_allowed" {
  command = plan
  variables {
    environment = "dev0"
    enable_tls  = false
    hostname    = ""
  }

  assert {
    condition     = terraform_data.gate.input.is_prod == false
    error_message = "environment=dev0 must not be treated as prod"
  }

  assert {
    condition     = terraform_data.gate.input.tls_enabled == false
    error_message = "environment=dev0 HTTP should leave tls_enabled false"
  }

  assert {
    condition     = terraform_data.gate.input.tags_env == "dev0"
    error_message = "force-merged tags.environment must be dev0"
  }
}

run "prod_http_rejected" {
  command = plan
  variables {
    environment = "prod"
    enable_tls  = false
    hostname    = ""
  }
  expect_failures = [
    var.environment,
  ]
}

run "stale_prod_tag_does_not_trip_gate" {
  command = plan
  variables {
    environment = "dev0"
    enable_tls  = false
    hostname    = ""
    tags = {
      app         = "torqvoice"
      environment = "prod"
      managed-by  = "terraform"
    }
  }

  assert {
    condition     = terraform_data.gate.input.is_prod == false
    error_message = "stale tags.environment=prod must not set is_prod"
  }

  assert {
    condition     = terraform_data.gate.input.tags_env == "dev0"
    error_message = "force-merge must overwrite tags.environment to var.environment"
  }
}
