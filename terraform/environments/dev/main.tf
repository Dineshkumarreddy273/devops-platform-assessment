module "service" {
  source = "../../modules/cloud_run"

  project_id                    = var.project_id
  region                        = var.region
  service_name                  = "delivery-demo-dev"
  environment                   = "dev"
  image                         = var.image
  runtime_service_account_email = var.runtime_service_account_email
  cpu                           = var.cpu
  memory                        = var.memory
  timeout_seconds               = var.timeout_seconds
  concurrency                   = var.concurrency
  min_instances                 = 0
  max_instances                 = 3
  ingress                       = "INGRESS_TRAFFIC_ALL"
  allow_unauthenticated         = true

  labels = {
    app        = "delivery-demo"
    managed_by = "terraform"
  }
}
