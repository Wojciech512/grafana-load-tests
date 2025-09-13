import http, { RefinedResponse, ResponseType, RefinedParams } from "k6/http";
import { sleep, check } from "k6";
import exec from "k6/execution";

/* ===== Konfiguracja Grafana Annotations ===== */
const ORG_ID = __ENV.GRAFANA_ORG_ID || "";
const DASH_IDS = (
  __ENV.DASHBOARD_IDS_TO_ANNOTATE ||
  __ENV.DASHBOARD_ID ||
  "4,10"
)
  .split(",")
  .filter(Boolean)
  .map((s) => parseInt(s.trim(), 10));

const RAW = __ENV.GRAFANA_URL || "grafana:3000";
const BASE_URL_ANN =
  RAW.startsWith("http://") || RAW.startsWith("https://")
    ? RAW.replace(/\/+$/, "")
    : `http://${RAW}`.replace(/\/+$/, "");
const ANN_URL = `${BASE_URL_ANN}/api/annotations`;

const TOKEN = __ENV.GRAFANA_TOKEN;
const ANN_HDRS = {
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${TOKEN}`,
    ...(ORG_ID ? { "X-Grafana-Org-Id": ORG_ID } : {}),
  },
};

// wysyłka tej samej adnotacji na wszystkie wskazane dashboardy
function postAnnAll(base: any) {
  for (const id of DASH_IDS) {
    const body = { ...base, dashboardId: id };
    const r = http.post(ANN_URL, JSON.stringify(body), ANN_HDRS);
    if (r.status !== 200)
      console.error("Annotation POST failed", id, r.status, r.body);
  }
}

/* ===== Czas i harmonogram ===== */
const MIN = 60_000;
const GAP_BETWEEN_TESTS_MIN = Number(__ENV.BREAK_BETWEEN_TESTS || "3");
const GAP_BETWEEN = GAP_BETWEEN_TESTS_MIN * MIN;
const BREAK_BETWEEN_SETS = Number(__ENV.BREAK_BETWEEN_SETS) * MIN;
const ALIGN_DELAY_MS = (60_000 - (Date.now() % 60_000)) % 60_000;

const DUR = {
  cold: 5_000,
  steady: 30 * MIN,
  stress: (5 + 5 + 5 + 5 + 2) * MIN, // 22 m
  spike: (10 + 5 * 60 + 30) * 1000, // 5m40s
  soak: 60 * MIN, // 1 h
};

const LOAD = {
  steady: { rate: 80, preVUs: 40, maxVUs: 160 },
  stress: { start: 60, steps: [180, 260, 340, 420], preVUs: 60, maxVUs: 520 },
  spike: { target: 500, preVUs: 80, maxVUs: 560 },
  soak: { rate: 50, preVUs: 25, maxVUs: 180 },
};

const toK6 = (ms: number) =>
  `${Math.floor(ms / MIN)}m${Math.floor((ms % MIN) / 1000)}s`;
const ceilMin = (ms: number) => Math.ceil(ms / MIN) * MIN;

/* ===== Definicja scenariuszy ===== */
type ScDef = {
  name: string;
  label: "cold_start" | "steady_load" | "stress" | "spike" | "soak";
  startMs: number;
  durMs: number;
  k6: any;
};

function makeSet(
  setIdx: number,
  t0: number,
): { items: ScDef[]; endMs: number } {
  const tag = (b: ScDef["label"]) => `${b}_s${setIdx}`;
  const items: ScDef[] = [];
  let t = ceilMin(t0);

  items.push({
    name: tag("cold_start"),
    label: "cold_start",
    startMs: t,
    durMs: DUR.cold,
    k6: {
      executor: "per-vu-iterations",
      vus: 1,
      iterations: 1,
      exec: "userJourney",
      startTime: toK6(t),
      gracefulStop: "0s",
    },
  });
  t = ceilMin(t + DUR.cold + GAP_BETWEEN);

  items.push({
    name: tag("steady_load"),
    label: "steady_load",
    startMs: t,
    durMs: DUR.steady,
    k6: {
      executor: "constant-arrival-rate",
      rate: LOAD.steady.rate,
      timeUnit: "1s",
      duration: "30m",
      preAllocatedVUs: LOAD.steady.preVUs,
      maxVUs: LOAD.steady.maxVUs,
      exec: "userJourney",
      startTime: toK6(t),
      gracefulStop: "0s",
    },
  });
  t = ceilMin(t + DUR.steady + GAP_BETWEEN);

  items.push({
    name: tag("stress"),
    label: "stress",
    startMs: t,
    durMs: DUR.stress,
    k6: {
      executor: "ramping-arrival-rate",
      startRate: LOAD.stress.start,
      timeUnit: "1s",
      stages: [
        { target: LOAD.stress.steps[0], duration: "5m" },
        { target: LOAD.stress.steps[1], duration: "5m" },
        { target: LOAD.stress.steps[2], duration: "5m" },
        { target: LOAD.stress.steps[3], duration: "5m" },
        { target: 0, duration: "2m" },
      ],
      preAllocatedVUs: LOAD.stress.preVUs,
      maxVUs: LOAD.stress.maxVUs,
      exec: "userJourney",
      startTime: toK6(t),
      gracefulStop: "0s",
    },
  });
  t = ceilMin(t + DUR.stress + GAP_BETWEEN);

  items.push({
    name: tag("spike"),
    label: "spike",
    startMs: t,
    durMs: DUR.spike,
    k6: {
      executor: "ramping-arrival-rate",
      startRate: 0,
      timeUnit: "1s",
      stages: [
        { target: LOAD.spike.target, duration: "10s" },
        { target: LOAD.spike.target, duration: "5m" },
        { target: 0, duration: "30s" },
      ],
      preAllocatedVUs: LOAD.spike.preVUs,
      maxVUs: LOAD.spike.maxVUs,
      exec: "userJourney",
      startTime: toK6(t),
      gracefulStop: "0s",
    },
  });
  t = ceilMin(t + DUR.spike + GAP_BETWEEN);

  items.push({
    name: tag("soak"),
    label: "soak",
    startMs: t,
    durMs: DUR.soak,
    k6: {
      executor: "constant-arrival-rate",
      rate: LOAD.soak.rate,
      timeUnit: "1s",
      duration: "1h",
      preAllocatedVUs: LOAD.soak.preVUs,
      maxVUs: LOAD.soak.maxVUs,
      exec: "userJourney",
      startTime: toK6(t),
      gracefulStop: "0s",
    },
  });

  return { items, endMs: t + DUR.soak };
}

/* ===== 3 zbiory ===== */
const set1 = makeSet(1, ALIGN_DELAY_MS);
const set2 = makeSet(2, set1.endMs + BREAK_BETWEEN_SETS);
const set3 = makeSet(3, set2.endMs + BREAK_BETWEEN_SETS);
const ALL: ScDef[] = [...set1.items, ...set2.items, ...set3.items];
const TOTAL_END_MS = ALL[ALL.length - 1].startMs + ALL[ALL.length - 1].durMs;

/* ===== Scenariusze k6 ===== */
const scenarios: Record<string, any> = {};
for (const s of ALL) scenarios[s.name] = s.k6;

/* ===== Setup/teardown + adnotacje ===== */
let start = 0;

export function setup() {
  const t0 = Date.now();
  start = t0 + ALIGN_DELAY_MS;

  postAnnAll({
    time: start,
    tags: ["test_start"],
    text: `k6 ${__ENV.CLOUD_PROVIDER} run started`,
  });

  for (const s of ALL) {
    postAnnAll({
      time: t0 + s.startMs,
      timeEnd: t0 + s.startMs + s.durMs,
      tags: [s.label, __ENV.CLOUD_PROVIDER],
      text: `Running: ${s.name}`,
    });
  }
}

export function teardown() {
  postAnnAll({
    time: start,
    timeEnd: start + TOTAL_END_MS,
    tags: ["test_end", `run_id=${__ENV.RUN_ID}`],
    text: `k6 ${__ENV.CLOUD_PROVIDER} zakończony; maxVUs=${exec.instance.vusInitialized}`,
  });
}

/* ===== Scenariusz użytkownika ===== */
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
    postAnnAll({
      time: Date.now(),
      tags: ["test_crash", `run_id=${__ENV.RUN_ID}`],
      text: `k6 crash: ${err.message}`,
    });
    throw err;
  }
}

/* ===== Opcje k6 ===== */
export const options = {
  thresholds: {
    http_reqs: ["rate>=30"],
    http_req_failed: ["rate<=0.01"],
    http_req_duration: ["p(95)<800", "p(99)<1500"],
    checks: ["rate>=0.95"],
    data_sent: ["rate>0"],
    data_received: ["rate>0"],
    iterations: ["count>0"],
    vus: ["value<=600"],
    vus_max: ["value<=600"],
    dropped_iterations: ["count==0"],
    iteration_duration: ["p(95)<2000"],
    http_req_blocked: ["avg<100"],
    http_req_connecting: ["avg<100"],
    http_req_waiting: ["avg<500"],
    http_req_sending: ["avg<200"],
    http_req_receiving: ["avg<200"],
    http_req_tls_handshaking: ["avg<200"],
  },
  scenarios,
};
