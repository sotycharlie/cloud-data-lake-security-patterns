# Cloud Data Lake Security Patterns

**Author:** Sotonye Evelyn Charles | **Course:** GACS 7307 | **Date:** April 2026

## What This Is

Implementation and evaluation of reusable security patterns for hybrid cloud data lakes. The proposed pattern uses per-object encryption with AWS KMS.


## Repository Contents
 `pattern_c_test.py`:Performance tests (10MB, 100MB, 500MB, 1GB) 
`attack_simulation.py` Permission validation for IAM roles 
`/terraform`:  Terraform files for AWS deployment 

## Requirements 
- AWS account
- Terraform
- Python 3.13+
- AWS CLI configured
## Quick Start

```bash
# 1. Deploy infrastructure
cd terraform && terraform apply

# 2. Run performance test
python pattern_c_test.py

# 3. Run permission test
python attack_simulation.py

