# ServiceNow Data Platform Pipeline Orchestration

Enterprise Medallion data engineering architecture handling robust, automated 
ingestion and dynamic normalization workflows for raw ServiceNow payloads.

## Pipeline Architecture Execution Model
1. **Infrastructure Provisioning**: Deployed completely via `infrastructure/` with state locking.
2. **Package Build Management**: Trigger code packaging using `scripts/build_and_deploy.sh`.
3. **Execution Driver Engine**: AWS Glue Spark cluster pulls data from Raw S3, unpacks metadata via `shared_utils` logic, and commits records down to downstream partitioned Parquet layers.

## Testing Setup
To validate local code behavior changes, run the test framework directly:
```bash
pip install -r shared-libs/requirements.txt
export PYTHONPATH=$PYTHONPATH:$(pwd)/shared-libs
pytest tests/


data-platform-orchestration/                   # Root Repository
├── .github/
│   └── workflows/
│       └── deploy.yml                          # CI/CD pipeline automation
├── configs/
│   ├── dev_config.json                        # Development runtime params
│   └── prod_config.json                       # Production runtime params
├── infrastructure/                            # INFRASTRUCTURE LAYER (Terraform)
│   ├── environments/
│   │   ├── dev.tfvars                         # Dev environment parameters
│   │   └── prod.tfvars                        # Prod environment parameters
│   ├── glue.tf                                # Glue jobs, IAM roles, & log configs
│   ├── outputs.tf                             # Terraform outputs
│   ├── providers.tf                           # AWS provider & remote state backend
│   ├── s3.tf                                  # Storage bucket topologies
│   └── variables.tf                           # Infrastructure input variable blocks
├── scripts/
│   └── build_and_deploy.sh                    # Heavy-lifting package & upload automation
├── shared-libs/                               # LOGIC COMPONENT LAYER (Python Wheel)
│   ├── utils/
│   │   ├── __init__.py                        # Package namespace initializer
│   │   ├── config_utils.py                    # Shared S3 config reader module
│   │   └── spark_utils.py                     # Shared dataframe transformation logic
│   ├── requirements.txt                       # Development & test runner dependencies
│   └── setup.py                               # Wheel compilation manifest 
├── src/                                       # RUNTIME LOGIC LAYER (Stateless Scripts)
│   └── glue_jobs/
│       ├── data_quality_check.py              # Ingestion integrity audit script
│       └── servicenow_ingestion.py            # Primary core processing script
├── tests/                                     # INTEGRITY LAYER (PyTest Framework)
│   ├── conftest.py                            # Shared local PySpark session fixture
│   └── test_spark_utils.py                    # Dataframe transformation unit tests
└── README.md                                  # Setup, deployment, and runbook docs



