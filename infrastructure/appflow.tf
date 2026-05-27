# 1. IAM Role allowing AppFlow to write objects to your Raw S3 Bucket
resource "aws_iam_role" "appflow_s3_delivery" {
  name = "appflow-s3-delivery-role-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "appflow.amazonaws.com" }
      }
    ]
  })
}

# 2. Policy granting AppFlow permission to put data in the Raw landing zone
resource "aws_iam_role_policy" "appflow_s3_write_policy" {
  name = "appflow-s3-write-policy"
  role = aws_iam_role.appflow_s3_delivery.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::sn-raw-data-tsl-dev",
          "arn:aws:s3:::sn-raw-data-tsl-dev/*"
        ]
      }
    ]
  })
}

# 3. AppFlow Flow for sc_req_item (Requested Items)
resource "aws_appflow_flow" "servicenow_req_item_flow" {
  name        = "servicenow-sc-req-item-ingestion-dev"
  description = "Ingests raw onboarding requested items from ServiceNow to S3 Raw landing"

  # Trigger type can be Scheduled, OnDemand, or Event
  trigger_config {
    trigger_type = "Scheduled"
    
    trigger_properties {
      scheduled_properties {
        schedule_expression = "rate(1 day)" # Scheduled daily batch window
        data_pull_mode     = "Incremental" # Pulls only modified records
        start_time         = "2026-05-28T00:00:00Z"
      }
    }
  }

  source_flow_config {
    connector_type = "Servicenow"
    
    # Assumes you created the connector profile authentication via Console/Secrets Manager
    connector_profile_name = "production-servicenow-connection"

    source_connector_properties {
      servicenow {
        object = "sc_req_item" # Target ServiceNow table name
      }
    }
  }

  destination_flow_config {
    connector_type = "S3"

    s3_destination_properties {
      bucket_name   = "sn-raw-data-tsl-dev"
      bucket_prefix = "servicenow_sc_req_item"

      s3_output_format_config {
        file_type = "JSON" # Keeps nested structure intact for the Bronze Glue Job
        
        aggregation_config {
          aggregation_type = "None" # Outputs single files per transfer window
        }
      }
    }
  }

  # Map core fields explicitly. Use task.source_fields to pass fields downstream
  task {
    source_fields = ["sys_id", "number", "cat_item", "requested_for", "u_department", "u_location", "state", "sys_created_on", "sys_updated_on"]
    task_type     = "Map_All" # Maps source fields 1:1 to destination properties
    
    task_properties = {
      EXCLUDE_SOURCE_FIELDS_LIST = ""
    }
  }
}