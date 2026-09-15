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

  assert {
    condition     = terraform_data.gate.input.service_type == "LoadBalancer"
    error_message = "environment=dev0 HTTP must keep Service type LoadBalancer"
  }

  assert {
    condition     = terraform_data.gate.input.load_balancer_ip == "192.0.2.10"
    error_message = "environment=dev0 HTTP must set a fixture load_balancer_ip (TEST-NET-1)"
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

# Fixture only: reserved example.test hostname, no ACME account, no Azure.
# command = plan — never apply. Catches enable_tls=true regressions (PR #11).
run "prod_tls_enabled_plans" {
  command = plan
  variables {
    environment = "prod"
    enable_tls  = true
    hostname    = "ci.example.test"
  }

  assert {
    condition     = terraform_data.gate.input.is_prod == true
    error_message = "environment=prod must be treated as prod"
  }

  assert {
    condition     = terraform_data.gate.input.tls_enabled == true
    error_message = "prod + enable_tls + hostname must set tls_enabled"
  }

  assert {
    condition     = terraform_data.gate.input.service_type == "ClusterIP"
    error_message = "TLS-on Service type must be ClusterIP (nginx owns the PIP)"
  }

  assert {
    condition     = terraform_data.gate.input.load_balancer_ip == null
    error_message = "TLS-on load_balancer_ip must be null (not empty string)"
  }
}

run "dev0_tls_enabled_plans" {
  command = plan
  variables {
    environment = "dev0"
    enable_tls  = true
    hostname    = "ci.example.test"
  }

  assert {
    condition     = terraform_data.gate.input.is_prod == false
    error_message = "environment=dev0 must not be treated as prod even with TLS"
  }

  assert {
    condition     = terraform_data.gate.input.tls_enabled == true
    error_message = "dev0 + enable_tls + hostname must set tls_enabled"
  }

  assert {
    condition     = terraform_data.gate.input.load_balancer_ip == null
    error_message = "TLS-on load_balancer_ip must be null on non-prod too"
  }
}
