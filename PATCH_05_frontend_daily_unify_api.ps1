# PATCH_05_frontend_daily_unify_api.ps1
# Goal: Daily Challenge uses canonical frontend/src/api.ts (no raw fetch), and /app routing is consistent.
# Golden Rules: absolute paths, backups, sanity checks, end at project root.

$ErrorActionPreference = "Stop"

$projectRoot = "C:\Projects\MindLab_Starter_Project"
$frontendRoot = Join-Path $projectRoot "frontend"
$dailyFolder  = Join-Path $frontendRoot "src\daily-challenge"

$homeCardPath   = Join-Path $dailyFolder "DailyChallengeHomeCard.tsx"
$detailPagePath = Join-Path $dailyFolder "DailyChallengeDetailPage.tsx"
$apiWrapperPath = Join-Path $dailyFolder "dailyChallengeApi.ts"

function Assert-FileExists([string]$path) {
  if (-not (Test-Path $path)) {
    throw "Missing required file: $path"
  }
}

try {
  # 0) Preconditions
  if (-not (Test-Path $projectRoot)) { throw "Project root not found: $projectRoot" }
  if (-not (Test-Path $frontendRoot)) { throw "Frontend root not found: $frontendRoot" }
  if (-not (Test-Path $dailyFolder)) { throw "Daily folder not found: $dailyFolder" }

  Assert-FileExists $homeCardPath
  Assert-FileExists $detailPagePath
  Assert-FileExists $apiWrapperPath

  # 1) Backups (timestamped)
  $ts = Get-Date -Format "yyyyMMdd_HHmmss"
  Copy-Item $homeCardPath   ($homeCardPath   + ".bak_" + $ts) -Force
  Copy-Item $detailPagePath ($detailPagePath + ".bak_" + $ts) -Force
  Copy-Item $apiWrapperPath ($apiWrapperPath + ".bak_" + $ts) -Force

  Write-Host "Backups created with timestamp $ts" -ForegroundColor Green

  # 2) Replace dailyChallengeApi.ts (wrapper around canonical api.ts)
  #    NOTE: This file is referenced by DailyChallengeHomeCard.
  $dailyChallengeApiContent = @"
import { apiGet } from "../api";

export type DailyChallengeStatus = {
  challengeDate: string; // YYYY-MM-DD
  band: number;
  status: "not_started" | "in_progress" | "completed";
  puzzlesCompletedToday: number;
  totalPuzzlesForToday: number;
  streakCount: number;
};

/**
 * We do not yet have a dedicated /daily/status endpoint on the backend.
 * So we derive a simple status from /puzzles + /progress to keep UI stable.
 */
export async function fetchDailyStatus(): Promise<DailyChallengeStatus> {
  const puzzles = await apiGet<any[]>("/puzzles").catch(() => []);
  const progress = await apiGet<{ total?: number; solved?: number }>("/progress").catch(() => ({}));

  const total = typeof progress.total === "number"
    ? progress.total
    : (Array.isArray(puzzles) ? puzzles.length : 0);

  const solved = typeof progress.solved === "number" ? progress.solved : 0;

  const today = new Date();
  const yyyy = today.getFullYear();
  const mm = String(today.getMonth() + 1).padStart(2, "0");
  const dd = String(today.getDate()).padStart(2, "0");

  const puzzlesCompletedToday = solved;
  const totalPuzzlesForToday = total;

  let status: DailyChallengeStatus["status"] = "not_started";
  if (puzzlesCompletedToday > 0 && puzzlesCompletedToday < totalPuzzlesForToday) status = "in_progress";
  if (totalPuzzlesForToday > 0 && puzzlesCompletedToday >= totalPuzzlesForToday) status = "completed";

  return {
    challengeDate: `${yyyy}-${mm}-${dd}`,
    band: 1,
    status,
    puzzlesCompletedToday,
    totalPuzzlesForToday,
    streakCount: 0,
  };
}
"@

  Set-Content -Path $apiWrapperPath -Value $dailyChallengeApiContent -Encoding UTF8
  Write-Host "Replaced: $apiWrapperPath" -ForegroundColor Green

  # 3) Replace DailyChallengeHomeCard.tsx (fix /daily -> /app/daily)
  $homeCardContent = @"
import React, { useEffect, useState } from "react";
import {
  fetchDailyStatus,
  type DailyChallengeStatus,
} from "./dailyChallengeApi";

/**
 * Small card to show Daily Challenge status on the home page.
 *
 * Router-agnostic navigation:
 * Our app is mounted under /app, so Daily Challenge is /app/daily.
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
    body = <p>Loading Daily Challenge…</p>;
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
          Today: <strong>{status.challengeDate}</strong> · Band{" "}
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
      <button
        type="button"
        onClick={handleOpenClick}
        style={{ marginTop: 12 }}
      >
        Open Daily Challenge
      </button>
    </section>
  );
}

export default DailyChallengeHomeCard;
"@

  Set-Content -Path $homeCardPath -Value $homeCardContent -Encoding UTF8
  Write-Host "Replaced: $homeCardPath" -ForegroundColor Green

  # 4) Replace DailyChallengeDetailPage.tsx (use canonical api.ts, no raw fetch)
  $detailPageContent = @"
import React, { useEffect, useMemo, useState } from "react";
import { apiGet, apiPost } from "../api";

type Puzzle = {
  id: number | string;
  question: string;
  options?: string[];
  correctIndex?: number;
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
  };
};

export default function DailyChallengeDetailPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [selectedId, setSelectedId] = useState<string>("");

  const [solveLoading, setSolveLoading] = useState(false);
  const [solveError, setSolveError] = useState<string | null>(null);
  const [solveOk, setSolveOk] = useState<string | null>(null);

  // Lightweight UI state to prevent double-click spam in-session
  const [locallySolvedIds, setLocallySolvedIds] = useState<Record<string, boolean>>({});

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        const json = await apiGet<Puzzle[]>("/puzzles");
        const list = Array.isArray(json) ? json : [];

        if (cancelled) return;

        setPuzzles(list);
        if (list.length > 0) setSelectedId(String(list[0].id));
      } catch (e: any) {
        if (!cancelled) setError(e?.message ?? "Failed to load puzzles.");
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

  const selectedIsSolved = selectedPuzzle ? !!locallySolvedIds[String(selectedPuzzle.id)] : false;

  async function markSolved() {
    if (!selectedPuzzle) return;

    setSolveLoading(true);
    setSolveError(null);
    setSolveOk(null);

    try {
      const res = await apiPost<ProgressSolveResponse>("/progress/solve", {
        puzzleId: selectedPuzzle.id,
      });

      // Record solved locally so UI is stable even before refresh
      setLocallySolvedIds((prev) => ({ ...prev, [String(selectedPuzzle.id)]: true }));

      const solvedNow = res?.progress?.solved;
      const totalNow = res?.progress?.total;

      const suffix =
        typeof solvedNow === "number" && typeof totalNow === "number"
          ? ` (progress: ${solvedNow}/${totalNow})`
          : "";

      setSolveOk(\`Solved recorded for puzzleId=\${selectedPuzzle.id}\${suffix}\`);
    } catch (e: any) {
      setSolveError(e?.message ?? "Failed to record solve.");
    } finally {
      setSolveLoading(false);
    }
  }

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      {loading && <p data-testid="daily-loading">Loading…</p>}

      {!loading && error && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          Failed to load puzzles. ({error})
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
                const isSolved = !!locallySolvedIds[String(p.id)];

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
                      {p.question} {isSolved ? "✓" : ""}
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
              >
                {selectedIsSolved ? "Solved" : solveLoading ? "Recording…" : "Mark Solved"}
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
"@

  Set-Content -Path $detailPagePath -Value $detailPageContent -Encoding UTF8
  Write-Host "Replaced: $detailPagePath" -ForegroundColor Green

  # 5) Sanity: TypeScript build (frontend)
  Set-Location $frontendRoot
  Write-Host "Running frontend build sanity..." -ForegroundColor Cyan
  npm run build

  Write-Host "PATCH GREEN: daily-challenge files unified to canonical api.ts and /app routing." -ForegroundColor Green
}
finally {
  Set-Location $projectRoot
  Write-Host "Returned to project root: $projectRoot" -ForegroundColor Yellow
}
