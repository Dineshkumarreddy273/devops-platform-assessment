mock_provider "google" {}

run "dev_configuration_validation" {
  command = plan

  variables {
    project_id                    = "unit-test-project"
    region                        = "us-central1"
    image                         = "us-central1-docker.pkg.dev/unit-test-project/apps/app:0123456789012345678901234567890123456789"
    runtime_service_account_email = "runtime@unit-test-project.iam.gserviceaccount.com"
  }

  assert {
    condition     = module.service.service_name == "delivery-demo-dev"
    error_message = "The dev service name should be delivery-demo-dev."
  }

  assert {
    condition     = var.region == "us-central1"
    error_message = "Default region must be us-central1."
  }

  assert {
    condition     = var.memory == "512Mi"
    error_message = "Dev environment must default to 512Mi memory."
  }
}