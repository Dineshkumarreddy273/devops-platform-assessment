
variable "project_id" {
  type        = string
  description = "GCP project ID. Supply via TF_VAR_project_id or a local tfvars file excluded from git."
  default     = "empirical-radio-340813"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "image" {
  type        = string
  description = "Use a commit-SHA tag or digest."
  default     = "us-central1-docker.pkg.dev/empirical-radio-340813/optum-repo/flask-app:latest"
}

variable "runtime_service_account_email" {
  type        = string
  description = "Dedicated service account for Cloud Run runtime."
  default     = "empirical-radio-340813-compute@developer.gserviceaccount.com"
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "512Mi"
}

variable "timeout_seconds" {
  type    = number
  default = 60
}

variable "concurrency" {
  type    = number
  default = 80
}
