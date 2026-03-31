export const API_BASE = "http://localhost:8085";

export async function getDailyStatus() {
  const res = await fetch(`${API_BASE}/daily/status`);
  if (!res.ok) throw new Error(`daily/status failed: ${res.status}`);
  return res.json();
}

export async function submitAnswer(answer) {
  const res = await fetch(`${API_BASE}/daily/answer`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ answer })
  });
  if (!res.ok) throw new Error(`daily/answer failed: ${res.status}`);
  return res.json();
}
