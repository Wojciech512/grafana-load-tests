import http from 'k6/http';
import { sleep, check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://host.docker.internal:8000';

// Funkcja symulująca sesję zwykłego użytkownika (klienta sklepu)
export default function userJourney() {
  // 1. Rejestracja nowego użytkownika
  const regPayload = JSON.stringify({username: `user${__VU}`, password: 'test123', email: `user${__VU}@test.com`});
  const regHeaders = { headers: { 'Content-Type': 'application/json' } };
  let res = http.post(`${BASE_URL}/account/register`, regPayload, regHeaders);
  check(res, { 'register success': (r) => r.status === 201 });  // oczekujemy 201 Created

  // 2. Logowanie nowo zarejestrowanego użytkownika
  const loginPayload = JSON.stringify({username: `user${__VU}`, password: 'test123'});
  res = http.post(`${BASE_URL}/account/login`, loginPayload, regHeaders);
  check(res, { 'login success': (r) => r.status === 200 });  // oczekujemy 200 OK (dashboard po zalogowaniu)
  sleep(1); // krótka pauza po zalogowaniu

  // 3. Przeglądanie strony produktu
  res = http.get(`${BASE_URL}/product/electronics-produkt-1-68226/`);
  check(res, { 'product page ok': (r) => r.status === 200 });
  sleep(1);

  // 4. Dodanie produktu do koszyka
  res = http.post(`${BASE_URL}/cart/`, JSON.stringify({ product_id: 68226, quantity: 1 }), regHeaders);
  check(res, { 'added to cart': (r) => r.status === 200 });
  sleep(1);

  // 5. Przejście do płatności (checkout)
  res = http.get(`${BASE_URL}/payment/checkout`);
  check(res, { 'checkout page ok': (r) => r.status === 200 });
  sleep(1);

  // 6. Wejście na dashboard klienta (po zakupie lub dla sprawdzenia statusu zamówienia)
  res = http.get(`${BASE_URL}/account/dashboard`);
  check(res, { 'user dashboard ok': (r) => r.status === 200 });
  sleep(2);  // dłuższa pauza - użytkownik przegląda dashboard
}

