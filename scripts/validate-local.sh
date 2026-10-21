#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing dependencies..."
python -m pip install -r requirements.txt -r requirements-dev.txt

echo "==> Running pytest..."
python -m pytest -q

echo "==> Running Ruff lint check..."
ruff check app

echo "==> Building container image locally..."
docker build -t optum-assessment:local .

echo "==> Validating Terraform environments..."
for env in dev prod; do
  echo "--- Testing environment: ${env} ---"
  terraform -chdir="terraform/environments/${env}" init -backend=false
  terraform -chdir="terraform/environments/${env}" fmt -check -recursive
  terraform -chdir="terraform/environments/${env}" validate
  terraform -chdir="terraform/environments/${env}" test
done

echo "Local validation commands completed successfully."
