import http from "k6/http";
import { check } from "k6";

export const options = { vus: 1, duration: "10s" };

export default function () {
  const res = http.get(`${__ENV.API_BASE}/api/health`);
  check(res, { "status is 200": (r) => r.status === 200 });
}
