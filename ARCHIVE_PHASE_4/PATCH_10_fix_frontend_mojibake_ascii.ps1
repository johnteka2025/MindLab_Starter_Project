# C:\Projects\MindLab_Starter_Project\PATCH_10_fix_frontend_mojibake_ascii.ps1
# Fix: Remove mojibake by using ASCII-only UI strings in Daily Challenge components.
# Golden Rules: absolute paths, backups, sanity build, return to project root.

$ErrorActionPreference = "Stop"

$projectRoot  = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $projectRoot "frontend"

$homeCardPath = Join-Path $frontendRoot "src\daily-challenge\DailyChallengeHomeCard.tsx"
$dailyPagePath = Join-Path $frontendRoot "src\daily-challenge\DailyChallengeDetailPage.tsx"

function Assert-FileExists([string]$p) {
  if (-not (Test-Path $p)) { throw "Missing required file: $p" }
}

try {
  if (-not (Test-Path $projectRoot)) { throw "Project root not found: $projectRoot" }
  if (-not (Test-Path $frontendRoot)) { throw "Frontend root not found: $frontendRoot" }

  Assert-FileExists $homeCardPath
  Assert-FileExists $dailyPagePath

  # Backups
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $homeCardPath ($homeCardPath + ".bak_ascii_" + $ts) -Force
  Copy-Item $dailyPagePath ($dailyPagePath + ".bak_ascii_" + $ts) -Force
  Write-Host "Backups created (timestamp $ts)" -ForegroundColor Green

  # Replace DailyChallengeHomeCard.tsx (ASCII only)
  $homeCard = @'
import React, { useEffect, useState } from "react";
import { fetchDailyStatus, type DailyChallengeStatus } from "./dailyChallengeApi";

/**
 * Small card to show Daily Challenge status on the home page.
 * ASCII-only text to avoid encoding/mojibake issues across environments.
 */
export function DailyChallengeHomeCard() {
  const [status, setStatus] = useState<DailyChallengeStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const result = await fetchDailyStatus();
        if (!cancelled) {
          setStatus(result);
          setLoading(false);
        }
      } catch (err: any) {
        if (!cancelled) {
          setError(err?.message ?? "Unable to load Daily Challenge status.");
          setLoading(false);
        }
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const handleOpenClick = () => {
    window.location.href = "/app/daily";
  };

  let body: React.ReactNode;

  if (loading) {
    body = <p>Loading Daily Challenge...</p>;
  } else if (error) {
    body = <p style={{ color: "crimson" }}>Daily Challenge status unavailable: {error}</p>;
  } else if (status) {
    const friendlyStatus =
      status.status === "completed"
        ? "Completed"
        : status.status === "in_progress"
        ? "In progress"
        : "Not started";

    body = (
      <>
        <p>
          Today: <strong>{status.challengeDate}</strong> - Band{" "}
          <strong>{status.band}</strong>
        </p>
        <p style={{ marginTop: 6 }}>
          Progress:{" "}
          <strong>
            {status.puzzlesCompletedToday} / {status.totalPuzzlesForToday}
          </strong>{" "}
          puzzles
        </p>
        <p style={{ marginTop: 6 }}>
          Streak: <strong>{status.streakCount}</strong> day
          {status.streakCount === 1 ? "" : "s"}
        </p>
        <p style={{ marginTop: 10, fontWeight: 700 }}>
          Status: <span>{friendlyStatus}</span>
        </p>
      </>
    );
  } else {
    body = <p>No Daily Challenge information available.</p>;
  }

  return (
    <section style={{ border: "1px solid #ddd", borderRadius: 12, padding: 16 }}>
      <h2 style={{ marginTop: 0 }}>Daily Challenge</h2>
      {body}
      <button type="button" onClick={handleOpenClick} style={{ marginTop: 12 }}>
        Open Daily Challenge
      </button>
    </section>
  );
}

export default DailyChallengeHomeCard;
'@
  Set-Content -Path $homeCardPath -Value $homeCard -Encoding UTF8
  Write-Host "Replaced: $homeCardPath" -ForegroundColor Green

  # Replace DailyChallengeDetailPage.tsx: change the solved marker from ✓ to ASCII "[SOLVED]"
  $dailyPage = @'
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
'@
  Set-Content -Path $dailyPagePath -Value $dailyPage -Encoding UTF8
  Write-Host "Replaced: $dailyPagePath" -ForegroundColor Green

  # Sanity build
  Set-Location $frontendRoot
  Write-Host "Running frontend build sanity..." -ForegroundColor Cyan
  npm run build

  Write-Host "PATCH_10 GREEN: ASCII-only Daily UI markers applied." -ForegroundColor Green
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
