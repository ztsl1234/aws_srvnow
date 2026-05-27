#!/bin/bash
# Enterprise compilation script to handle python bundling and S3 syncing
set -e

ENV=${1:-dev}
BUCKET_NAME="sn-meta-data-tsl-${ENV}"

echo "======================================================="
echo "Starting Build & Artifact Deployment Process [ENV: ${ENV}]"
echo "======================================================="

# 1. Compile the Shared Utilities Package safely inside an isolated venv
echo "--> Compiling Shared Python Wheel package..."
cd shared-libs
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/Scripts/activate
pip install --upgrade pip setuptools wheel --quiet
#python setup.py bdist_wheel --quiet
python -m build --wheel

deactivate
cd ..

# 2. Deploy compiled library package asset to S3
echo "--> Syncing compiled binaries to S3 tracking bucket..."
aws s3 cp shared-libs/dist/shared_utils-1.0.0-py3-none-any.whl s3://${BUCKET_NAME}/libraries/ --quiet

# 3. Deploy Python stateless compute orchestration scripts
echo "--> Uploading Glue executor job files..."
aws s3 cp src/glue_jobs/servicenow_ingestion.py s3://${BUCKET_NAME}/scripts/ --quiet
aws s3 cp src/glue_jobs/data_quality_check.py s3://${BUCKET_NAME}/scripts/ --quiet

# 4. Deploy environmental structural runtime JSON configurations
echo "--> Initializing application environment parameters..."
aws s3 cp configs/${ENV}_config.json s3://${BUCKET_NAME}/configs/ --quiet

echo "======================================================="
echo "Artifact Sync Completed Successfully."
echo "======================================================="