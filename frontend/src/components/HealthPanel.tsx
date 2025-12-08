import React, { useEffect, useState } from "react";

type HealthResponse = {
  ok: boolean;
  status: string;
  message: string;
};

type PuzzlesResponse = {
  id: string;
  question: string;
  options: string[];
  correctIndex: number;
}[];

type ProgressResponse = {
  total: number;
  solved: number;
};

const HealthPanel: React.FC = () => {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [puzzles, setPuzzles] = useState<PuzzlesResponse | null>(null);
  const [progress, setProgress] = useState<ProgressResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadAll() {
      try {
        setError(null);

        // ✅ Always call the real backend on 8085
        const [healthRes, puzzlesRes, progressRes] = await Promise.all([
          fetch("http://localhost:8085/health"),
          fetch("http://localhost:8085/puzzles"),
          fetch("http://localhost:8085/progress"),
        ]);

        if (!healthRes.ok || !puzzlesRes.ok || !progressRes.ok) {
          throw new Error(
            `HTTP error(s): health=${healthRes.status}, puzzles=${puzzlesRes.status}, progress=${progressRes.status}`
          );
        }

        const [healthJson, puzzlesJson, progressJson] = await Promise.all([
          healthRes.json(),
          puzzlesRes.json(),
          progressRes.json(),
        ]);

        setHealth(healthJson);
        setPuzzles(puzzlesJson);
        setProgress(progressJson);
      } catch (err: any) {
        console.error("Error loading dashboard data", err);
        setError(err.message ?? String(err));
      }
    }

    void loadAll();
  }, []);

  return (
    <div>
      <section>
        <h2>Health</h2>
        {error && (
          <p style={{ color: "red" }}>
            Failed to reach backend: {error}
          </p>
        )}
        {health && !error && (
          <p>
            Status: {health.status} – {health.message}
          </p>
        )}
      </section>

      <section>
        <h2>Puzzles</h2>
        {!puzzles && !error && <p>No puzzle loaded.</p>}
        {puzzles && puzzles.length > 0 && (
          <ul>
            {puzzles.map((puzzle) => (
              <li key={puzzle.id}>{puzzle.question}</li>
            ))}
          </ul>
        )}
        {error && <p>Failed to load puzzles.</p>}
      </section>

      <section>
        <h2>Progress</h2>
        {progress && !error && (
          <p>
            {progress.solved} of {progress.total} puzzles solved.
          </p>
        )}
        {error && (
          <p style={{ color: "red" }}>
            Error: {error}
          </p>
        )}
      </section>
    </div>
  );
};

export default HealthPanel;
