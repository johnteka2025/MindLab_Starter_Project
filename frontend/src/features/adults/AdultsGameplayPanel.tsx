import * as React from "react";
import {
  getAdultsGameplayItemsForSession,
  type AdultsGameplayItem
} from "./adultsGameplayContent";
import AdultsPostSessionInsightPanel from "./AdultsPostSessionInsightPanel";
import { recordAdultSessionResult } from "./adultsPersistence";
import {
  calculateAdultsScore,
  type AdultsScoreResult
} from "./adultsScoring";

const ADULTS_SESSION_LENGTH = 3;

type AdultsGameplayPanelProps = {
  selectedMode: string;
};

type AdultsRoundResult = {
  certifiedId: string;
  isCorrect: boolean;
  score: number;
  elapsedSeconds: number;
};

function nowMilliseconds(): number {
  if (typeof performance !== "undefined" && typeof performance.now === "function") {
    return performance.now();
  }

  return Date.now();
}

export function getExpectedAdultsTimeSeconds(selectedMode: string): number {
  if (selectedMode === "QuickFocus") return 45;
  if (selectedMode === "Standard") return 75;
  if (selectedMode === "Deep") return 120;
  if (selectedMode === "Recovery") return 180;
  return 75;
}

export function buildAdultsSessionItems(
  items: AdultsGameplayItem[],
  cycle: number,
  sessionLength = ADULTS_SESSION_LENGTH
): AdultsGameplayItem[] {
  if (items.length === 0 || sessionLength <= 0) {
    return [];
  }

  const length = Math.min(sessionLength, items.length);
  const startIndex = Math.abs(cycle) % items.length;

  return Array.from({ length }, (_, index) => items[(startIndex + index) % items.length]!);
}

export default function AdultsGameplayPanel({ selectedMode }: AdultsGameplayPanelProps) {
  const [sessionCycle, setSessionCycle] = React.useState(0);
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [selectedAnswer, setSelectedAnswer] = React.useState("");
  const [hintVisible, setHintVisible] = React.useState(false);
  const [hintUse, setHintUse] = React.useState(0);
  const [roundScore, setRoundScore] = React.useState<AdultsScoreResult | null>(null);
  const [savedProfileLabel, setSavedProfileLabel] = React.useState("");
  const [sessionResults, setSessionResults] = React.useState<AdultsRoundResult[]>([]);
  const [sessionComplete, setSessionComplete] = React.useState(false);
  const answerLockedRef = React.useRef(false);
  const questionStartedAtRef = React.useRef(nowMilliseconds());

  const availableItems = React.useMemo(
    () => getAdultsGameplayItemsForSession(selectedMode),
    [selectedMode]
  );

  const sessionItems = React.useMemo(
    () => buildAdultsSessionItems(availableItems, sessionCycle),
    [availableItems, sessionCycle]
  );

  const activeItem = sessionItems[questionIndex] ?? null;
  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = Boolean(activeItem && selectedAnswer === activeItem.correctAnswer);

  React.useEffect(() => {
    setSessionCycle(0);
    setQuestionIndex(0);
    setSelectedAnswer("");
    setHintVisible(false);
    setHintUse(0);
    setRoundScore(null);
    setSavedProfileLabel("");
    setSessionResults([]);
    setSessionComplete(false);
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }, [selectedMode]);

  function resetQuestionState() {
    setSelectedAnswer("");
    setHintVisible(false);
    setHintUse(0);
    setRoundScore(null);
    setSavedProfileLabel("");
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }

  function handleHint() {
    if (hasAnswered) {
      return;
    }

    if (!hintVisible) {
      setHintUse(1);
    }

    setHintVisible((current) => !current);
  }

  function handleAnswer(option: string) {
    if (!activeItem || answerLockedRef.current) {
      return;
    }

    answerLockedRef.current = true;

    const answerIsCorrect = option === activeItem.correctAnswer;
    const elapsedSeconds = Math.max(
      1,
      Math.round((nowMilliseconds() - questionStartedAtRef.current) / 1000)
    );

    const score = calculateAdultsScore({
      isCorrect: answerIsCorrect,
      selectedAnswer: option,
      correctAnswer: activeItem.correctAnswer,
      hintUse,
      retryCount: 0,
      completed: true,
      expectedTimeSeconds: getExpectedAdultsTimeSeconds(selectedMode),
      actualTimeSeconds: elapsedSeconds,
      firstTrySuccess: answerIsCorrect
    });

    const savedProfile = recordAdultSessionResult({
      certifiedId: activeItem.certifiedId,
      category: activeItem.category,
      stage: activeItem.stage,
      sessionMode: selectedMode,
      selectedAnswer: option,
      correctAnswer: activeItem.correctAnswer,
      isCorrect: answerIsCorrect,
      scoreResult: score
    });

    setSelectedAnswer(option);
    setRoundScore(score);
    setSavedProfileLabel(`${savedProfile.currentStage} - ${savedProfile.currentCategory}`);
    setSessionResults((current) => [
      ...current,
      {
        certifiedId: activeItem.certifiedId,
        isCorrect: answerIsCorrect,
        score: score.overallScore,
        elapsedSeconds
      }
    ]);
  }

  function handleContinue() {
    if (!activeItem || !roundScore) {
      return;
    }

    if (questionIndex >= sessionItems.length - 1) {
      setSessionComplete(true);
      return;
    }

    setQuestionIndex((current) => current + 1);
    resetQuestionState();
  }

  function handleReplay() {
    setSessionCycle((current) => current + 1);
    setQuestionIndex(0);
    setSessionResults([]);
    setSessionComplete(false);
    resetQuestionState();
  }

  if (sessionItems.length === 0) {
    return (
      <section aria-labelledby="adults-gameplay-heading" style={{ marginTop: "28px" }}>
        <h2 id="adults-gameplay-heading">Training session</h2>
        <p>No gameplay items are available for this session mode.</p>
      </section>
    );
  }

  if (sessionComplete) {
    const correctCount = sessionResults.filter((result) => result.isCorrect).length;
    const averageScore = sessionResults.length > 0
      ? Math.round(sessionResults.reduce((sum, result) => sum + result.score, 0) / sessionResults.length)
      : 0;
    const totalSeconds = sessionResults.reduce((sum, result) => sum + result.elapsedSeconds, 0);

    return (
      <section aria-labelledby="adults-session-result-heading" style={{ marginTop: "28px" }}>
        <article
          style={{
            border: "1px solid #c7d2fe",
            borderRadius: "22px",
            padding: "22px",
            background: "#eef2ff"
          }}
        >
          <p style={{ margin: "0 0 6px", color: "#3730a3", fontSize: "14px" }}>
            Session complete - {selectedMode}
          </p>
          <h2 id="adults-session-result-heading" style={{ margin: "0 0 14px", fontSize: "28px" }}>
            Training round complete.
          </h2>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
              gap: "10px"
            }}
          >
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Challenges</div>
              <strong style={{ fontSize: "22px" }}>{sessionResults.length}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Correct</div>
              <strong style={{ fontSize: "22px" }}>{correctCount}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Average score</div>
              <strong style={{ fontSize: "22px" }}>{averageScore}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
              <div style={{ color: "#64748b", fontSize: "13px" }}>Measured time</div>
              <strong style={{ fontSize: "22px" }}>{totalSeconds}s</strong>
            </div>
          </div>

          <button
            type="button"
            onClick={handleReplay}
            style={{
              marginTop: "18px",
              border: "1px solid #111827",
              borderRadius: "999px",
              padding: "12px 18px",
              background: "#111827",
              color: "#ffffff",
              cursor: "pointer"
            }}
          >
            Play another round
          </button>
        </article>
      </section>
    );
  }

  if (!activeItem) {
    return null;
  }

  return (
    <section aria-labelledby="adults-gameplay-heading" style={{ marginTop: "28px" }}>
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
          Challenge {questionIndex + 1} of {sessionItems.length} - {activeItem.categoryName} - {activeItem.stage}
        </p>
        <h2 id="adults-gameplay-heading" style={{ margin: 0, fontSize: "26px" }}>
          Training round
        </h2>
      </div>

      <article
        style={{
          border: "1px solid #e5e7eb",
          borderRadius: "20px",
          padding: "22px",
          background: "#ffffff"
        }}
      >
        <p style={{ margin: "0 0 10px", color: "#475569", lineHeight: 1.6 }}>
          {activeItem.objective}
        </p>
        <h3 style={{ margin: "0 0 18px", fontSize: "22px", lineHeight: 1.3 }}>
          {activeItem.prompt}
        </h3>

        <div style={{ display: "grid", gap: "10px" }}>
          {activeItem.options.map((option) => {
            const isSelected = selectedAnswer === option;

            return (
              <button
                aria-label="MindLab interactive control"
                key={option}
                type="button"
                disabled={hasAnswered}
                onClick={() => handleAnswer(option)}
                style={{
                  textAlign: "left",
                  border: isSelected ? "2px solid #111827" : "1px solid #e5e7eb",
                  borderRadius: "14px",
                  padding: "14px 16px",
                  background: isSelected ? "#e0e7ff" : "#f9fafb",
                  color: "#111827",
                  cursor: hasAnswered ? "default" : "pointer"
                }}
              >
                {option}
              </button>
            );
          })}
        </div>

        <button
          aria-label="MindLab interactive control"
          type="button"
          disabled={hasAnswered}
          onClick={handleHint}
          style={{
            marginTop: "14px",
            border: "1px solid #cbd5e1",
            borderRadius: "999px",
            padding: "10px 14px",
            background: "#ffffff",
            color: "#334155",
            cursor: hasAnswered ? "default" : "pointer"
          }}
        >
          {hintVisible ? "Hide hint" : "Show hint"}
        </button>

        {hintVisible && !hasAnswered && (
          <div
            style={{
              marginTop: "12px",
              padding: "12px 14px",
              borderRadius: "14px",
              background: "#eff6ff",
              color: "#1e3a8a"
            }}
          >
            {activeItem.hint}
          </div>
        )}

        {!hasAnswered && (
          <p style={{ margin: "14px 0 0", color: "#475569" }}>
            Choose one answer when you are ready.
          </p>
        )}

        {hasAnswered && roundScore && (
          <>
            <div
              aria-live="polite"
              style={{
                marginTop: "18px",
                padding: "14px 16px",
                borderRadius: "14px",
                background: isCorrect ? "#ecfdf5" : "#fff7ed",
                color: isCorrect ? "#065f46" : "#9a3412"
              }}
            >
              <strong>{isCorrect ? "Correct." : "Review recommended."}</strong>{" "}
              {isCorrect
                ? activeItem.insight
                : `${activeItem.hint} Correct answer: ${activeItem.correctAnswer}.`}
              {savedProfileLabel && (
                <div style={{ marginTop: "10px", color: "#334155" }}>
                  Progress saved: <strong>{savedProfileLabel}</strong>
                </div>
              )}
            </div>

            <AdultsPostSessionInsightPanel
              scoreResult={roundScore}
              isCorrect={isCorrect}
              itemInsight={activeItem.insight}
            />

            <button
              type="button"
              onClick={handleContinue}
              style={{
                marginTop: "18px",
                border: "1px solid #111827",
                borderRadius: "999px",
                padding: "12px 18px",
                background: "#111827",
                color: "#ffffff",
                cursor: "pointer"
              }}
            >
              {questionIndex >= sessionItems.length - 1 ? "View session result" : "Next challenge"}
            </button>
          </>
        )}
      </article>
    </section>
  );
}
