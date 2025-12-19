import React, { useEffect, useMemo, useState } from "react";

type Puzzle = {
  id: number;
  question: string;
  options: string[];
  correctIndex: number;
};

export default function DailyChallengeDetailPage() {
  const puzzlesUrl = useMemo(() => "http://localhost:8085/puzzles", []);
  const progressUrl = useMemo(() => "http://localhost:8085/progress", []);

  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [selectedPuzzle, setSelectedPuzzle] = useState<Puzzle | null>(null);
  const [selectedOptionIndex, setSelectedOptionIndex] = useState<number | null>(null);

  const [feedback, setFeedback] = useState("");
  const [saveStatus, setSaveStatus] = useState<string | null>(null);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch(puzzlesUrl);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = (await res.json()) as Puzzle[];
        if (!Array.isArray(data)) throw new Error("Invalid puzzles payload (expected array)");

        if (!cancelled) {
          setPuzzles(data);
          if (data.length > 0) setSelectedPuzzle(data[0]);
        }
      } catch (e: any) {
        console.error(e);
        if (!cancelled) {
          setError("Failed to load puzzles.");
          setPuzzles([]);
          setSelectedPuzzle(null);
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, [puzzlesUrl]);

  async function writeProgress(puzzleId: number, correct: boolean) {
    setSaving(true);
    setSaveStatus(null);

    try {
      const res = await fetch(progressUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ puzzleId, correct }),
      });

      if (!res.ok) {
        const t = await res.text().catch(() => "");
        throw new Error(`HTTP ${res.status} ${t}`.trim());
      }

      await res.json().catch(() => null);
      setSaveStatus("✅ Progress saved.");
      return true;
    } catch (e) {
      console.error(e);
      setSaveStatus("❌ Progress save failed.");
      return false;
    } finally {
      setSaving(false);
    }
  }

  async function submit() {
    if (!selectedPuzzle) return;

    if (selectedOptionIndex === null) {
      setFeedback("⚠️ Please select an option.");
      return;
    }

    const isCorrect = selectedOptionIndex === selectedPuzzle.correctIndex;
    setFeedback(isCorrect ? "✅ Correct!" : "❌ Incorrect. Try again!");
    await writeProgress(selectedPuzzle.id, isCorrect);
  }

  return (
    <div style={{ padding: "1.5rem" }}>
      <h1>Daily Challenge</h1>

      {error && <p style={{ color: "red" }}>{error}</p>}
      {loading && <p>Loading puzzles…</p>}

      <h2 style={{ marginTop: "1rem" }}>Puzzles</h2>

      <ul data-testid="daily-puzzles-list">
        {puzzles.map((p) => (
          <li key={p.id}>
            <button
              type="button"
              data-testid="daily-puzzle-item"
              onClick={() => {
                setSelectedPuzzle(p);
                setSelectedOptionIndex(null);
                setFeedback("");
                setSaveStatus(null);
              }}
              style={{ marginBottom: "0.5rem" }}
            >
              {p.question}
            </button>
          </li>
        ))}
      </ul>

      {selectedPuzzle && (
        <div style={{ marginTop: "1rem" }}>
          <h2 data-testid="puzzle-question">{selectedPuzzle.question}</h2>

          <div data-testid="puzzle-options" style={{ marginTop: "0.5rem" }}>
            {selectedPuzzle.options.map((opt, idx) => (
              <label key={idx} style={{ display: "block", marginBottom: "0.25rem" }}>
                <input
                  type="radio"
                  name="puzzle-option"
                  checked={selectedOptionIndex === idx}
                  onChange={() => setSelectedOptionIndex(idx)}
                />
                {" "}{opt}
              </label>
            ))}
          </div>

          <button
            data-testid="puzzle-submit-button"
            onClick={submit}
            disabled={saving}
            style={{ marginTop: "0.75rem" }}
          >
            {saving ? "Saving..." : "Submit"}
          </button>

          {feedback && (
            <p data-testid="answer-feedback" style={{ marginTop: "0.5rem" }}>
              {feedback}
            </p>
          )}

          {saveStatus && (
            <p data-testid="progress-save-status" style={{ marginTop: "0.5rem" }}>
              {saveStatus}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
