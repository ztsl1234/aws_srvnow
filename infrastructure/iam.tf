# 1. Create a managed policy in your current project workspace
resource "aws_iam_policy" "runner_s3_data_policy" {
  name        = "DataPlatformRunnerS3Access"
  description = "Grants localized S3 bucket data-plane privileges to the external runner user"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDataIngestionFromLocalTerminal"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::sn-raw-data-tsl-dev",
          "arn:aws:s3:::sn-raw-data-tsl-dev/*",
          "arn:aws:s3:::sn-meta-data-tsl-dev",
          "arn:aws:s3:::sn-meta-data-tsl-dev/*"
        ]
      }
    ]
  })
}

# 2. Attach it to the external user by string name
resource "aws_iam_user_policy_attachment" "external_runner_attach" {
  user       = "terraform-runner1" # Hardcoded string targets the external entity directly
  policy_arn = aws_iam_policy.runner_s3_data_policy.arn
}