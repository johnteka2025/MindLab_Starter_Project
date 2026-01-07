// src/ProgressPanel.tsx

import React, { useEffect, useState } from "react";
import { getProgress, Progress } from "./api";

export const ProgressPanel: React.FC = () => {
  const [progress, setProgress] = useState<Progress | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    setLoading(true);
    setError(null);
    try {
      const r = await getProgress();
      setProgress(r);
    } catch (e) {
      setError("Failed to load progress.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <section aria-label="Progress">
      <h2>Progress</h2>

      {loading && <div aria-live="polite">Loading progress…</div>}

      {error && (
        <div role="alert">
          {error}{" "}
          <button type="button" onClick={load}>
            Retry
          </button>
        </div>
      )}

      {!loading && !error && progress && (
        <div aria-live="polite">
          <p>
            Solved {progress.solvedPuzzles} of {progress.totalPuzzles} puzzles.
          </p>
        </div>
      )}
    </section>
  );
};

export default ProgressPanel;
