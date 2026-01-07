import React, { useEffect, useMemo, useState } from "react";
import { getPuzzles, solvePuzzle, type Puzzle } from "./api";

/**
 * GamePanel (SOURCE OF TRUTH)
 * - Reads puzzles from backend: GET /puzzles
 * - When user answers correctly (data-driven via correctIndex), records it: POST /progress/solve
 * - Keeps UI simple + deterministic
 *
 * NOTE:
 * - correctIndex is 0-based index into options
 * - If correctIndex is missing, we treat the puzzle as "unknown correctness" (never auto-solve)
 */

function isCorrectAnswer(p: Puzzle, pickedIndex: number): boolean {
  if (typeof p.correctIndex !== "number") return false;
  return pickedIndex === p.correctIndex;
}

const GamePanel: React.FC = () => {
  const [puzzles, setPuzzles] = useState<Puzzle[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [status, setStatus] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // prevent double-solve for same puzzle in this session
  const [solvedIds, setSolvedIds] = useState<Record<string, true>>({});

  async function loadPuzzles() {
    setLoading(true);
    setStatus(null);
    try {
      const result = await getPuzzles();
      const list = result || [];
      setPuzzles(list);
      setCurrentIndex(0);
      if (list.length === 0) setStatus("No puzzles available.");
    } catch (e) {
      setStatus("Failed to load puzzles.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadPuzzles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const currentPuzzle = useMemo(() => puzzles[currentIndex], [puzzles, currentIndex]);

  async function handleOptionClick(pickedIndex: number) {
    if (!currentPuzzle) return;

    const correct = isCorrectAnswer(currentPuzzle, pickedIndex);

    if (correct) {
      setStatus("Correct!");
      const id = String((currentPuzzle as any).id ?? "unknown");

      // only solve once per id per session
      if (!solvedIds[id]) {
        setSolvedIds((prev) => ({ ...prev, [id]: true }));
        try {
          await solvePuzzle(id);
        } catch {
          // Keep UI stable even if solve fails
        }
      }
    } else {
      setStatus("Try again.");
    }
  }

  function nextPuzzle() {
    if (puzzles.length === 0) return;
    setStatus(null);
    setCurrentIndex((i) => (i + 1) % puzzles.length);
  }

  return (
    <section aria-label="Puzzles section">
      <h2>Puzzles</h2>

      {loading && <div aria-live="polite">Loading puzzlesâ€¦</div>}

      {!loading && !currentPuzzle && (
        <div aria-live="polite">
          <p>No puzzle loaded.</p>
          <button type="button" onClick={loadPuzzles}>
            Reload puzzles
          </button>
        </div>
      )}

      {currentPuzzle && (
        <>
          <p>{currentPuzzle.question}</p>
          <ul>
            {currentPuzzle.options.map((opt: string, idx: number) => (
              <li key={idx}>
                <button type="button" onClick={() => handleOptionClick(idx)}>
                  {opt}
                </button>
              </li>
            ))}
          </ul>

          <button type="button" onClick={nextPuzzle}>
            Next puzzle
          </button>
        </>
      )}

      {status && (
        <div role="status" aria-live="polite" style={{ marginTop: "0.75rem" }}>
          {status}
        </div>
      )}
    </section>
  );
};

export default GamePanel;
