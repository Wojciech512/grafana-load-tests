#!/usr/bin/env python3
import re, sys, time
from pathlib import Path
from urllib.parse import urlencode
import requests

# --- KONFIG ---
OUT_DIR = "grafana_exports"
RETRIES = 8

COMMON = {'timezone':'Europe/Warsaw',"orgId": 1, "width": 1000, "height": 500, "scale": 2, "theme": "light", 'annotations': 'true'}

RAW_INTERVALS = [
    # AZURE
    '&from=2025-09-13T17:30:51.000Z&to=2025-09-13T23:48:24.000Z',
    '&from=2025-09-13T17:31:40.461Z&to=2025-09-13T19:35:42.500Z',
    '&from=2025-09-13T19:36:40.089Z&to=2025-09-13T21:42:42.277Z',
    '&from=2025-09-13T21:43:34.609Z&to=2025-09-13T23:47:35.596Z',

    # GCP
    '&from=2025-09-17T23:10:05.711Z&to=2025-09-18T05:34:49.749Z',
    '&from=2025-09-17T23:14:49.323Z&to=2025-09-18T01:21:06.705Z',
    '&from=2025-09-18T01:21:00.698Z&to=2025-09-18T03:26:35.071Z',
    '&from=2025-09-18T03:26:39.286Z&to=2025-09-18T05:32:41.922Z',
]

# kontener-aplikacji
# BASE_URL = "http://localhost:3000/render/d-solo/40f9e67c-9c08-481f-9319-08a39f2fe84b/kontener-aplikacji-09092025"
# PANEL_IDS = [1, 5, 16, 3, 11, 17, 9, 12, 18, 13, 10, 8, 6, 7] * 2 

# PLOTNAMES= [
#   'Wykorzystanie CPU [99-ty percentyl][%] - AZURE',
#   'Wykorzystanie pamięci RAM [99-ty percentyl][%] - AZURE',
#   'Czas oczekiwania na uruchomienie kontenera [99-ty percentyl][sekundy] - AZURE',
#   'Wykorzystanie CPU [95-ty percentyl][%] - AZURE',
#   'Wykorzystanie pamięci RAM [95-ty percentyl][%] - AZURE',
#   'Czas oczekiwania na uruchomienie kontenera [95-ty percentyl][sekundy] - AZURE',
#   'Wykorzystanie CPU [50-ty percentyl][%] - AZURE',
#   'Wykorzystanie pamięci RAM [50-ty percentyl][%] - AZURE',
#   'Czas oczekiwania na uruchomienie kontenera [50-ty percentyl][sekundy] - AZURE',
#   'Wykorzystanie CPU [Odchylenie standardowe][%] - AZURE',
#   'Wykorzystanie pamięci RAM [Odchylenie standardowe][%] - AZURE',
#   'Liczba aktywnych instancji [Średnia] - AZURE',
#   'Wychodzący ruch sieciowy [egress][bajty/sekundę] - AZURE',
#   'Przychodzący ruch sieciowy [ingress][bajty/sekundę] - AZURE',

#   'Wykorzystanie CPU [99-ty percentyl][%] - GCP',
#   'Wykorzystanie pamięci RAM [99-ty percentyl][%] - GCP',
#   'Czas oczekiwania na uruchomienie kontenera [99-ty percentyl][sekundy] - GCP',
#   'Wykorzystanie CPU [95-ty percentyl][%] - GCP',
#   'Wykorzystanie pamięci RAM [95-ty percentyl][%] - GCP',
#   'Czas oczekiwania na uruchomienie kontenera [95-ty percentyl][sekundy] - GCP',
#   'Wykorzystanie CPU [50-ty percentyl][%] - GCP',
#   'Wykorzystanie pamięci RAM [50-ty percentyl][%] - GCP',
#   'Czas oczekiwania na uruchomienie kontenera [50-ty percentyl][sekundy] - GCP',
#   'Wykorzystanie CPU [Odchylenie standardowe][%] - GCP',
#   'Wykorzystanie pamięci RAM [Odchylenie standardowe][%] - GCP',
#   'Liczba aktywnych instancji [Średnia] - GCP',
#   'Wychodzący ruch sieciowy [egress][bajty/sekundę] - GCP',
#   'Przychodzący ruch sieciowy [ingress][bajty/sekundę] - GCP',
# ]

# k6-prometheus
BASE_URL = "http://localhost:3000/render/d-solo/ccbb2351-2ae2-462f-ae0e-f2c893ad1028/k6-prometheus"
COMMON.update({'var-quantile_stat': 'p99', 'var-testid': '$__all'})
PANEL_IDS = [10, 8, 9, 14, 15, 18, 13] * 2

PLOTNAMES= [
  # AZURE
  'Performance Overview - AZURE',
  'Transfer Rate - AZURE',
  'Iterations - AZURE',
  'HTTP Latency Timings - AZURE',
  'HTTP Latency Stats - AZURE',
  'HTTP Request Rate - AZURE',
  'Checks Success Rate (aggregate individual checks) - AZURE',

#  GCP
  'Performance Overview - GCP',
  'Transfer Rate - GCP',
  'Iterations - GCP',
  'HTTP Latency Timings - GCP',
  'HTTP Latency Stats - GCP',
  'HTTP Request Rate - GCP',
  'Checks Success Rate (aggregate individual checks) - GCP',
]


# --- KONIEC KONFIG ---

def sanitize(s: str) -> str:
    return "".join(c for c in s if c.isalnum() or c in "-_[]()%ąĄćĆęĘłŁńŃóÓśŚźŹżŻ @.").strip().replace(" ", "_")

def normalize_interval(raw: str):
    # zapewnij leading '&'
    raw = raw.strip()
    if raw.startswith('&'):
        raw = raw[1:]
    # wyciągnij from/to
    m_from = re.search(r'from=([^&]+)', raw)
    m_to = re.search(r'to=([^&]+)', raw)
    if not m_from or not m_to:
        raise ValueError(f"Niepoprawny zakres czasu: {raw}")
    return m_from.group(1), m_to.group(1)

def build_url(base: str, params: dict) -> str:
    return f"{base}?{urlencode(params)}"

def fetch_png(url: str, out_path: Path, token: str):
    headers = {
        "Authorization": f"Bearer {token}",
        "X-Grafana-Org-Id": "1",
        "Accept": "image/png"
    }
    with requests.Session() as s:
        for attempt in range(1, RETRIES+1):
            print(url)
            r = s.get(url, headers=headers, stream=True, timeout=180, allow_redirects=False)
            ct = r.headers.get("Content-Type","")
            if r.status_code == 200 and ct.startswith(("image/png","image/jpeg")):
                out_path.parent.mkdir(parents=True, exist_ok=True)
                with open(out_path, "wb") as f:
                    for c in r.iter_content(8192): f.write(c)
                return True, ""
            # zapisz HTML/redirect diagnostycznie
            try: (out_path.with_suffix(".html")).write_text(r.text[:20000], encoding="utf-8")
            except: pass
            if attempt < RETRIES: time.sleep(1.5*attempt)
            else: return False, f"HTTP {r.status_code} ct={ct} loc={r.headers.get('Location','')}"

def main():
    token = ""
    if not token:
        print("Brak GRAFANA_TOKEN w env. Ustaw i uruchom ponownie.", file=sys.stderr)
        sys.exit(2)

    if len(PANEL_IDS) != len(PLOTNAMES):
        print("Liczba PANEL_IDS musi odpowiadać liczbie PLOTNAMES.", file=sys.stderr)
        sys.exit(2)

    intervals = [normalize_interval(x) for x in RAW_INTERVALS]
    base_out = Path(OUT_DIR)
    base_out.mkdir(parents=True, exist_ok=True)

    total_ok = 0
    total_err = 0

    for idx_int, (frm, to) in enumerate(intervals, start=1):
        # folder per zakres
        int_folder = base_out / f"range_{idx_int:02d}__{sanitize(frm)}__{sanitize(to)}"
        int_folder.mkdir(parents=True, exist_ok=True)

        for idx, (pid, pname) in enumerate(zip(PANEL_IDS, PLOTNAMES), start=1):
            params = dict(COMMON)
            params.update({"panelId": int(pid), "from": frm, "to": to})
            url = build_url(BASE_URL, params)
            fname = f"{sanitize(pname)} {sanitize(frm)}-{sanitize(to)}.png"
            out_path = int_folder / fname
            ok, err = fetch_png(url, out_path, token)
            if ok:
                print(f"OK   → {out_path}")
                total_ok += 1
            else:
                print(f"FAIL → {out_path}\n       url={url}\n       {err}", file=sys.stderr)
                total_err += 1

    print(f"\nZakończono. OK={total_ok}, ERR={total_err}")
    sys.exit(1 if total_err else 0)

if __name__ == "__main__":
    main()
