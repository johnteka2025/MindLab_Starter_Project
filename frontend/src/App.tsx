
import { useEffect, useMemo, useState } from "react";
import {
  createSession,
  getHealth,
  getProgress,
  getPuzzles,
  puzzleChoicesOf,
  puzzleTextOf,
  sessionIdOf,
  submitAnswer,
  type MindLabPuzzle,
} from "./lib/mindlabApi";
import "./styles.css";
import { startMindLabAnalyticsDomBridge } from "./lib/mindlabAnalytics";

startMindLabAnalyticsDomBridge();

type Step = "home" | "loading" | "play" | "feedback" | "progress" | "error";

const AGE_OPTIONS = [
  { id: "kids", label: "Kids" },
  { id: "seniors", label: "Seniors" },
  { id: "adults", label: "Adults" },
];

export default function App() {
  const [step, setStep] = useState<Step>("home");
  const [ageCategory, setAgeCategory] = useState("kids");
  const [puzzles, setPuzzles] = useState<MindLabPuzzle[]>([]);
  const [activeIndex, setActiveIndex] = useState(0);
  const [sessionId, setSessionId] = useState("");
  const [answer, setAnswer] = useState("");
  const [feedback, setFeedback] = useState<Record<string, unknown> | null>(null);
  const [progress, setProgress] = useState<Record<string, unknown> | null>(null);
  const [error, setError] = useState("");

  const activePuzzle = useMemo(() => puzzles[activeIndex], [puzzles, activeIndex]);
  const choices = activePuzzle ? puzzleChoicesOf(activePuzzle) : [];

  useEffect(() => {
    getHealth().catch(() => {
      setError("Backend is not reachable at https://mindlab-backend.onrender.com.");
      setStep("error");
    });
  }, []);

  async function startGame() {
    try {
      setStep("loading");
      setError("");
      setFeedback(null);
      setProgress(null);
      setAnswer("");
      setActiveIndex(0);

      const [session, puzzleList] = await Promise.all([
        createSession(ageCategory),
        getPuzzles(),
      ]);

      const newSessionId = sessionIdOf(session);
      if (!newSessionId) {
        throw new Error("Session response did not include an id or sessionId.");
      }

      if (!puzzleList.length) {
        throw new Error("No puzzles returned by /api/puzzles.");
      }

      setSessionId(newSessionId);
      setPuzzles(puzzleList);
      setStep("play");
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
      setStep("error");
    }
  }

  async function submitCurrentAnswer(value?: string) {
    try {
      const finalAnswer = value || answer;
      if (!activePuzzle) throw new Error("No active puzzle selected.");
      if (!finalAnswer.trim()) throw new Error("Enter or select an answer first.");

      setStep("loading");
      const result = await submitAnswer({
        sessionId,
        puzzleId: activePuzzle.id,
        answer: finalAnswer,
      });

      setFeedback(result);
      setStep("feedback");
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
      setStep("error");
    }
  }

  async function showProgress() {
    try {
      setStep("loading");
      const result = await getProgress(sessionId);
      setProgress(result);
      setStep("progress");
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
      setStep("error");
    }
  }

  function nextPuzzle() {
    setAnswer("");
    setFeedback(null);

    if (activeIndex + 1 < puzzles.length) {
      setActiveIndex(activeIndex + 1);
      setStep("play");
    } else {
      showProgress();
    }
  }

  return (
    <main className="mindlab-shell">
{/* MINDLAB_SCOPE1_ONBOARDING_START */}
<section className="mindlab-onboarding-polish" aria-label="MindLab game overview">
  <p className="mindlab-onboarding-eyebrow">MindLab Practice</p>
  <h2>Pick your age group and answer quick practice questions.</h2>
  <p>
    Choose a category, play through each question, and watch your score and progress as you go.
  </p>
  <p className="mindlab-feedback-guide">After each answer, MindLab gives quick feedback so you know what to try next.</p>
{/* MINDLAB_SCOPE3_COMPLETION_MOTIVATION_START */}
<p className="mindlab-completion-cue">
  Finish a session to see your result, then replay or choose another age group to keep practicing.
</p>
{/* MINDLAB_SCOPE3_COMPLETION_MOTIVATION_END */}
</section>
{/* MINDLAB_SCOPE1_ONBOARDING_END */}
      <section className="mindlab-card">
        <p className="eyebrow">MindLab practice session</p>
        <h1>Practice questions by age group</h1>

        {step === "home" && (
          <div className="stack">
            <label>
              Age group
              <select value={ageCategory} onChange={(event) => setAgeCategory(event.target.value)}>
                {AGE_OPTIONS.map((option) => (
                  <option key={option.id} value={option.id}>
                    {option.label}
                  </option>
                ))}
              </select>
            </label>
            <button onClick={startGame}>Start practice</button>
          </div>
        )}

        {step === "loading" && <p className="status">Loadingâ€¦</p>}

        {step === "play" && activePuzzle && (
          <div className="stack">
            <p className="meta">
              Session: {sessionId} Â· Puzzle {activeIndex + 1} of {puzzles.length}
            </p>
            <h2>{activePuzzle.title || "Puzzle"}</h2>
            <p className="prompt">{puzzleTextOf(activePuzzle)}</p>

            {choices.length > 0 ? (
              <div className="choices">
                {choices.map((choice) => (
                  <button key={choice} onClick={() => submitCurrentAnswer(choice)}>
                    {choice}
                  </button>
                ))}
              </div>
            ) : (
              <>
                <textarea
                  value={answer}
                  onChange={(event) => setAnswer(event.target.value)}
                  placeholder="Type your answer"
                />
                <button onClick={() => submitCurrentAnswer()}>Submit answer</button>
              </>
            )}
          </div>
        )}

        {step === "feedback" && (
          <div className="stack">
            <h2>Answer saved</h2>
            <div
  className="player-feedback-card"
  role="status"
  style={{
    padding: "1rem",
    borderRadius: "0.75rem",
    background: "#f8fafc",
    border: "1px solid #e2e8f0",
    lineHeight: 1.6,
    marginTop: "1rem",
    marginBottom: "1rem"
  }}
>
  <strong>Progress saved.</strong>
  <p style={{ margin: "0.5rem 0 0 0" }}>
    Continue to the next question or view your result when the session is complete.
  </p>
</div>
            <div className="actions">
              <button onClick={nextPuzzle}>Next</button>
              <button onClick={showProgress}>View result</button>
            </div>
          </div>
        )}

        {step === "progress" && (
          <div className="stack">
            <h2>Result</h2>
            <div
  className="player-feedback-card"
  role="status"
  style={{
    padding: "1rem",
    borderRadius: "0.75rem",
    background: "#f8fafc",
    border: "1px solid #e2e8f0",
    lineHeight: 1.6,
    marginTop: "1rem",
    marginBottom: "1rem"
  }}
>
  <strong>Progress saved.</strong>
  <p style={{ margin: "0.5rem 0 0 0" }}>
    Continue to the next question or view your result when the session is complete.
  </p>
</div>
            <button onClick={() => setStep("home")}>Start another session</button>
          </div>
        )}

        {step === "error" && (
          <div className="stack">
            <h2>Something needs attention</h2>
            <p className="error">{error}</p>
            <button onClick={() => setStep("home")}>Back home</button>
          </div>
        )}
      </section>
    </main>
  );
}








