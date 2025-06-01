# GCP
## Usługi hostowania aplikacji
limits = {
cpu    = "1"
memory = "1792Mi"
}

limits = {
cpu    = "2"
memory = "3584Mi"
}

limits = {
cpu    = "4"
memory = "7168Mi"
}
      
### Usługi hostowania bazy danych 
db-g1-small (1 cpu, 1792Mi)

limits = {
cpu    = "2"
memory = "3840Mi"
}

limits = {
cpu    = "4"
memory = "7168Mi"
}

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

# Azure
## Usługi hostowania aplikacji (container web app)
B1 to absolutne minimum — wystarczy na lekkie testy i prototypy, przy koszcie ~13 USD/mies.
B2 to złoty środek: 2 vCPU i 3,5 GB RAM za ~26 USD/mies. — dobra przepustowość przy nadal niskim koszcie.
B3 zapewni już 4 vCPU i 7 GB RAM za ~52 USD/mies., gdy potrzebujesz więcej mocy.

## Usługi hostowania bazy danych (flex db postgresql16)
Standard_B1ms (rdzeń wirtualny:1, pamięć GiB:2, maksymalna liczba operacji we/wy na sekundę:640)
Standard_B2s (rdzenie wirtualne:2, pamięć GiB:4, maksymalna liczba operacji we/wy na sekundę:1280)
Standard_B2ms (rdzenie wirtualne:2, pamięć GiB:8, maksymalna liczba operacji we/wy na sekundę:1920)

