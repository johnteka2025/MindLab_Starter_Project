import React, { useEffect, useState } from "react";

type ProgressData = {
  total: number;
  solved: number;
};

const ProgressPage: React.FC = () => {
  const [data, setData] = useState<ProgressData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadProgress() {
      try {
        const res = await fetch("http://localhost:8085/progress");
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const json = (await res.json()) as ProgressData;
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
    <main style={{ padding: "1.5rem" }}>
      <h1>Daily Progress</h1>

      {loading && <p>Loading progress…</p>}

      {error && (
        <p style={{ color: "red" }}>
          Error: {error}
        </p>
      )}

      {data && !loading && !error && (
        <ul>
          <li>Total puzzles: {data.total}</li>
          <li>Solved: {data.solved}</li>
        </ul>
      )}
    </main>
  );
};

export default ProgressPage;
