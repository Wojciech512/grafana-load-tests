# Google Cloud deployment guide

This runbook promotes NebulaOps Observability Platform (Master's thesis) to Google Cloud Platform using Terraform and Cloud Run.

## Prerequisites

- Google Cloud project (e.g., `praca-magisterska-proj-gcp`).
- Billing account with permissions to link to the project.
- Local tooling: `gcloud` CLI, Terraform ≥ 1.7, Docker.
- Artifact Registry enabled in the target project.

## 1. Enable required services

```bash
gcloud services enable \
  run.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com
```

## 2. Authenticate and configure project

```bash
gcloud auth login
PROJECT_ID=praca-magisterska-proj-gcp
gcloud config set project $PROJECT_ID
```

List available billing accounts if needed:

```bash
gcloud billing accounts list --filter="open=true" --format="value(ACCOUNT_ID)"
```

## 3. Build and push container images

```bash
REGION=europe-central2
REGISTRY="$REGION-docker.pkg.dev/$PROJECT_ID/praca-magisterska-artifact-registry"
IMAGE="$REGISTRY/django-app:latest"

docker build -t $IMAGE .
docker push $IMAGE
```

## 4. Provision infrastructure with Terraform

1. Navigate to the GCP module:
   ```bash
   cd terraform_deploys/gcp
   ```
2. Provide environment-specific variables in `cloud_env.tfvars` (examples: region, database tiers, service account names).
3. Initialize and validate:
   ```bash
   terraform init
   terraform validate -var-file="cloud_env.tfvars"
   ```
4. Apply the configuration:
   ```bash
   terraform apply -var-file="cloud_env.tfvars"
   ```

The Terraform templates provision:

- Cloud Run service for the ecommerce workload.
- Cloud SQL PostgreSQL instance with recommended tiers (`db-g1-small` through `db-custom-4-7680`).
- Artifact Registry repository for container images.
- Managed Service for Prometheus integration for observability.
- Service accounts and IAM bindings for secure proxying and deployments.

Retrieve generated service account keys when required (example for proxy integration):

```bash
terraform output -raw google_service_account_key.proxy_key_private_key > proxy-sa-key.json
```

## 5. Configure networking and connectivity

- Terraform templates set up private networking and connectors for Cloud Run ↔ Cloud SQL communication.
- If a dedicated proxy is required, load the key produced above and configure the service according to the Terraform outputs.

## 6. Execute load tests against Cloud Run

Once the service URL is available, run the full k6 scenario:

```bash
GRAFANA_TOKEN=$(gcloud secrets versions access latest --secret=grafana-api-token)
docker run --rm \
  -e GRAFANA_URL=https://<grafana-domain> \
  -e GRAFANA_TOKEN=$GRAFANA_TOKEN \
  -e DASHBOARD_IDS_TO_ANNOTATE=4,10 \
  nebulaops-k6 run tests/ecommerce-test.ts
```

Annotations will appear inside Grafana, aligning the test phases with observed metrics.

## 7. Clean up resources

To avoid charges, remove the project or destroy the Terraform state:

```bash
terraform destroy -var-file="cloud_env.tfvars"
```

or delete the whole project:

```bash
gcloud projects delete $PROJECT_ID
```

---

Continue with the [Azure deployment guide](deployment-azure.md) if you want to demonstrate multi-cloud parity.
