resource "aws_glue_job" "sn_ingestion" {
  name     = "ServiceNow_Flatten_Pipeline"
  role_arn = aws_iam_role.glue_role.arn
  glue_version = "4.0"

  command {
    script_location = "s3://your-meta-bucket/scripts/main_job.py"
  }

  default_arguments = {
    "--extra-py-files" = "s3://your-meta-bucket/libraries/spark_utils.py"
    "--CONFIG_PATH"    = "s3://your-meta-bucket/configs/sn_pipeline_config.json"
    "--job-bookmark-option" = "job-bookmark-enable"
  }
}