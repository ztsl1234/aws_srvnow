

aws s3 cp dist/shared_utils-1.0-py3-none-any.whl s3://sn-meta-data-tsl/libraries/

aws s3api get-object \
    --bucket sn-raw-data-tsl-dev \
    --key servicenow/year=2026/month=05/sample_incident.json \
    /dev/stdout

aws sts get-caller-identity