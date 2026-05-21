variable "aws_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "Target deployment region"
}

variable "environment" {
  type        = string
  description = "Deployment environment namespace (dev, prod)"
}