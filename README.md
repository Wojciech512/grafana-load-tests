# NebulaOps Observability Platform (Master's thesis)

NebulaOps is a production-grade observability and performance engineering platform created as the foundation of my master's thesis. It combines infrastructure-as-code, multi-cloud deployment strategies, and deep observability automation to provide a compelling DevOps story for modern SaaS workloads.

## Why it matters for DevOps portfolios

- **End-to-end narrative** – From Terraform provisioning through automated load testing with k6 and Grafana analytics, NebulaOps demonstrates complete platform ownership.
- **Multi-cloud fluency** – Ready-to-run deployments for Google Cloud and Microsoft Azure highlight cloud-agnostic architecture and portability skills.
- **Observability first** – Managed Prometheus, custom dashboards, and automated annotations ensure every test is measurable and auditable.
- **Production thinking** – Opinionated naming conventions, security guardrails, and Git-based workflows reflect real-world delivery constraints.

---

## Table of contents

1. [Platform overview](#platform-overview)
2. [Solution architecture](#solution-architecture)
3. [Key capabilities](#key-capabilities)
4. [DevOps lifecycle walkthrough](#devops-lifecycle-walkthrough)
5. [Repository structure](#repository-structure)
6. [Quick start](#quick-start)
7. [Operations guide](#operations-guide)
8. [Dashboards & reporting](#dashboards--reporting)
9. [Portfolio highlights](#portfolio-highlights)
10. [Roadmap](#roadmap)

---

## Platform overview

NebulaOps simulates a cloud-native ecommerce workload and instrumented observability stack. It provisions infrastructure with Terraform, deploys workloads via container registries, and executes repeatable load tests that annotate Grafana dashboards for precise performance storytelling. The platform can run fully locally with Docker Compose or be promoted to managed services on GCP and Azure.

### Core objectives

| Objective                            | Implementation                                                                                 |
| ------------------------------------ | ---------------------------------------------------------------------------------------------- |
| Consistent, auditable infrastructure | Terraform modules for Google Cloud Run, Cloud SQL, Azure Container Apps, and managed databases |
| Automated performance insights       | k6 TypeScript scenarios synced with Grafana annotations and Prometheus remote write            |
| Developer experience                 | Prettier formatting automation, documented workflows, and opinionated repository layout        |
| Portfolio storytelling               | Dedicated documentation and diagrams that make the platform easy to present to recruiters      |

## Solution architecture

```
+-------------------+        +------------------------+
| Terraform IaC     |        |  CI/CD (GitHub Actions)|
|  - GCP deployment | -----> |  - Build & push images |
|  - Azure deployment|       |  - Trigger load tests  |
+---------+---------+        +-----------+------------+
          |                               |
          |                               v
          v                 +-----------------------------+
+-------------------+       | k6 Load Testing Orchestrator |
| Container Runtime |       |  - Ecommerce scenarios       |
|  (Cloud Run/Azure |       |  - Grafana annotations       |
|   Container Apps) |       +------------------------------+
+---------+---------+                               |
          |                                         v
          v                        +-------------------------------+
+-------------------+              | Observability Layer           |
| Managed Databases | <----------- |  - Grafana dashboards         |
|  (Cloud SQL/Azure |              |  - Managed Prometheus / Mimir |
|   Flexible Server)|              |  - Loki logging (optional)    |
+-------------------+              +-------------------------------+
```

### Personas addressed

- **Platform Engineer** – designs Terraform modules, configures managed services, and enforces security.
- **Site Reliability Engineer** – monitors dashboards, reacts to load test signals, tunes capacity.
- **Performance Engineer** – iterates on k6 scenarios, correlates synthetic load with business KPIs.

## Key capabilities

| Category          | Highlights                                                                                                 |
| ----------------- | ---------------------------------------------------------------------------------------------------------- |
| Infrastructure    | Multi-cloud Terraform blueprints, networking baselines, IAM automation                                     |
| CI/CD & Images    | Dockerfiles for k6 runners, registry push workflows for GCP Artifact Registry and Azure Container Registry |
| Observability     | Grafana provisioning, Prometheus remote-write integration, automated annotation publishing                 |
| Testing           | Rich k6 scenarios (`load-tests/tests`) covering cold start, steady, stress, spike, and soak phases         |
| Developer Tooling | Prettier formatting scripts, TypeScript typings for k6, reproducible local environment via Docker Compose  |

## DevOps lifecycle walkthrough

1. **Plan** – Define target cloud (GCP or Azure) and adjust Terraform variables to match capacity requirements.
2. **Provision** – Apply Terraform configurations to create networking, managed databases, and container runtimes.
3. **Package** – Build workload images (Django ecommerce demo) and push them to the cloud-specific registry.
4. **Deploy** – Release container revisions through Cloud Run or Azure Container Apps with observability sidecars enabled.
5. **Test** – Execute k6 suites from the `load-tests` runner to stress the platform and tag dashboards automatically.
6. **Observe** – Analyze Grafana dashboards (imported via `provisioning/`) enriched by load test annotations.
7. **Iterate** – Capture findings, adjust Terraform or application configuration, and rerun the pipeline.

## Repository structure

```
.
├── docker-compose.yml          # Local orchestration for Grafana, Prometheus, and demo services
├── load-tests/                 # k6 test runner Dockerfile and TypeScript scenarios
│   └── tests/
│       ├── ecommerce-test.ts   # Full performance suite with Grafana annotations
│       └── test-check.ts       # Smoke test to validate environments
├── provisioning/               # Grafana dashboards, data sources, and alerting configuration
├── prometheus.yml              # Prometheus scrape configuration (local mode)
├── terraform_deploys/
│   ├── gcp/                    # Cloud Run + Cloud SQL modules and variables
│   └── azure/                  # Azure Container Apps + Flexible Server modules
├── docs/                       # Portfolio-ready documentation set
│   ├── architecture.md
│   ├── deployment-gcp.md
│   ├── deployment-azure.md
│   └── load-testing.md
└── package.json                # Formatting scripts and dependencies
```

## Quick start

> 🧭 Choose your path: [Local lab](#local-lab-setup), [Google Cloud](docs/deployment-gcp.md), or [Microsoft Azure](docs/deployment-azure.md).

### Local lab setup

1. **Install prerequisites** – Docker Desktop (or podman), Node.js 20+, and Terraform 1.7+.
2. **Bootstrap dependencies**:
   ```bash
   npm install
   npm run format:check
   ```
3. **Launch observability stack**:
   ```bash
   docker compose up -d
   ```
4. **Customize credentials** in [`load-tests/.env.example`](load-tests/.env.example) and run a smoke test:
   ```bash
   npm run format
   docker build -t nebulaops-k6 load-tests
   docker run --rm --env-file=load-tests/.env.example nebulaops-k6 run tests/test-check.ts
   ```
5. **Open Grafana** at [http://localhost:3000](http://localhost:3000) and explore pre-provisioned dashboards.

## Operations guide

### Running the full ecommerce scenario

```bash
docker run --rm \
  -e GRAFANA_URL=http://host.docker.internal:3000 \
  -e GRAFANA_TOKEN=<token> \
  -e DASHBOARD_IDS_TO_ANNOTATE=4,10 \
  nebulaops-k6 run tests/ecommerce-test.ts
```

The script executes cold start, steady load, stress, spike, and soak phases while pushing annotations to Grafana for each phase boundary.

### Formatting & linting

Maintain code quality with:

```bash
npm run format
npm run format:check
```

### Terraform validation

Before applying infrastructure changes, run:

```bash
cd terraform_deploys/<cloud>
terraform init
terraform validate -var-file="cloud_env.tfvars"
```

## Dashboards & reporting

- **Grafana provisioning** – Dashboards, alert rules, and data sources live under `provisioning/`. They automatically load when Grafana starts locally or through Terraform bootstrapping in the cloud.
- **Managed Prometheus** – Google Managed Service for Prometheus is enabled via Terraform and mirrored by Azure Monitor-managed Prometheus equivalents.
- **Annotations** – Each load test phase posts a descriptive annotation, enabling time-aligned storytelling during portfolio reviews.

## Portfolio highlights

- Crafted as the centrepiece of a master's thesis to illustrate real-world DevOps competencies.
- Demonstrates cross-cloud expertise with opinionated yet adaptable Terraform templates.
- Provides measurable outcomes through reproducible load tests, enabling data-backed retrospectives.
- Includes narrative-friendly documentation (this README + `/docs`) to support interviews and presentations.

## Roadmap

- [ ] Automate CI/CD pipelines using GitHub Actions for provisioning, testing, and regression checks.
- [ ] Add Loki-based log aggregation with sample alerts.
- [ ] Publish reference Grafana screenshots and storytelling scripts.
- [ ] Expand k6 scenarios with business metrics (conversion, latency SLOs).

---

**Looking for more detail?** Dive into the [`docs/`](docs/) directory for architecture deep dives, cloud-specific deployment runbooks, and load testing guides tailored for showcase demos.
