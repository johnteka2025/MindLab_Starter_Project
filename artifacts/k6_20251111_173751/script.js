import http from 'k6/http';
import { check, sleep } from 'k6';
export const options = { vus: 20, duration: '30s',
  thresholds: { http_req_failed: ['rate<0.02'], http_req_duration: ['p(95)<400'] } };
export default function () {
  const res = http.get('http://host.docker.internal:8085/api/health', { timeout: '5s' });
  check(res, { 'status 200': (r) => r.status === 200 });
  sleep(0.25);
}
