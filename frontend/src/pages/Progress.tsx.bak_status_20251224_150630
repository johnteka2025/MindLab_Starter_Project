import React, { useEffect, useState } from "react";
import { apiGet, apiPost } from "../api";

type Progress = {
  total: number;
  solved: number;
  solvedIds?: Array<string | number>;
};

export default function ProgressPage() {
  const [progress, setProgress] = useState<Progress | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function load() {
    setError(null);
    try {
      const p = await apiGet<Progress>("/progress");
      setProgress(p);
    } catch (e: any) {
      setError(e?.message ?? "Failed to load progress.");
    }
  }

  async function resetProgress() {
    setBusy(true);
    setError(null);
    try {
      await apiPost("/progress/reset", {});
      await load();
    } catch (e: any) {
      setError(e?.message ?? "Failed to reset progress.");
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  const total = progress?.total ?? 0;
  const solved = progress?.solved ?? 0;
  const pct = total > 0 ? Math.round((solved / total) * 100) : 0;

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Progress</h1>

      {error && <p style={{ color: "crimson" }}>{error}</p>}

      <p>Puzzles solved: {solved} of {total}</p>
      <p>Completion: {pct}%</p>

      <button type="button" onClick={load} disabled={busy}>
        Refresh
      </button>

      <button
        type="button"
        onClick={resetProgress}
        disabled={busy}
        style={{ marginLeft: 8 }}
      >
        {busy ? "Resetting..." : "Reset Progress"}
      </button>
    </div>
  );
}
