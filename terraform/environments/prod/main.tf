module "service" {
  source = "../../modules/cloud_run"

  project_id                    = var.project_id
  region                        = var.region
  service_name                  = "delivery-demo-prod"
  environment                   = "prod"
  image                         = var.image
  runtime_service_account_email = var.runtime_service_account_email
  cpu                           = var.cpu
  memory                        = var.memory
  timeout_seconds               = var.timeout_seconds
  concurrency                   = var.concurrency
  min_instances                 = 1
  max_instances                 = 10
  ingress                       = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  allow_unauthenticated         = false

  labels = {
    app        = "delivery-demo"
    managed_by = "terraform"
  }
}
