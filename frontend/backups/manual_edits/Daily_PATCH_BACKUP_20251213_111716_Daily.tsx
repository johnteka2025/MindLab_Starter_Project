import React, { useEffect, useMemo, useState } from "react";

type Puzzle = {
  id: string;
  question: string;
  answer?: string;
  options?: string[];
};

type DailyResponse = {
  puzzles?: Puzzle[];
  puzzle?: Puzzle;
};

const API_BASE = "http://localhost:8085";

export default function Daily() {
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [selectedPuzzleId, setSelectedPuzzleId] = useState<string | null>(null);

  const [answerInput, setAnswerInput] = useState("");
  const [feedback, setFeedback] = useState<string | null>(null);

  const selectedPuzzle = useMemo(() => {
    if (!selectedPuzzleId) return null;
    return puzzles.find((p) => p.id === selectedPuzzleId) ?? null;
  }, [puzzles, selectedPuzzleId]);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setLoadError(null);
      setFeedback(null);

      try {
        // Try /daily first (preferred)
        const dailyRes = await fetch(`${API_BASE}/daily`);
        if (dailyRes.ok) {
          const dailyJson = (await dailyRes.json()) as DailyResponse;

          const fromDaily =
            dailyJson.puzzles ??
            (dailyJson.puzzle ? [dailyJson.puzzle] : []);

          if (!cancelled) {
            setPuzzles(Array.isArray(fromDaily) ? fromDaily : []);
            setSelectedPuzzleId(
              Array.isArray(fromDaily) && fromDaily.length > 0 ? fromDaily[0].id : null
            );
          }
          return;
        }

        // Fallback to /puzzles
        const puzzlesRes = await fetch(`${API_BASE}/puzzles`);
        if (!puzzlesRes.ok) {
          throw new Error(`Backend responded ${puzzlesRes.status} for /puzzles`);
        }
        const puzzlesJson = (await puzzlesRes.json()) as Puzzle[];
        if (!cancelled) {
          setPuzzles(Array.isArray(puzzlesJson) ? puzzlesJson : []);
          setSelectedPuzzleId(
            Array.isArray(puzzlesJson) && puzzlesJson.length > 0 ? puzzlesJson[0].id : null
          );
        }
      } catch (e: any) {
        if (!cancelled) {
          setLoadError(e?.message ?? "Failed to load daily puzzles.");
          setPuzzles([]);
          setSelectedPuzzleId(null);
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  function onSelectPuzzle(id: string) {
    setSelectedPuzzleId(id);
    setAnswerInput("");
    setFeedback(null);
  }

  function onSubmitAnswer(e: React.FormEvent) {
    e.preventDefault();
    if (!selectedPuzzle) return;

    // Simple client-side check if answer exists; otherwise just acknowledge submission.
    const expected = (selectedPuzzle.answer ?? "").trim().toLowerCase();
    const got = answerInput.trim().toLowerCase();

    if (expected.length === 0) {
      setFeedback("Answer submitted.");
      return;
    }

    if (got === expected) setFeedback("Correct!");
    else setFeedback("Try again.");
  }

  return (
    <div style={{ padding: 16 }}>
      <h1>Daily Challenge</h1>

      {loading && <p data-testid="daily-loading">Loading…</p>}

      {!loading && loadError && (
        <p data-testid="daily-error" style={{ color: "crimson" }}>
          {loadError}
        </p>
      )}

      {!loading && !loadError && (
        <>
          <div style={{ marginTop: 12 }}>
            <h2 style={{ marginBottom: 8 }}>Today’s Puzzles</h2>

            <div
              data-testid="daily-puzzles-list"
              style={{
                border: "1px solid #ddd",
                borderRadius: 8,
                padding: 12,
              }}
            >
              {puzzles.length === 0 ? (
                <p data-testid="daily-puzzles-empty">No puzzles available.</p>
              ) : (
                <ul style={{ margin: 0, paddingLeft: 18 }}>
                  {puzzles.map((p) => (
                    <li key={p.id} style={{ marginBottom: 6 }}>
                      <button
                        type="button"
                        data-testid="daily-puzzle-item"
                        onClick={() => onSelectPuzzle(p.id)}
                        style={{
                          background: "transparent",
                          border: "none",
                          padding: 0,
                          cursor: "pointer",
                          textAlign: "left",
                        }}
                      >
                        {p.question}
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>

          {selectedPuzzle && (
            <div style={{ marginTop: 16 }}>
              <h2>Selected Puzzle</h2>
              <p data-testid="daily-selected-question">{selectedPuzzle.question}</p>

              <form onSubmit={onSubmitAnswer}>
                <label style={{ display: "block", marginBottom: 6 }}>
                  Your answer:
                </label>
                <input
                  data-testid="daily-answer-input"
                  value={answerInput}
                  onChange={(e) => setAnswerInput(e.target.value)}
                  style={{ padding: 8, width: "100%", maxWidth: 420 }}
                />
                <div style={{ marginTop: 10 }}>
                  <button data-testid="daily-submit" type="submit">
                    Submit
                  </button>
                </div>
              </form>

              {feedback && (
                <p data-testid="daily-feedback" style={{ marginTop: 10 }}>
                  {feedback}
                </p>
              )}
            </div>
          )}
        </>
      )}
    </div>
  );
}
