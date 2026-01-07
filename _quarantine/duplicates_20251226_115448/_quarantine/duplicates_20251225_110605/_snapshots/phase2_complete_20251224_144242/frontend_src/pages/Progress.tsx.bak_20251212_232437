import React, { useEffect, useState } from "react";

type ProgressData = {
  totalPuzzles?: number;
  solvedToday?: number;
  currentStreak?: number;
};

export default function Progress() {
  const [data, setData] = useState<ProgressData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadProgress() {
      try {
        setError(null);
        const res = await fetch("http://localhost:8085/progress");
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const json: ProgressData = await res.json();
        setData(json);
      } catch (err: any) {
        console.error("Failed to load progress:", err);
        setError("Unable to load progress right now.");
      } finally {
        setLoading(false);
      }
    }

    loadProgress();
  }, []);

  return (
    <div style={{ padding: "1.5rem" }}>
      <h1>Progress</h1>

      {loading && <p>Loading progress…</p>}

      {error && (
        <p style={{ color: "red" }}>
          {error}
        </p>
      )}

      {!loading && !error && (
        <div style={{ display: "grid", gap: "1rem", maxWidth: "300px" }}>
          <div>
            <h2>Total puzzles</h2>
            <p data-testid="progress-total-puzzles">
              {data?.totalPuzzles ?? "N/A"}
            </p>
          </div>

          <div>
            <h2>Solved today</h2>
            <p data-testid="progress-solved-today">
              {data?.solvedToday ?? "N/A"}
            </p>
          </div>

          <div>
            <h2>Current streak</h2>
            <p data-testid="progress-current-streak">
              {data?.currentStreak ?? "N/A"}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
