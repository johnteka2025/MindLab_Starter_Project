import React, { useEffect, useState } from "react";

type Progress = { total: number; solved: number };

const API_BASE =
  (import.meta as any).env?.VITE_API_BASE_URL?.toString()?.trim() ||
  "http://localhost:8085";

export default function ProgressPage() {
  const [progress, setProgress] = useState<Progress>({ total: 0, solved: 0 });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>("");

  const loadProgress = async () => {
    setLoading(true);
    setError("");
    try {
      const res = await fetch(`${API_BASE}/progress`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = (await res.json()) as Progress;
      setProgress(data);
    } catch (e: any) {
      setError(`Error loading progress: ${e?.message || "Failed to fetch"}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProgress();
  }, []);

  const completion =
    progress.total > 0 ? Math.round((progress.solved / progress.total) * 100) : 0;

  return (
    <div style={{ padding: "1rem" }}>
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
