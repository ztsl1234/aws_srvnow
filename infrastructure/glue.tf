resource "aws_iam_role" "glue_execution" {
  name = "glue-pipeline-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "glue.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy" "glue_s3_access" {
  name        = "glue-s3-access-policy-${var.environment}"
  description = "Provides read, write and execution access across target data layers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::sn-raw-data-tsl-${var.environment}",
          "arn:aws:s3:::sn-raw-data-tsl-${var.environment}/*",
          "arn:aws:s3:::sn-bronze-data-tsl-${var.environment}",
          "arn:aws:s3:::sn-bronze-data-tsl-${var.environment}/*",
          "arn:aws:s3:::sn-meta-data-tsl-${var.environment}",
          "arn:aws:s3:::sn-meta-data-tsl-${var.environment}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*glue*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3_attach" {
  role       = aws_iam_role.glue_execution.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

resource "aws_iam_role_policy_attachment" "glue_service_attach" {
  role       = aws_iam_role.glue_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_job" "servicenow_ingestion" {
  name              = "servicenow-ingestion-${var.environment}"
  role_arn          = aws_iam_role.glue_execution.arn
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 60

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.meta_bucket.id}/scripts/servicenow_ingestion.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--continuous-log-logGroup"          = "/aws-glue/jobs/data-platform-${var.environment}"
    "--enable-continuous-cloudwatch-log" = "true"
    "--extra-py-files"                   = "s3://sn-meta-data-tsl-${var.environment}/libraries/shared_utils-1.0.0-py3-none-any.whl"
    "--ENV"                              = var.environment
  }
}

resource "aws_glue_job" "data_quality_check" {
  name              = "data-quality-check-${var.environment}"
  role_arn          = aws_iam_role.glue_execution.arn
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 30

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.meta_bucket.id}/scripts/data_quality_check.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--continuous-log-logGroup"          = "/aws-glue/jobs/data-platform-dq-${var.environment}"
    "--enable-continuous-cloudwatch-log" = "true"
    "--extra-py-files"                   = "s3://sn-meta-data-tsl-${var.environment}/libraries/shared_utils-1.0.0-py3-none-any.whl"
    "--ENV"                              = var.environment
  }
}