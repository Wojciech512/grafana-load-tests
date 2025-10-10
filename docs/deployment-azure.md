# Microsoft Azure deployment guide

Deploy NebulaOps Observability Platform (Master's thesis) to Azure Container Apps and Azure Database for PostgreSQL using Terraform.

## Prerequisites

- Azure subscription with access to create resource groups and Container Apps.
- Azure CLI authenticated (`az login`).
- Terraform ≥ 1.7 and Docker installed locally.
- Azure Container Registry (ACR) available or permission to create one.

## 1. Capture environment identifiers

```bash
AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
export AZURE_TENANT_ID AZURE_SUBSCRIPTION_ID
```

## 2. Create a service principal for automation

```bash
SP_NAME="metrics-exporter-sp"
az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role "Monitoring Reader" \
  --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID" \
  --sdk-auth \
  -o json > service-principal.json
```

Store `service-principal.json` securely and reference it in Terraform variables to enable Grafana to query Azure Monitor metrics.

## 3. Build and push container images

```bash
ACR_NAME=pracamagisterskaacr
REGISTRY="$ACR_NAME.azurecr.io"
IMAGE="$REGISTRY/ecommerce-app:latest"

docker build -t $IMAGE .
az acr login --name $ACR_NAME
docker push $IMAGE
```

## 4. Provision infrastructure with Terraform

1. Navigate to the Azure module:
   ```bash
   cd terraform_deploys/azure
   ```
2. Populate `cloud_env.tfvars` with values such as location, ACR name, Container Apps environment name, and database tiers.
3. Initialize, validate, and apply:
   ```bash
   terraform init
   terraform validate -var-file="cloud_env.tfvars"
   terraform apply -var-file="cloud_env.tfvars"
   ```

Terraform creates:

- Resource group and networking primitives (Virtual Network and Subnet).
- Azure Container Apps environment hosting the ecommerce workload and auxiliary services.
- Azure Database for PostgreSQL Flexible Server using recommended SKUs (`Standard_B1ms` to `Standard_B2ms`).
- Azure Monitor-managed Prometheus resources and dashboards wiring.

## 5. Configure observability credentials

- Upload Grafana API tokens to Azure Key Vault or Container Apps secrets.
- Map Terraform outputs (Grafana endpoints, Prometheus scrape URLs) to the k6 environment variables before running tests.

## 6. Run load tests against Azure Container Apps

```bash
GRAFANA_URL=https://<grafana-endpoint>
GRAFANA_TOKEN=<token-from-secret-store>

docker run --rm \
  -e GRAFANA_URL=$GRAFANA_URL \
  -e GRAFANA_TOKEN=$GRAFANA_TOKEN \
  -e DASHBOARD_IDS_TO_ANNOTATE=4,10 \
  nebulaops-k6 run tests/ecommerce-test.ts
```

Monitor Grafana for annotations and use Azure Monitor metrics to validate scaling behavior.

## 7. Clean up resources

```bash
terraform destroy -var-file="cloud_env.tfvars"
```

If you created dedicated resource groups or registries for the demo, remove them afterwards:

```bash
az group delete --name <resource-group> --yes --no-wait
```

---

Return to the [Google Cloud guide](deployment-gcp.md) or explore the [architecture overview](architecture.md) for more context.
