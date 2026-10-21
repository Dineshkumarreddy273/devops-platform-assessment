variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
  nullable    = false
}

variable "region" {
  description = "Cloud Run region."
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Cloud Run service name."
  type        = string
}

variable "environment" {
  description = "Environment label."
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "image" {
  description = "Immutable container image reference; prefer digest over mutable tags."
  type        = string
  validation {
    condition     = can(regex("@sha256:[a-f0-9]{64}$", var.image)) || can(regex(":[a-f0-9]{40}$", var.image))
    error_message = "Use an image digest or a commit-SHA tag; mutable tags such as latest are not accepted."
  }
}

variable "runtime_service_account_email" {
  description = "Dedicated runtime service account email."
  type        = string
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
  validation {
    condition     = var.timeout_seconds >= 1 && var.timeout_seconds <= 3600
    error_message = "timeout_seconds must be between 1 and 3600."
  }
}

variable "concurrency" {
  type    = number
  default = 80
  validation {
    condition     = var.concurrency >= 1 && var.concurrency <= 1000
    error_message = "concurrency must be between 1 and 1000."
  }
}

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 5
  validation {
    condition     = var.max_instances >= 1
    error_message = "max_instances must be at least 1."
  }
}

variable "ingress" {
  description = "Cloud Run v2 ingress enum: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, or INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
  validation {
    condition     = contains(["INGRESS_TRAFFIC_ALL", "INGRESS_TRAFFIC_INTERNAL_ONLY", "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"], var.ingress)
    error_message = "Unsupported Cloud Run v2 ingress enum."
  }
}

variable "allow_unauthenticated" {
  description = "Whether to grant invoker to allUsers. For public production traffic, prefer the load-balancer design and review this explicitly."
  type        = bool
  default     = false
}

variable "labels" {
  type    = map(string)
  default = {}
}
