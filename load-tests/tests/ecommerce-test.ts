import http, { RefinedResponse, ResponseType } from "k6/http";
import { sleep, check } from "k6";
// TODO 4 typy testów obciążeniowych
const BASE_URL = __ENV.BASE_URL || "http://host.docker.internal:8000";

function getCsrfHeaders(pageRes: RefinedResponse<ResponseType>) {
  const csrf = pageRes.cookies["csrftoken"][0].value; // 1. czytamy cookie
  return {
    headers: {
      "Content-Type": "application/x-www-form-urlencoded", // 2. Django oczekuje form-urlencoded
      "X-CSRFToken": csrf, // 3. token w nagłówku
      Cookie: `csrftoken=${csrf}`, // 4. token w ciasteczku
    },
  };
}

export default function userJourney() {
  /* ---------- 1. REJESTRACJA ---------- */
  let page = http.get(`${BASE_URL}/account/register`);
  let headers = getCsrfHeaders(page);

  const regBody = {
    username: `user${__VU}`,
    email: `user${__VU}@test.com`,
    password1: "Test123!",
    password2: "Test123!",
  };

  let res = http.post(`${BASE_URL}/account/register`, regBody, headers);

  check(res, {
    "register success": (r) => r.status === 200 || r.status === 302,
  });

  /* ---------- 2. LOGOWANIE ---------- */
  page = http.get(`${BASE_URL}/account/login`);
  headers = getCsrfHeaders(page);

  const loginBody = { username: `user${__VU}`, password: "Test123!" };

  res = http.post(`${BASE_URL}/account/login`, loginBody, headers);

  check(res, { "login success": (r) => r.status === 200 || r.status === 302 });
  sleep(1);

  /* ---------- 3. PRZEGLĄDANIE PRODUKTU ---------- */
  res = http.get(`${BASE_URL}/product/electronics-produkt-1-41389/`);

  check(res, { "product page ok": (r) => r.status === 200 });
  sleep(1);

  /* ---------- 4. DODANIE DO KOSZYKA ---------- */
  const cartBody = { product_id: "68226", quantity: "1" };

  res = http.post(`${BASE_URL}/cart/`, cartBody, headers);

  check(res, { "added to cart": (r) => r.status === 200 || r.status === 302 });
  sleep(1);

  /* ---------- 5. CHECKOUT ---------- */
  res = http.get(`${BASE_URL}/payment/checkout`);

  check(res, { "checkout page ok": (r) => r.status === 200 });
  sleep(1);

  /* ---------- 6. DASHBOARD KLIENTA ---------- */
  res = http.get(`${BASE_URL}/account/dashboard`);

  check(res, { "user dashboard ok": (r) => r.status === 200 });
  sleep(2);
}
