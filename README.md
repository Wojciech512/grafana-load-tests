Sprawdzanie dostępnych maszyn
```
gcloud sql tiers list --project=atlantean-yeti-454021-b3 --filter="tier:db-perf-optimized*" --format="value(tier)"
```
Managed Service for Prometheus (Cloud Run sidecar)
```
gcloud services enable run.googleapis.com monitoring.googleapis.com logging.googleapis.com
```
