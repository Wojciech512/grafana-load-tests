FROM grafana/k6:0.57.0

WORKDIR /tests

ENTRYPOINT ["k6","run","--out","experimental-prometheus-rw","ecommerce-test.ts"]
