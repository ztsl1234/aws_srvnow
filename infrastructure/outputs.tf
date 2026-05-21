output "raw_bucket_arn" {
  value       = aws_s3_bucket.raw_bucket.arn
  description = "Target Storage ARN mapping descriptor"
}

output "ingestion_job_name" {
  value       = aws_glue_job.servicenow_ingestion.name
  description = "Core Ingestion pipeline identity string"
}