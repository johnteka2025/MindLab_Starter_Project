import React, { useEffect, useState } from "react";

type Puzzle = {
  id?: string | number;
  question?: string;
  answer?: string;
};

type DailyResponse = {
  challengeDate?: string;
  dailyChallengeId?: string;
  puzzles?: Puzzle[];
};

const DailyChallengeDetailPage: React.FC = () => {
  const [puzzle, setPuzzle] = useState<Puzzle | null>(null);
  const [answer, setAnswer] = useState("");
  const [feedback, setFeedback] = useState("");
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    async function loadDaily() {
      try {
        setLoading(true);
        setLoadError(null);
        setFeedback("");

        // ✅ Always hit the real backend on 8085
        const res = await fetch("http://localhost:8085/daily");
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }

        const json: DailyResponse = await res.json();

        // Take the first puzzle if a list exists, otherwise fall back to a single puzzle-like object
        const first: Puzzle | null =
          (json.puzzles && json.puzzles.length > 0 && json.puzzles[0]) || null;

        setPuzzle(first);
      } catch (err: any) {
        console.error("Failed to load daily challenge", err);
        setLoadError(err?.message ?? "Unknown error");
      } finally {
        setLoading(false);
      }
    }

    void loadDaily();
  }, []);

  function handleSubmit(evt: React.FormEvent) {
    evt.preventDefault();
    if (!puzzle || !puzzle.answer) return;

    const correct = puzzle.answer.toLowerCase().trim();
    const guess = answer.toLowerCase().trim();

    if (guess === correct) {
      setFeedback("✅ Correct!");
    } else {
      setFeedback("❌ Incorrect. Try again!");
    }
  }

  return (
    <div style={{ padding: "1.5rem" }}>
      {/* 👇 This heading is what the Playwright test looks for (/Daily/i) */}
      <h1>Daily Challenge</h1>
      <p>Daily Challenge</p>

      {loading && <p>Loading daily challenge...</p>}

      {loadError && (
        <p style={{ color: "red" }}>
          {/* keep the same prefix so any existing tests/messages still match */}
          Error loading daily challenge: {loadError}
        </p>
      )}

      {!loading && !loadError && !puzzle && (
        <p>No daily puzzle available.</p>
      )}

      {!loading && !loadError && puzzle && (
        <form onSubmit={handleSubmit} style={{ marginTop: "1rem" }}>
          <h2>{puzzle.question ?? "Puzzle"}</h2>
          <input
            value={answer}
            onChange={(e) => setAnswer(e.target.value)}
            style={{ display: "block", marginTop: "0.5rem", minWidth: "16rem" }}
          />
          <button type="submit" style={{ marginTop: "0.5rem" }}>
            Submit
          </button>

          {feedback && (
            <p style={{ marginTop: "0.5rem" }}>
              {feedback}
            </p>
          )}
        </form>
      )}
    </div>
  );
};

export default DailyChallengeDetailPage;
