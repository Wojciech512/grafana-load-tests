FROM python:3.10-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY poller.py .
EXPOSE 8002
CMD ["uvicorn", "poller:app", "--host", "0.0.0.0", "--port", "8002"]
