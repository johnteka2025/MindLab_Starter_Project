
export type MindLabPuzzle = {
  id: string;
  title?: string;
  prompt?: string;
  question?: string;
  category?: string;
  ageCategory?: string;
  difficulty?: string;
  choices?: string[];
  options?: string[];
};

export type MindLabSession = {
  id?: string;
  sessionId?: string;
  [key: string]: unknown;
};

const API_BASE =
  import.meta.env.VITE_FRONTEND_API_BASE_URL ||
  import.meta.env.VITE_API_BASE_URL ||
  "https://mindlab-backend.onrender.com";

async function requestJson<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(API_BASE + path, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(init?.headers || {}),
    },
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`API ${response.status} ${response.statusText}: ${text}`);
  }

  return response.json() as Promise<T>;
}

export async function getHealth() {
  return requestJson<{ ok?: boolean; status?: string }>("/api/health");
}

export async function getPuzzles() {
  const data = await requestJson<MindLabPuzzle[] | { puzzles?: MindLabPuzzle[] }>("/api/puzzles");
  return Array.isArray(data) ? data : data.puzzles || [];
}

export async function getPuzzle(id: string) {
  return requestJson<MindLabPuzzle>("/api/puzzles/" + encodeURIComponent(id));
}

export async function createSession(ageCategory: string) {
  return requestJson<MindLabSession>("/api/sessions", {
    method: "POST",
    body: JSON.stringify({ ageCategory }),
  });
}

export async function submitAnswer(payload: {
  sessionId: string;
  puzzleId: string;
  answer: string;
}) {
  return requestJson<Record<string, unknown>>("/api/answers", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function getProgress(sessionId?: string) {
  const suffix = sessionId ? "?sessionId=" + encodeURIComponent(sessionId) : "";
  return requestJson<Record<string, unknown>>("/api/progress" + suffix);
}

export function sessionIdOf(session: MindLabSession) {
  return String(session.sessionId || session.id || "");
}

export function puzzleTextOf(puzzle: MindLabPuzzle) {
  return puzzle.prompt || puzzle.question || puzzle.title || "Untitled puzzle";
}

export function puzzleChoicesOf(puzzle: MindLabPuzzle) {
  return puzzle.choices || puzzle.options || [];
}

