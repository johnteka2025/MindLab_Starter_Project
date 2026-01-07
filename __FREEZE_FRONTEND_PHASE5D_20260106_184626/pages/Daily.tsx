import React, { useEffect, useState } from "react";
import { apiGet } from "../api";

type Puzzle = {
  id: number | string;
  question: string;
  options?: string[];
  correctIndex?: number;
};

export default function Daily() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);

      try {
        const json = await apiGet<Puzzle[]>("/puzzles");
        if (!cancelled) setPuzzles(Array.isArray(json) ? json : []);
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

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      {loading && <p data-testid="daily-loading">Loading…</p>}
      {!loading && error && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          {error}
        </p>
      )}

      {!loading && !error && (
        <div style={{ marginTop: 12 }}>
          <h2 style={{ marginBottom: 8 }}>Today’s Puzzles</h2>

          {/* IMPORTANT: this must be visible (NOT hidden) */}
          <ul
            data-testid="daily-puzzles-list"
            style={{
              border: "1px solid #ddd",
              borderRadius: 8,
              padding: 12,
              listStylePosition: "inside",
              margin: 0,
            }}
          >
            {puzzles.length === 0 ? (
              <li data-testid="daily-puzzles-empty">No puzzles available.</li>
            ) : (
              puzzles.map((p) => (
                <li key={String(p.id)} style={{ marginBottom: 6 }}>
                  <span data-testid="daily-puzzle-item">{p.question}</span>
                </li>
              ))
            )}
          </ul>
        </div>
      )}
    </div>
  );
}
