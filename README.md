# GCP
## Sprawdzanie dostępnych maszyn
```
gcloud sql tiers list --project=atlantean-yeti-454021-b3 --filter="tier:db-perf-optimized*" --format="value(tier)"
```

## Managed Service for Prometheus (Cloud Run sidecar)

```
gcloud services enable run.googleapis.com monitoring.googleapis.com logging.googleapis.com
```

## Budowanie obrazów do rejestru 
```
docker build -t europe-central2-docker.pkg.dev/praca-magisterska-proj-gcp/praca-magisterska-artifact-registry/django-app:latest .
```
## Wysyłanie obrazów do rejestru
```
docker push  europe-central2-docker.pkg.dev/praca-magisterska-proj-gcp/praca-magisterska-artifact-registry/django-app:latest```
```

## KLUCZ DO PROXY
```
terraform output -raw google_service_account_key.proxy_key_private_key > proxy-sa-key.json
```

## ID do rachunków
```
 gcloud billing accounts list --filter="open=true" --format="value(NAME)"
```

## Usuwanie projektu
```
gcloud projects delete praca-magisterska-proj-gcp
```
