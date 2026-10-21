mock_provider "google" {}

run "prod_configuration_validation" {
  command = plan

  variables {
    project_id                    = "unit-test-project"
    region                        = "us-central1"
    image                         = "us-central1-docker.pkg.dev/unit-test-project/apps/app:0123456789012345678901234567890123456789"
    runtime_service_account_email = "runtime@unit-test-project.iam.gserviceaccount.com"
  }

  assert {
    condition     = module.service.service_name == "delivery-demo-prod"
    error_message = "The prod service name must be delivery-demo-prod."
  }

  assert {
    condition     = var.region == "us-central1"
    error_message = "Default region must be us-central1."
  }

  assert {
    condition     = var.memory == "1Gi"
    error_message = "Production environment must default to 1Gi memory."
  }
}
