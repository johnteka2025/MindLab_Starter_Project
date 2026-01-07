import React, { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { apiGet, apiPost } from "../api";

type Puzzle = {
  id: number | string;
  question: string;
  options?: string[];
  correctIndex?: number;
};

type ProgressState = {
  total: number;
  solved: number;
  streak: number;
  solvedIds?: Array<string | number>;
};

type ProgressSolveResponse = {
  ok?: boolean;
  puzzleId?: string | number | null;
  progress?: {
    total: number;
    solved: number;
    solvedToday?: number;
    totalSolved?: number;
    streak?: number;
    solvedIds?: Array<string | number>;
  };
};

function normalizeIds(ids: Array<string | number> | undefined | null): Record<string, boolean> {
  const map: Record<string, boolean> = {};
  (ids || []).forEach((id) => {
    map[String(id)] = true;
  });
  return map;
}

export default function DailyChallengeDetailPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [selectedId, setSelectedId] = useState<string>("");

  const [solveLoading, setSolveLoading] = useState(false);
  const [solveError, setSolveError] = useState<string | null>(null);
  const [solveOk, setSolveOk] = useState<string | null>(null);

  // Solved state + progress from backend
  const [solvedMap, setSolvedMap] = useState<Record<string, boolean>>({});
  const [progress, setProgress] = useState<ProgressState | null>(null);

  async function refreshProgress() {
    const p = await apiGet<ProgressState>("/progress");
    setProgress(p);
    setSolvedMap(normalizeIds(p?.solvedIds));
    return p;
  }

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        const [puzzlesRes] = await Promise.all([apiGet<Puzzle[]>("/puzzles"), refreshProgress()]);
        if (cancelled) return;

        const list = Array.isArray(puzzlesRes) ? puzzlesRes : [];
        setPuzzles(list);

        // Preserve selected if possible, else select first puzzle
        if (list.length > 0) {
          const existing = list.find((p) => String(p.id) === selectedId);
          setSelectedId(existing ? String(existing.id) : String(list[0].id));
        } else {
          setSelectedId("");
        }
      } catch (e: any) {
        if (!cancelled) setError(e?.message ?? "Failed to load daily challenge data.");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const selectedPuzzle = useMemo(() => {
    if (!selectedId) return null;
    return puzzles.find((p) => String(p.id) === selectedId) ?? null;
  }, [puzzles, selectedId]);

  const selectedIsSolved = selectedPuzzle ? !!solvedMap[String(selectedPuzzle.id)] : false;

  const total = typeof progress?.total === "number" ? progress!.total : 0;
  const solved = typeof progress?.solved === "number" ? progress!.solved : 0;
const streak = typeof progress?.streak === "number" ? progress!.streak : 0;
  const isComplete = total > 0 && solved === total;

  const statusText =
    total <= 0 ? "Status: Unknown" :
    solved <= 0 ? "Status: Not started" :
    solved < total ? "Status: In progress" :
    "Status: Complete";

  async function markSolved() {
    if (!selectedPuzzle) return;

    setSolveLoading(true);
    setSolveError(null);
    setSolveOk(null);

    try {
      const res = await apiPost<ProgressSolveResponse>("/progress/solve", {
        puzzleId: selectedPuzzle.id,
      });

      // Prefer progress returned by POST; otherwise refresh
      const returned = res?.progress;
      if (returned && typeof returned.total === "number" && typeof returned.solved === "number") {
        setProgress({
          total: returned.total,
          solved: returned.solved,
          solvedIds: returned.solvedIds || [],
        });
        setSolvedMap(normalizeIds(returned.solvedIds));
      } else {
        await refreshProgress();
      }

      const solvedNow = returned?.solved;
      const totalNow = returned?.total;

      const suffix =
        typeof solvedNow === "number" && typeof totalNow === "number"
          ? ` (progress: ${solvedNow}/${totalNow})`
          : "";

      setSolveOk(`Solved recorded for puzzleId=${selectedPuzzle.id}${suffix}`);
    } catch (e: any) {
      setSolveError(e?.message ?? "Failed to record solve.");
    } finally {
      setSolveLoading(false);
    }
  }

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      {/* Completion banner (shows ONLY when solved === total) */}
      {!loading && !error && isComplete && (
        <div
          data-testid="daily-complete-banner"
          style={{
            border: "1px solid #2f855a",
            borderRadius: 12,
            padding: 12,
            marginBottom: 12,
            background: "#f0fff4",
          }}
        >
          <p style={{ margin: 0, fontWeight: 700 }}>Daily Challenge Complete!</p>
          <p style={{ margin: "6px 0 0 0" }}>
            You solved all {total} puzzle{total === 1 ? "" : "s"} today.
          </p>
        </div>
      )}

      {loading && <p data-testid="daily-loading">Loading...</p>}

      {!loading && error && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          Failed to load daily challenge. ({error})
        </p>
      )}

      {!loading && !error && (
        <>
          <p style={{ marginTop: 0 }}>
            Progress: <strong>{solved}</strong> / <strong>{total}</strong> {" | "} Streak: <strong>{streak}</strong>
{" "}
<button type="button" onClick={() => { void refreshProgress(); }}>
  Refresh Progress
</button>          </p>

          <p data-testid="daily-status" style={{ marginTop: 0 }}>
            {statusText}
          </p>

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
            {puzzles.length === 0 ? (
              <li data-testid="daily-puzzles-empty">No puzzles available.</li>
            ) : (
              puzzles.map((p) => {
                const isSelected = String(p.id) === selectedId;
                const isSolved = !!solvedMap[String(p.id)];

                return (
                  <li key={String(p.id)} style={{ marginBottom: 6 }}>
                    <button
                      type="button"
                      onClick={() => {
                        setSelectedId(String(p.id));
                        setSolveOk(null);
                        setSolveError(null);
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
                      {p.question} {isSolved ? "[SOLVED]" : ""}
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

              <button
  data-testid="daily-mark-solved"
  onClick={markSolved}
  disabled={solveLoading || selectedIsSolved}
  title={selectedIsSolved ? "Already solved" : solveLoading ? "Saving..." : "Mark as solved"}
>
  {selectedIsSolved ? "Solved" : solveLoading ? "Saving..." : "Mark Solved"}
</button>

              {solveOk && (
                <p data-testid="daily-solve-ok" style={{ marginTop: 10 }}>
                  {solveOk}
                </p>
              )}
              {solveError && (
                <p data-testid="daily-solve-error" style={{ marginTop: 10, color: "crimson" }}>
                  {solveError}
                </p>
              )}

              <p style={{ marginTop: 12 }}>
                Tip: Click Refresh Progress to update totals.
              </p>
            </div>
          )}
        </>
      )}
    </div>
  );
}









