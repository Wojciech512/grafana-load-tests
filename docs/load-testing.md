# Load testing playbook

This guide explains how NebulaOps Observability Platform (Master's thesis) uses k6 to validate performance characteristics and generate portfolio-ready insights.

## Scenario catalogue

### `tests/ecommerce-test.ts`

- **Purpose** – Full regression suite targeting the ecommerce application and its dependencies.
- **Grafana integration** – Posts annotations for each phase (cold start, steady load, stress, spike, soak) across multiple dashboards via the Grafana API.
- **Highlights**
  - Parameterized dashboard IDs through `DASHBOARD_IDS_TO_ANNOTATE`.
  - Automatic calculation of scenario timelines to keep phases aligned to minute boundaries.
  - Custom load profiles ranging from gentle ramps to extreme spikes.

### `tests/test-check.ts`

- **Purpose** – Lightweight smoke test ensuring endpoints respond before running the full scenario.
- **Usage** – Execute prior to `ecommerce-test.ts` inside CI/CD or local setups.

## Running tests locally

1. Build the k6 runner image:
   ```bash
   docker build -t nebulaops-k6 load-tests
   ```
2. Provide environment variables (example uses a local Grafana instance):
   ```bash
   cat <<'ENV' > load-tests/.env.example
   GRAFANA_URL=http://grafana:3000
   GRAFANA_TOKEN=<insert-local-token>
   DASHBOARD_IDS_TO_ANNOTATE=4,10
   ENV
   ```
3. Execute a smoke test:
   ```bash
   docker run --rm --env-file=load-tests/.env.example nebulaops-k6 run tests/test-check.ts
   ```
4. Launch the comprehensive scenario:
   ```bash
   docker run --rm --env-file=load-tests/.env.example nebulaops-k6 run tests/ecommerce-test.ts
   ```

## Key environment variables

| Variable                    | Description                                         | Default        |
| --------------------------- | --------------------------------------------------- | -------------- |
| `GRAFANA_URL`               | Base URL for Grafana REST API                       | `grafana:3000` |
| `GRAFANA_TOKEN`             | API token with annotation scope                     | _required_     |
| `GRAFANA_ORG_ID`            | Optional Grafana organization ID                    | Empty          |
| `DASHBOARD_IDS_TO_ANNOTATE` | Comma-separated dashboard IDs receiving annotations | `4,10`         |
| `BREAK_BETWEEN_TESTS`       | Minutes between scenario phases                     | `3`            |
| `BREAK_BETWEEN_SETS`        | Minutes between repeated scenario sets              | n/a            |

## Scenario anatomy

- The script calculates phase start times with helper functions `toK6` and `ceilMin` to align with Grafana time axes.
- Each phase defines unique k6 executors:
  - **Cold start** – `per-vu-iterations` executor, 1 VU.
  - **Steady load** – `constant-arrival-rate` at 80 RPS.
  - **Stress** – `ramping-arrival-rate` scaling up to 420 RPS before cooldown.
  - **Spike** – `ramping-arrival-rate` hitting 500 RPS within seconds.
  - **Soak** – `constant-arrival-rate` at 50 RPS for 60 minutes.
- Post-test hooks evaluate HTTP response codes, payload validations, and custom thresholds using k6 `check` constructs.

## Reporting best practices

- Export Grafana dashboard panels as PNGs aligned with annotations to showcase cause-and-effect during interviews.
- Summarize key findings (latency percentiles, error budgets) in retrospectives or README updates.
- Automate result uploads to cloud storage or GitHub Releases for reproducible evidence of platform readiness.

## Troubleshooting

- **Annotations missing** – Verify `GRAFANA_TOKEN` has the `annotations:write` permission and confirm network access to Grafana.
- **Load plateaus** – Increase `preAllocatedVUs` and `maxVUs` in the scenario definitions to match target RPS.
- **Environment drift** – Rebuild the k6 Docker image after modifying TypeScript files to ensure compiled bundles are up to date.

For architectural context, review [`architecture.md`](architecture.md). To deploy these tests against cloud environments, use the [GCP](deployment-gcp.md) or [Azure](deployment-azure.md) guides.
