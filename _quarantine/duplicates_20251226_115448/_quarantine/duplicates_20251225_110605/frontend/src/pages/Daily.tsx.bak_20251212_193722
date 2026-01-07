import React, { useEffect, useState } from "react";

type Puzzle = {
  id: string | number;
  question: string;
  answer: string;
};

export default function Daily() {
  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [selectedPuzzle, setSelectedPuzzle] = useState<Puzzle | null>(null);
  const [answer, setAnswer] = useState("");
  const [feedback, setFeedback] = useState("");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadPuzzles() {
      try {
        setError(null);
        const res = await fetch("http://localhost:8085/puzzles");
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const data: Puzzle[] = await res.json();
        setPuzzles(data);
      } catch (err: any) {
        console.error("Failed to load puzzles:", err);
        setError("Error loading puzzles list.");
      }
    }

    loadPuzzles();
  }, []);

  async function submitAnswer() {
    if (!selectedPuzzle) return;

    const correct = selectedPuzzle.answer.toLowerCase().trim();
    const guess = answer.toLowerCase().trim();

    if (guess === correct) {
      setFeedback("✅ Correct!");
    } else {
      setFeedback("❌ Incorrect. Try again!");
    }
  }

  return (
    <div style={{ padding: "1.5rem" }}>
      <h1>Daily Challenge</h1>
      <p>Daily Challenge</p>

      {error && (
        <p style={{ color: "red" }}>{error}</p>
      )}

      {/* Puzzles list */}
      <ul data-testid="puzzles-list">
        {puzzles.map((p) => (
          <li key={p.id}>
            <button
              onClick={() => {
                setSelectedPuzzle(p);
                setFeedback("");
                setAnswer("");
              }}
            >
              Puzzle #{p.id}
            </button>
          </li>
        ))}
      </ul>

      {/* Selected puzzle + answer area */}
      {selectedPuzzle && (
        <div style={{ marginTop: "1rem" }}>
          <h2 data-testid="puzzle-question">{selectedPuzzle.question}</h2>

          <input
            data-testid="puzzle-answer-input"
            value={answer}
            onChange={(e) => setAnswer(e.target.value)}
          />

          <button
            style={{ marginLeft: "0.5rem" }}
            data-testid="puzzle-submit-button"
            onClick={submitAnswer}
          >
            Submit
          </button>

          {feedback && (
            <p data-testid="answer-feedback" style={{ marginTop: "0.5rem" }}>
              {feedback}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
