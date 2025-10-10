# Architecture overview

## Vision

NebulaOps Observability Platform (Master's thesis) models a modular DevOps stack that can be deployed locally or across public clouds without rewriting application logic. The architecture emphasizes:

- **Portability** – Terraform modules abstract infrastructure differences across Google Cloud and Microsoft Azure.
- **Observability by default** – Every service emits metrics, logs, and test annotations that are visible inside Grafana.
- **Performance experimentation** – k6 scenarios simulate production workloads and expose system bottlenecks.

## High-level components

| Layer             | Responsibilities                                                   | Key assets                                         |
| ----------------- | ------------------------------------------------------------------ | -------------------------------------------------- |
| Delivery pipeline | Containerize workloads, push to registries, orchestrate load tests | `docker-compose.yml`, `load-tests/Dockerfile`      |
| Infrastructure    | Provision networks, compute, and databases across clouds           | `terraform_deploys/gcp`, `terraform_deploys/azure` |
| Observability     | Centralize metrics, dashboards, and alert rules                    | `provisioning/`, `prometheus.yml`                  |
| Test harness      | Execute load scenarios, annotate dashboards, enforce SLOs          | `load-tests/tests/*.ts`                            |

## Deployment modes

### Local developer lab

- Docker Compose starts Grafana, Prometheus, and demo services for rapid iteration.
- Prometheus scrapes local targets defined in `prometheus.yml`.
- Grafana loads dashboards and alerts from the `provisioning/` directory at startup.

### Google Cloud rollout

- Cloud Run hosts the ecommerce web workload and Grafana agent sidecars.
- Cloud SQL serves as the managed PostgreSQL backend.
- Managed Service for Prometheus collects metrics via Terraform-enabled integration.
- Artifact Registry stores Docker images built from the app and load-testing containers.

### Microsoft Azure rollout

- Azure Container Apps runs the workload and handles revision traffic routing.
- Azure Database for PostgreSQL Flexible Server supplies the relational backend.
- Azure Monitor-managed Prometheus ingests metrics compatible with Grafana dashboards.
- Azure Container Registry manages OCI images for both the application and k6 runner.

## Security considerations

- Service principals and service accounts are created by Terraform with least-privilege IAM roles.
- Secrets such as Grafana API tokens are injected via environment variables or secret managers rather than committed to Git.
- Network configuration leverages private subnets and controlled ingress to managed services where supported.

## Data flow

1. Test traffic originates from the k6 runner (containerized locally or via CI/CD).
2. Requests hit the containerized ecommerce application running on Cloud Run or Azure Container Apps.
3. Application metrics are scraped and pushed to managed Prometheus endpoints.
4. Grafana visualizes metrics, with dashboards automatically tagged by k6 annotations to align scenario phases.
5. Terraform state tracks infrastructure changes, enabling reproducible promotions between environments.

## Extensibility

- The architecture supports plugging in additional clouds by following the Terraform module pattern.
- Logging can be extended with Loki or Azure Log Analytics by attaching sidecars and updating Grafana data sources.
- Business KPIs can be incorporated into k6 scenarios with custom trend metrics and threshold assertions.

For deployment specifics, consult [`deployment-gcp.md`](deployment-gcp.md) and [`deployment-azure.md`](deployment-azure.md). For in-depth load-testing workflows, see [`load-testing.md`](load-testing.md).
