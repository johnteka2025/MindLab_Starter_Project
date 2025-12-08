import React, { useEffect, useState, FormEvent } from "react";
import {
  fetchDailyInstance,
  submitDailyAnswer,
  type DailyChallengeInstance,
  type DailyAnswerResponse,
} from "./DailyChallengeApi";
import {
  DailyCompletionCard,
  type DailyResultStatus,
} from "../components/DailyCompletionCard";

type LoadState = "idle" | "loading" | "loaded" | "error";
type AnswerState = "idle" | "submitting" | "submitted" | "error";

const demoAnswerHint = "demo-answer";

/**
 * Full Daily Challenge detail page.
 * - Fetches today"s challenge from /daily
 * - Shows puzzle list
 * - Lets the user submit an answer for a puzzle
 * - Updates progress after an answer is accepted
 */
export const DailyChallengeDetailPage: React.FC = () => {
  const [instance, setInstance] = useState<DailyChallengeInstance | null>(null);
  const [loadState, setLoadState] = useState<LoadState>("idle");
  const [loadError, setLoadError] = useState<string | null>(null);

  const [selectedPuzzleId, setSelectedPuzzleId] = useState<string | null>(null);
  const [answerText, setAnswerText] = useState("");
  const [answerState, setAnswerState] = useState<AnswerState>("idle");
  const [answerError, setAnswerError] = useState<string | null>(null);
  const [answerResult, setAnswerResult] = useState<DailyAnswerResponse | null>(
    null,
  );

  // Derived status for the completion card
  const resultStatus: DailyResultStatus | null = answerResult
    ? answerResult.correct
      ? "correct"
      : "incorrect"
    : null;

  // Load the full instance on mount
  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      setLoadState("loading");
      setLoadError(null);

      try {
        const data = await fetchDailyInstance();
        if (cancelled) return;
        setInstance(data);
        setLoadState("loaded");

        // Default to first puzzle if any are available
        if (data.puzzles.length > 0) {
          setSelectedPuzzleId(data.puzzles[0].id);
        }
      } catch (err: any) {
        if (cancelled) return;
        setLoadState("error");
        setLoadError(err?.message ?? "Failed to load daily challenge.");
      }
    };

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const selectedPuzzle =
    instance?.puzzles.find((p) => p.id === selectedPuzzleId) ?? null;

  const handleSubmit = async (evt: FormEvent) => {
    evt.preventDefault();

    if (!instance || !selectedPuzzle) return;

    if (!answerText.trim()) {
      setAnswerError("Please enter an answer.");
      return;
    }

    setAnswerState("submitting");
    setAnswerError(null);
    setAnswerResult(null);

    try {
      const response = await submitDailyAnswer({
        dailyChallengeId: instance.dailyChallengeId,
        puzzleId: selectedPuzzle.id,
        answer: answerText.trim(),
      });

      setAnswerState("submitted");
      setAnswerResult(response);

      // Shallow update of high-level progress fields
      setInstance({
        ...instance,
        completedCount: response.completedCount,
        status: response.status,
      });
    } catch (err: any) {
      setAnswerState("error");
      setAnswerError(err?.message ?? "Failed to submit answer.");
    }
  };

  const headline = instance
    ? `Daily Challenge for ${instance.challengeDate} (band ${instance.band})`
    : "Daily Challenge";

  return (
    <div style={{ maxWidth: 900, margin: "0 auto", padding: "1.5rem" }}>
      <h1>Daily Challenge</h1>
      <p style={{ color: "#555" }}>{headline}</p>

      {loadState === "loading" && <p>Loading daily challenge…</p>}

      {loadState === "error" && (
        <p style={{ color: "red" }}>
          Error loading daily challenge: {loadError}
        </p>
      )}

      {instance && (
        <>
          <section style={{ marginTop: "1rem", marginBottom: "1.5rem" }}>
            <strong>Status:</strong> {instance.status} ·{" "}
            <strong>Progress:</strong> {instance.completedCount} /{" "}
            {instance.totalPuzzles}
          </section>

          <div
            style={{
              display: "flex",
              gap: "1.5rem",
              alignItems: "flex-start",
            }}
          >
            {/* Puzzles list */}
            <section style={{ flex: 1 }}>
              <h2>Puzzles</h2>
              {instance.puzzles.length === 0 && <p>No puzzles for today.</p>}
              <ul style={{ listStyle: "none", padding: 0 }}>
                {instance.puzzles.map((puzzle) => (
                  <li
                    key={puzzle.id}
                    style={{
                      padding: "0.5rem 0.75rem",
                      marginBottom: "0.25rem",
                      borderRadius: 8,
                      border:
                        puzzle.id === selectedPuzzleId
                          ? "2px solid #2563eb"
                          : "1px solid #ddd",
                      cursor: "pointer",
                      background:
                        puzzle.id === selectedPuzzleId ? "#eff6ff" : "white",
                    }}
                    onClick={() => setSelectedPuzzleId(puzzle.id)}
                  >
                    <div style={{ fontWeight: 600 }}>{puzzle.title}</div>
                    <div style={{ fontSize: "0.85rem", color: "#666" }}>
                      Difficulty: {puzzle.difficulty}
                    </div>
                  </li>
                ))}
              </ul>
            </section>

            {/* Answer panel */}
            <section style={{ flex: 1 }}>
              <h2>Answer</h2>
              {!selectedPuzzle && <p>Select a puzzle to answer.</p>}
              {selectedPuzzle && (
                <form onSubmit={handleSubmit}>
                  <p>
                    Answering: <strong>{selectedPuzzle.title}</strong>
                  </p>
                  <label style={{ display: "block", marginBottom: "0.5rem" }}>
                    Your answer
                    <input
                      type="text"
                      value={answerText}
                      onChange={(e) => setAnswerText(e.target.value)}
                      style={{
                        width: "100%",
                        marginTop: "0.25rem",
                        padding: "0.5rem",
                        borderRadius: 6,
                        border: "1px solid #ccc",
                      }}
                    />
                  </label>
                  <p style={{ fontSize: "0.8rem", color: "#888" }}>
                    Hint for the demo backend: try <code>{demoAnswerHint}</code>.
                  </p>

                  {answerError && (
                    <p style={{ color: "red", marginTop: "0.5rem" }}>
                      {answerError}
                    </p>
                  )}

                  {answerResult && (
                    <p
                      style={{
                        color: answerResult.correct ? "green" : "red",
                        marginTop: "0.5rem",
                      }}
                    >
                      {answerResult.correct
                        ? "Correct! Progress updated."
                        : "That answer was not correct."}
                    </p>
                  )}

                  {resultStatus && (
                    <div style={{ marginTop: "0.75rem" }}>
                      <DailyCompletionCard status={resultStatus} />
                    </div>
                  )}

                  <button
                    type="submit"
                    disabled={answerState === "submitting"}
                    style={{
                      marginTop: "0.75rem",
                      padding: "0.5rem 1rem",
                      borderRadius: 999,
                      border: "none",
                      backgroundColor: "#2563eb",
                      color: "white",
                      fontWeight: 600,
                      cursor:
                        answerState === "submitting" ? "wait" : "pointer",
                    }}
                  >
                    {answerState === "submitting"
                      ? "Submitting…"
                      : "Submit answer"}
                  </button>
                </form>
              )}
            </section>
          </div>
        </>
      )}
    </div>
  );
};

export default DailyChallengeDetailPage;
