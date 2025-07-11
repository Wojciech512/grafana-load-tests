import http, { RefinedResponse, ResponseType, RefinedParams } from "k6/http";
import { sleep, check } from "k6";
import exec from "k6/execution";

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

const BASE = __ENV.BASE_URL;

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

export function userJourney() {
  try {
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

    page = http.get(`${BASE}/account/login`);
    headers = csrfHeaders(page);
    const loginBody = { username: `user${__VU}`, password: "Test123!" };
    res = http.post(`${BASE}/account/login`, loginBody, headers);
    check(res, { "login ok": (r) => [200, 302].includes(r.status) });
    sleep(1);

    const cartBody = { product_id: "68226", quantity: "1" };
    res = http.post(`${BASE}/cart/`, cartBody, headers);
    check(res, { cart: (r) => [200, 302].includes(r.status) });
    sleep(1);

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
    cold_start: {
      executor: "per-vu-iterations",
      vus: 1,
      iterations: 1,
      startTime: "0s",
      exec: "userJourney",
    },
    steady_load: {
      executor: "constant-arrival-rate",
      rate: 30,
      timeUnit: "1s",
      duration: "30m",
      preAllocatedVUs: 10,
      maxVUs: 50,
      startTime: "1m",
      exec: "userJourney",
    },
    stress: {
      executor: "ramping-arrival-rate",
      startRate: 20,
      timeUnit: "1s",
      stages: [
        { target: 50, duration: "5m" },
        { target: 100, duration: "5m" },
        { target: 150, duration: "5m" },
        { target: 200, duration: "5m" },
        { target: 0, duration: "2m" },
      ],
      preAllocatedVUs: 20,
      maxVUs: 100,
      startTime: "35m",
      exec: "userJourney",
    },
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
      maxVUs: 150,
      startTime: "55m",
      exec: "userJourney",
    },
    soak: {
      executor: "constant-arrival-rate",
      rate: 20,
      timeUnit: "1s",
      duration: "1h",
      preAllocatedVUs: 10,
      maxVUs: 50,
      startTime: "61m",
      exec: "userJourney",
    },
  },
};
