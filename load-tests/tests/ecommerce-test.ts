// TODO Chcesz porównać same platformy (GCP Cloud Run vs Azure App Service, …), a nie logikę Twojej aplikacji Django.
//  Musisz więc zaprojektować testy, które eksponują cechy infrastruktury:
//  czas zimnego startu,
//  szybkość autoscalingu,
//  granice przepustowości,
//  wpływ skoków ruchu,
//  koszt przy różnym obciążeniu
//  i stabilność w dłuższym horyzoncie.
//  Stress & Ramp-up Spike  Cold-start Soak / endurance

import http, { RefinedResponse, ResponseType, RefinedParams } from "k6/http";
import { sleep, check } from "k6";
import exec from "k6/execution";

/* ---------- annotation helpers ---------- */
const url = `http://${__ENV.GRAFANA_URL}/api/annotations`;
const token = __ENV.GRAFANA_TOKEN;
let start = 0;

export function setup() {
  start = Date.now();
  http.post(
    url,
    JSON.stringify({
      time: start,
      tags: ["test_start", `run_id=${__ENV.RUN_ID}`],
      text: `k6 ${__ENV.CLOUD} run rozpoczęty`,
    }),
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    },
  );
}

export function teardown() {
  http.post(
    url,
    JSON.stringify({
      time: start,
      timeEnd: Date.now(),
      tags: ["test_end", `run_id=${__ENV.RUN_ID}`],
      text: `k6 ${__ENV.CLOUD} zakończony; maxVUs=${exec.instance.vusInitialized}`,
    }),
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    },
  );
}

/* ---------- konfiguracja globalna ---------- */
const BASE = __ENV.BASE_URL;

/* ---------- helper CSRF ---------- */
function csrfHeaders(
  page: RefinedResponse<ResponseType>,
): RefinedParams<undefined> | undefined {
  const csrf = page.cookies["csrftoken"][0].value;
  return {
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "X-CSRFToken": csrf,
      Cookie: `csrftoken=${csrf}`,
    },
  };
}

/* ---------- stary scenariusz użytkownika ---------- */
export function userJourney() {
  try {
    /* 1. rejestracja */
    let page = http.get(`${BASE}/account/register`);
    let headers = csrfHeaders(page);

    const regBody = {
      username: `user${__VU}`,
      email: `user${__VU}@test.com`,
      password1: "Test123!",
      password2: "Test123!",
    };
    let res = http.post(`${BASE}/account/register`, regBody, headers);
    check(res, { "register ok": (r) => [200, 302].includes(r.status) });

    /* 2. logowanie */
    page = http.get(`${BASE}/account/login`);
    headers = csrfHeaders(page);
    const loginBody = { username: `user${__VU}`, password: "Test123!" };
    res = http.post(`${BASE}/account/login`, loginBody, headers);
    check(res, { "login ok": (r) => [200, 302].includes(r.status) });
    sleep(1);

    /* 3. produkt */
    res = http.get(`${BASE}/product/electronics-produkt-1-41991/`);
    check(res, { product: (r) => r.status === 200 });
    sleep(1);

    /* 4. koszyk */
    const cartBody = { product_id: "68226", quantity: "1" };
    res = http.post(`${BASE}/cart/`, cartBody, headers);
    check(res, { cart: (r) => [200, 302].includes(r.status) });
    sleep(1);

    /* 5-6. checkout + dashboard */
    check(http.get(`${BASE}/payment/checkout`), {
      checkout: (r) => r.status === 200,
    });
    check(http.get(`${BASE}/account/dashboard`), {
      dash: (r) => r.status === 200,
    });
    sleep(2);
  } catch (err: any) {
    http.post(
      `${url}/api/annotations`,
      JSON.stringify({
        time: Date.now(),
        tags: ["test_crash", `run_id=${__ENV.RUN_ID}`],
        text: `k6 crash: ${err.message}`,
      }),
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
      },
    );

    throw err;
  }
}

/* ---------- scenariusze obciążenia ---------- */
export const options = {
  thresholds: {
    // RED – Requests, Errors, Duration
    http_reqs: ["rate>=30"], // zapewnienie min. 30 RPS
    http_req_failed: ["rate<=0.01"], // max 1% błędów
    http_req_duration: ["p(95)<800", "p(99)<1500"], // p95 < 800 ms, p99 < 1.5 s
    checks: ["rate>=0.95"], // min. 95% pozytywnych asercji

    // Obciążenie i wolumen
    data_sent: ["rate>0"], // wysyłanie danych
    data_received: ["rate>0"], // odbiór danych
    iterations: ["count>0"], // wykonanie co najmniej jednej iteracji
    vus: ["value<=100"], // aktywnych VU ≤ 100
    vus_max: ["value<=100"], // prealokowanych VU ≤ 100
    dropped_iterations: ["count==0"], // brak odrzuconych iteracji
    iteration_duration: ["p(95)<2000"], // czas iteracji p95 < 2 s

    // Detale HTTP
    http_req_blocked: ["avg<100"], // czas blokowania < 100 ms
    http_req_connecting: ["avg<100"], // nawiązywanie TCP < 100 ms
    http_req_waiting: ["avg<500"], // TTFB < 500 ms
    http_req_sending: ["avg<200"], // wysyłanie < 200 ms
    http_req_receiving: ["avg<200"], // odbieranie < 200 ms
    http_req_tls_handshaking: ["avg<200"], // handshake TLS < 200 ms
  },
  scenarios: {
    /* 1) Cold-start / smoke – 1 iteracja po 15 min bezruchu */
    cold_start: {
      executor: "per-vu-iterations",
      vus: 1,
      iterations: 1,
      startTime: "0s",
      exec: "userJourney",
    },

    /* 2) Steady-load – 30 RPS przez 30 min (baseline) */
    steady_load: {
      executor: "constant-arrival-rate",
      rate: 30,
      timeUnit: "1s",
      duration: "30m",
      preAllocatedVUs: 10,
      maxVUs: 100,
      startTime: "1m",
      exec: "userJourney",
    },

    /* 3) Stress / ramp-up – rosnący ruch do 200 RPS */
    stress: {
      executor: "ramping-arrival-rate",
      startRate: 20,
      timeUnit: "1s",
      preAllocatedVUs: 20,
      maxVUs: 300,
      stages: [
        { target: 50, duration: "5m" },
        { target: 100, duration: "5m" },
        { target: 150, duration: "5m" },
        { target: 200, duration: "5m" },
        { target: 0, duration: "2m" },
      ],
      startTime: "35m",
      exec: "userJourney",
    },

    /* 4) Spike – 0 → 200 RPS w 10 s, 5 min hold */
    spike: {
      executor: "ramping-arrival-rate",
      startRate: 0,
      timeUnit: "1s",
      stages: [
        { target: 200, duration: "10s" },
        { target: 200, duration: "5m" },
        { target: 0, duration: "30s" },
      ],
      preAllocatedVUs: 20,
      maxVUs: 500,
      startTime: "55m",
      exec: "userJourney",
    },

    /* 5) Soak / endurance – 20 RPS przez 8 h */
    soak: {
      executor: "constant-arrival-rate",
      rate: 20,
      timeUnit: "1s",
      duration: "8h",
      preAllocatedVUs: 25,
      maxVUs: 200,
      startTime: "61m",
      exec: "userJourney",
    },
  },
};
