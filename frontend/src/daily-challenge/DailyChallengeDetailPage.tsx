import React, { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";

import {
  fetchDaily,
  fetchDailyStatus,
  submitDailyAnswer,
  type DailyChallengeInstance,
  type DailyChallengeStatus,
  type DailyChallengePuzzleSummary,
  type DailyAnswerResponse,
} from "./dailyChallengeApi";

type DifficultyLevel = "easy" | "medium" | "hard";

type DifficultyData = {
  default: DifficultyLevel;
  levels: DifficultyLevel[];
  map: Record<string, DifficultyLevel>;
};

type DifficultyFilter = "all" | DifficultyLevel;

function toDifficultyMap(data: DifficultyData | null): Map<string, DifficultyLevel> {
  const m = new Map<string, DifficultyLevel>();
  if (!data?.map) return m;
  for (const [k, v] of Object.entries(data.map)) {
    m.set(String(k), v);
  }
  return m;
}

function safeString(v: unknown): string {
  return typeof v === "string" ? v : "";
}

export default function DailyChallengeDetailPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [instance, setInstance] = useState<DailyChallengeInstance | null>(null);
  const [status, setStatus] = useState<DailyChallengeStatus | null>(null);

  // UI selection + input
  const [selectedId, setSelectedId] = useState<string>("");
  const [answer, setAnswer] = useState<string>("");

  // In-flight guard for submit
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Submit UX
  const [submitOk, setSubmitOk] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState<string | null>(null);

  // Optional difficulty (fail-open)
  const [difficulty, setDifficulty] = useState<DifficultyData | null>(null);
  const [difficultyFilter, setDifficultyFilter] = useState<DifficultyFilter>("all");

  async function refreshAll() {
    const [inst, st] = await Promise.all([fetchDaily(), fetchDailyStatus()]);
    setInstance(inst);
    setStatus(st);
    return { inst, st };
  }

  useEffect(() => {
    let cancelled = false;

    (async () => {
      setLoading(true);
      setError(null);

      try {
        const { inst } = await refreshAll();
        if (cancelled) return;

        // Set initial selection
        const firstId = inst?.puzzles?.[0]?.id != null ? String(inst.puzzles[0].id) : "";
        setSelectedId(firstId);
        setAnswer("");
      } catch (e: any) {
        if (!cancelled) setError(e?.message ?? "Failed to load daily challenge.");
      } finally {
        if (!cancelled) setLoading(false);
      }

      // Difficulty is optional; do not block Daily page
      try {
        const res = await fetch("/difficulty");
        if (!res.ok) throw new Error("difficulty endpoint unavailable");
        const d = (await res.json()) as DifficultyData;
        if (!cancelled) setDifficulty(d);
      } catch {
        if (!cancelled) setDifficulty(null);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  const diffMap = useMemo(() => toDifficultyMap(difficulty), [difficulty]);

  const puzzles = instance?.puzzles ?? [];

  const filteredPuzzles = useMemo(() => {
    if (difficultyFilter === "all") return puzzles;
    if (!difficulty) return puzzles; // fail-open (do not filter if difficulty missing)

    const target = difficultyFilter;
    return puzzles.filter((p: DailyChallengePuzzleSummary) => {
      const pid = String(p.id);
      const d = diffMap.get(pid) ?? difficulty.default ?? "medium";
      return d === target;
    });
  }, [puzzles, difficultyFilter, difficulty, diffMap]);

  // Keep selection valid when filter changes
  useEffect(() => {
    if (filteredPuzzles.length === 0) {
      setSelectedId("");
      setAnswer("");
      return;
    }
    if (!selectedId) {
      setSelectedId(String(filteredPuzzles[0].id));
      setAnswer("");
      return;
    }
    const exists = filteredPuzzles.some((p) => String(p.id) === selectedId);
    if (!exists) {
      setSelectedId(String(filteredPuzzles[0].id));
      setAnswer("");
    }
  }, [filteredPuzzles, selectedId]);

  const selectedPuzzle = useMemo(() => {
    if (!selectedId) return null;
    return puzzles.find((p) => String(p.id) === selectedId) ?? null;
  }, [puzzles, selectedId]);

  const statusText = useMemo(() => {
    const s = status?.status;
    if (!s) return "Status: Unknown";
    if (s === "not_started") return "Status: Not started";
    if (s === "in_progress") return "Status: In progress";
    if (s === "completed") return "Status: Complete";
    return "Status: Unknown";
  }, [status]);

  async function onSubmit() {
    if (isSubmitting) return;
    if (!selectedPuzzle) return;

    setIsSubmitting(true);
    setSubmitOk(null);
    setSubmitError(null);

    try {
      const res: DailyAnswerResponse = await submitDailyAnswer({
        puzzleId: selectedPuzzle.id,
        answer: answer,
      });

      // Re-fetch from canonical endpoints (single source of truth)
      const { st } = await refreshAll();

      const ok = !!res?.ok;
      if (ok) {
        setSubmitOk(`Answer submitted. Status: ${safeString(st?.status) || "unknown"}`);
      } else {
        setSubmitError("Answer rejected.");
      }
    } catch (e: any) {
      setSubmitError(e?.message ?? "Failed to submit answer.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      {loading && <p data-testid="daily-loading">Loading...</p>}

      {!loading && error && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          {`Failed to load daily challenge. (${error})`}
        </p>
      )}

      {!loading && !error && (
        <>
          <p data-testid="daily-status">{statusText}</p>

          <div style={{ marginTop: 12, marginBottom: 12 }}>
            <label>
              Difficulty filter:{" "}
              <select
                value={difficultyFilter}
                onChange={(e) => setDifficultyFilter(e.target.value as DifficultyFilter)}
                disabled={!difficulty}
              >
                <option value="all">All</option>
                <option value="easy">Easy</option>
                <option value="medium">Medium</option>
                <option value="hard">Hard</option>
              </select>
            </label>
            {!difficulty && (
              <span style={{ marginLeft: 10, opacity: 0.75 }}>
                (difficulty data unavailable — filter disabled)
              </span>
            )}
          </div>

          <h2>Puzzles</h2>

          <ul
            data-testid="daily-puzzles-list"
            style={{
              border: "1px solid #ddd",
              borderRadius: 8,
              padding: 12,
              listStylePosition: "inside",
              margin: 0,
              maxWidth: 720,
            }}
          >
            {filteredPuzzles.length === 0 ? (
              <li data-testid="daily-puzzles-empty">No puzzles available.</li>
            ) : (
              filteredPuzzles.map((p) => {
                const pid = String(p.id);
                const isSelected = pid === selectedId;

                const d: DifficultyLevel | null = difficulty
                  ? diffMap.get(pid) ?? difficulty.default ?? "medium"
                  : null;

                return (
                  <li key={pid} style={{ marginBottom: 6 }}>
                    <button
                      type="button"
                      onClick={() => {
                        setSelectedId(pid);
                        setSubmitOk(null);
                        setSubmitError(null);
                        setAnswer("");
                      }}
                      data-testid="daily-puzzle-item"
                      style={{
                        background: "transparent",
                        border: "none",
                        padding: 0,
                        cursor: "pointer",
                        textAlign: "left",
                        fontWeight: isSelected ? "bold" : "normal",
                      }}
                    >
                      {p.question} {d ? `[${d}]` : ""}
                    </button>
                  </li>
                );
              })
            )}
          </ul>

          {selectedPuzzle && (
            <div style={{ marginTop: 16, maxWidth: 720 }}>
              <h3>Selected</h3>
              <p data-testid="daily-selected-question">{selectedPuzzle.question}</p>

              <div style={{ marginTop: 10 }}>
                <label>
                  Answer:{" "}
                  <input
                    data-testid="daily-answer"
                    value={answer}
                    onChange={(e) => setAnswer(e.target.value)}
                    style={{ width: 320 }}
                    disabled={isSubmitting}
                  />
                </label>

                <button
                  type="button"
                  onClick={onSubmit}
                  disabled={isSubmitting}
                  data-testid="daily-submit"
                  style={{ marginLeft: 10 }}
                >
                  {isSubmitting ? "Submitting…" : "Submit"}
                </button>
              </div>

              {submitOk && (
                <p data-testid="daily-submit-ok" style={{ marginTop: 10 }}>
                  {submitOk}
                </p>
              )}

              {submitError && (
                <p
                  data-testid="daily-submit-error"
                  style={{ marginTop: 10, color: "crimson" }}
                >
                  {submitError}
                </p>
              )}
            </div>
          )}

          <p style={{ marginTop: 12 }}>
            <Link to="/">← Back to Home</Link>
          </p>
        </>
      )}
    </div>
  );
}