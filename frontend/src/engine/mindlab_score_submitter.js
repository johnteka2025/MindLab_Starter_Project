import { mindlabSafeFetch } from "./mindlab_safe_fetch.js";

export const MINDLAB_SCORE_ENDPOINT = "http://localhost:8085/score";

export async function submitMindLabScore(payload) {
  const body = JSON.stringify({
    sessionId: payload?.sessionId ?? "default-session",
    scoreDelta: Number(payload?.scoreDelta ?? 0),
    result: payload?.result ?? "unknown",
    puzzleId: payload?.puzzleId ?? null,
    metadata: payload?.metadata ?? {}
  });

  return await mindlabSafeFetch(MINDLAB_SCORE_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body
  });
}
