export const API_BASE = import.meta.env.VITE_API_BASE || "http://127.0.0.1:8085";

async function http(path: string, init?: RequestInit) {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { "Content-Type": "application/json", ...(init?.headers || {}) },
    ...init,
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}

export const api = {
  health: () => http("/health"),
  register: (email: string, password: string) =>
    http("/auth/register", { method: "POST", body: JSON.stringify({ email, password }) }),
  login: (email: string, password: string) =>
    http("/auth/login", { method: "POST", body: JSON.stringify({ email, password }) }),
  nextPuzzle: (t: string) =>
    http("/puzzles/next?mode=mixed&level=1", { headers: { Authorization: `Bearer ${t}` } }),
  world: (t: string) =>
    http("/world/state", { headers: { Authorization: `Bearer ${t}` } }),
};
