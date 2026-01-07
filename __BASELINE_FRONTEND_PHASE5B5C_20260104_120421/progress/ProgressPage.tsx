import React, { useEffect, useState } from "react";
import { apiGet } from "../api";

type ProgressData = {
  total: number;
  solved: number;
};

export default function Progress() {
  const [progress, setProgress] = useState<ProgressData>({ total: 0, solved: 0 });
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  async function loadProgress() {
    try {
      setLoading(true);
      setError(null);

      const data = await apiGet<ProgressData>("/progress");

      const total = Number.isFinite(data?.total) ? Number(data.total) : 0;
      const solved = Number.isFinite(data?.solved) ? Number(data.solved) : 0;

      setProgress({ total, solved });
    } catch (e: any) {
      console.error("Failed to load progress:", e);
      setError("Error loading progress: Failed to fetch");
      setProgress({ total: 0, solved: 0 });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadProgress();
  }, []);

  const completion =
    progress.total > 0 ? Math.round((progress.solved / progress.total) * 100) : 0;

  return (
    <div data-testid="progress-page" style={{ padding: "1.5rem" }}>
      <h1>Daily Progress</h1>

      {loading && <p data-testid="progress-loading">Loading...</p>}

      {error && (
        <p data-testid="progress-error" style={{ color: "red" }}>
          {error}
        </p>
      )}

      {/* IMPORTANT: This text is required for Playwright: /puzzles solved/i */}
      <p data-testid="progress-solved">
        Puzzles solved: {progress.solved} of {progress.total}
      </p>

      <p data-testid="progress-completion">Completion: {completion}%</p>

      <button
        data-testid="progress-refresh"
        style={{ marginTop: "0.75rem" }}
        onClick={loadProgress}
      >
        Refresh
      </button>
    </div>
  );
}
