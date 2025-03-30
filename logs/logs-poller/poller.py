import os
import requests
import schedule
import time
import json
import threading
from datetime import datetime
from fastapi import FastAPI
from fastapi.responses import JSONResponse
# TODO sprawdzić wysłanie logów do fluent-bit
# TODO dodać

app = FastAPI()

LOCAL_LOGS_ENDPOINT = os.getenv(
    "LOG_ENDPOINT",
    "http://host.docker.internal:8000/logs/"
)

LOG_FILE = "/var/log/django_logs.log"

last_poll_time: str | None = None
last_poll_count: int = 0

def poll():
    global last_poll_time, last_poll_count

    try:
        r = requests.get(LOCAL_LOGS_ENDPOINT, timeout=10)
        r.raise_for_status()
        entries = r.json()
        count = len(entries)

        with open(LOG_FILE, "a", encoding="utf-8") as f:
            for e in entries:
                f.write(json.dumps(e) + "\n")

        now = datetime.utcnow().isoformat() + "Z"
        last_poll_time = now
        last_poll_count = count

        print(f"[{now}] Pulled {count} entries from {LOCAL_LOGS_ENDPOINT}")

    except Exception as e:
        err_time = datetime.utcnow().isoformat() + "Z"
        print(f"[{err_time}] Polling error: {e}")

@app.on_event("startup")
def start_polling():
    poll()
    schedule.every(5).seconds.do(poll)

    def run_scheduler():
        while True:
            schedule.run_pending()
            time.sleep(1)

    threading.Thread(target=run_scheduler, daemon=True).start()

@app.get("/health")
async def health():
    return {
        "status": "ok",
        "last_poll_time": last_poll_time,
        "last_poll_count": last_poll_count
    }

@app.get("/", response_class=JSONResponse)
async def get_logs():
    records = []
    if os.path.exists(LOG_FILE):
        with open(LOG_FILE, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    records.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
    return records