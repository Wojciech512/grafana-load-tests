FROM grafana/k6:0.57.0

WORKDIR /tests

USER root
RUN apk update && apk add --no-cache curl
USER k6
