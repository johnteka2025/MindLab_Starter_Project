import React, { useEffect, useMemo, useState } from "react";
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

  // Solved state from backend
  const [solvedMap, setSolvedMap] = useState<Record<string, boolean>>({});

  async function refreshProgress() {
    const p = await apiGet<ProgressState>("/progress");
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
        if (list.length > 0) setSelectedId(String(list[0].id));
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
  }, []);

  const selectedPuzzle = useMemo(() => {
    if (!selectedId) return null;
    return puzzles.find((p) => String(p.id) === selectedId) ?? null;
  }, [puzzles, selectedId]);

  const selectedIsSolved = selectedPuzzle ? !!solvedMap[String(selectedPuzzle.id)] : false;

  async function markSolved() {
    if (!selectedPuzzle) return;

    setSolveLoading(true);
    setSolveError(null);
    setSolveOk(null);

    try {
      const res = await apiPost<ProgressSolveResponse>("/progress/solve", {
        puzzleId: selectedPuzzle.id,
      });

      const returnedSolved = res?.progress?.solvedIds;
      if (returnedSolved && Array.isArray(returnedSolved)) {
        setSolvedMap(normalizeIds(returnedSolved));
      } else {
        await refreshProgress();
      }

      const solvedNow = res?.progress?.solved;
      const totalNow = res?.progress?.total;

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

      {loading && <p data-testid="daily-loading">Loading...</p>}

      {!loading && error && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          Failed to load daily challenge. ({error})
        </p>
      )}

      {!loading && !error && (
        <>
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

              <button data-testid="daily-mark-solved" onClick={markSolved} disabled={solveLoading || selectedIsSolved}>
                {selectedIsSolved ? "Solved" : solveLoading ? "Recording..." : "Mark Solved"}
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
                Next: open <a href="/app/progress">Progress</a> to see updated totals.
              </p>
            </div>
          )}
        </>
      )}
    </div>
  );
}
