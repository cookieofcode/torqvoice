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

  assert {
    condition     = terraform_data.gate.input.viewer_count == 0
    error_message = "default aks_viewer_user_object_ids must plan as an empty viewer set"
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

# aks_viewer_user_object_ids (PR #10). Fixture UUIDs only — not real Entra IDs.
# Same enable_tls=true path as above; command = plan, never apply.
run "viewer_one_fixture_id" {
  command = plan
  variables {
    environment                = "prod"
    enable_tls                 = true
    hostname                   = "ci.example.test"
    aks_admin_user_object_ids  = ["00000000-0000-0000-0000-0000000000a1"]
    aks_viewer_user_object_ids = ["00000000-0000-0000-0000-0000000000b2"]
  }

  assert {
    condition     = terraform_data.gate.input.tls_enabled == true
    error_message = "viewer fixture must still plan with enable_tls=true"
  }

  assert {
    condition     = terraform_data.gate.input.viewer_count == 1
    error_message = "one non-overlapping fixture viewer ID must be assigned"
  }

  assert {
    condition     = terraform_data.gate.input.viewer_ids == "00000000-0000-0000-0000-0000000000b2"
    error_message = "viewer set must be exactly the one fixture GUID"
  }
}

run "viewer_skipped_when_admin" {
  command = plan
  variables {
    environment                = "prod"
    enable_tls                 = true
    hostname                   = "ci.example.test"
    aks_admin_user_object_ids  = ["00000000-0000-0000-0000-0000000000a1"]
    aks_viewer_user_object_ids = ["00000000-0000-0000-0000-0000000000a1"]
  }

  assert {
    condition     = terraform_data.gate.input.tls_enabled == true
    error_message = "admin-overlap fixture must still plan with enable_tls=true"
  }

  assert {
    condition     = terraform_data.gate.input.viewer_count == 0
    error_message = "viewer ID that overlaps aks_admin_user_object_ids must be skipped"
  }
}

run "viewer_skipped_when_apply_principal" {
  command = plan
  variables {
    environment                = "prod"
    enable_tls                 = true
    hostname                   = "ci.example.test"
    aks_viewer_user_object_ids = ["00000000-0000-0000-0000-0000000000c3"]
  }

  assert {
    condition     = terraform_data.gate.input.viewer_count == 0
    error_message = "viewer ID that overlaps the apply-principal fixture must be skipped"
  }
}
