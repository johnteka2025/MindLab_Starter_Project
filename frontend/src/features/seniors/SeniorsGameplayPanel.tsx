import * as React from "react";
import {
  getSeniorsGameplayItemsForSession,
  type SeniorsGameplayItem
} from "./seniorsGameplayContent";
import { recordSeniorsChallengeResult } from "./seniorsPersistence";
import {
  calculateSeniorsScore,
  type SeniorsScoreResult
} from "./seniorsScoring";
import {
  getSeniorsSessionSummary,
  type SeniorsSessionRoundResult
} from "./seniorsPostSessionInsights";
import SeniorsPostSessionInsightPanel from "./SeniorsPostSessionInsightPanel";
import type { SeniorsSessionModeId } from "./seniorsSessionModes";

const SENIORS_SESSION_LENGTH = 3;

function nowMilliseconds(): number {
  if (typeof performance !== "undefined" && typeof performance.now === "function") {
    return performance.now();
  }

  return Date.now();
}

export function shouldAcceptSeniorsAnswer(answerLocked: boolean): boolean {
  return !answerLocked;
}

export function buildSeniorsSessionItems(
  items: SeniorsGameplayItem[],
  cycle: number,
  sessionLength = SENIORS_SESSION_LENGTH
): SeniorsGameplayItem[] {
  if (items.length === 0 || sessionLength <= 0) {
    return [];
  }

  const length = Math.min(sessionLength, items.length);
  const startIndex = Math.abs(cycle) % items.length;

  return Array.from({ length }, (_, index) => items[(startIndex + index) % items.length]!);
}

type SeniorsGameplayPanelProps = {
  selectedMode: SeniorsSessionModeId;
};

export default function SeniorsGameplayPanel({
  selectedMode
}: SeniorsGameplayPanelProps) {
  const [sessionCycle, setSessionCycle] = React.useState(0);
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [selectedAnswer, setSelectedAnswer] = React.useState("");
  const [hintVisible, setHintVisible] = React.useState(false);
  const [roundScore, setRoundScore] = React.useState<SeniorsScoreResult | null>(null);
  const [sessionResults, setSessionResults] = React.useState<SeniorsSessionRoundResult[]>([]);
  const [sessionComplete, setSessionComplete] = React.useState(false);

  const answerLockedRef = React.useRef(false);
  const questionStartedAtRef = React.useRef(nowMilliseconds());

  const availableItems = React.useMemo(
    () => getSeniorsGameplayItemsForSession(selectedMode),
    [selectedMode]
  );

  const sessionItems = React.useMemo(
    () => buildSeniorsSessionItems(availableItems, sessionCycle),
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
    setRoundScore(null);
    setSessionResults([]);
    setSessionComplete(false);
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }, [selectedMode]);

  function resetQuestionState() {
    setSelectedAnswer("");
    setHintVisible(false);
    setRoundScore(null);
    answerLockedRef.current = false;
    questionStartedAtRef.current = nowMilliseconds();
  }

  function handleHint() {
    if (hasAnswered) return;
    setHintVisible((current) => !current);
  }

  function handleAnswer(option: string) {
    if (!activeItem || !shouldAcceptSeniorsAnswer(answerLockedRef.current)) {
      return;
    }

    answerLockedRef.current = true;

    const answerIsCorrect = option === activeItem.correctAnswer;
    const elapsedSeconds = Math.max(
      1,
      Math.round((nowMilliseconds() - questionStartedAtRef.current) / 1000)
    );

    const scoreResult = calculateSeniorsScore({
      isCorrect: answerIsCorrect,
      completed: true,
      elapsedSeconds,
      hintUsed: hintVisible
    });

    recordSeniorsChallengeResult({
      sessionMode: selectedMode,
      challengeId: activeItem.challengeId,
      isCorrect: answerIsCorrect,
      score: scoreResult.overallScore,
      hintUsed: hintVisible,
      elapsedSeconds,
      practiceCategory: activeItem.categoryName
    });

    setSelectedAnswer(option);
    setRoundScore(scoreResult);
    setSessionResults((current) => [
      ...current,
      {
        challengeId: activeItem.challengeId,
        isCorrect: answerIsCorrect,
        score: scoreResult.overallScore,
        elapsedSeconds,
        practiceCategory: activeItem.categoryName
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
      <section aria-labelledby="seniors-gameplay-heading" style={{ marginTop: "30px" }}>
        <h2 id="seniors-gameplay-heading" style={{ fontSize: "28px" }}>Practice session</h2>
        <p style={{ fontSize: "19px", lineHeight: 1.6 }}>
          No practice items are available for this session mode.
        </p>
      </section>
    );
  }

  if (sessionComplete) {
    const summary = getSeniorsSessionSummary(sessionResults);

    return (
      <section aria-labelledby="seniors-session-result-heading" style={{ marginTop: "30px" }}>
        <article
          style={{
            border: "1px solid #bbd7cc",
            borderRadius: "22px",
            padding: "24px",
            background: "#f0fdf8"
          }}
        >
          <p style={{ margin: "0 0 8px", color: "#166534", fontSize: "16px", fontWeight: 700 }}>
            Session complete - {selectedMode}
          </p>
          <h2
            id="seniors-session-result-heading"
            style={{ margin: "0 0 18px", fontSize: "30px", lineHeight: 1.2 }}
          >
            You completed this practice round.
          </h2>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
              gap: "12px"
            }}
          >
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Challenges completed</div>
              <strong style={{ fontSize: "24px" }}>{summary.challengesCompleted}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Correct answers</div>
              <strong style={{ fontSize: "24px" }}>{summary.correctAnswers}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Average score</div>
              <strong style={{ fontSize: "24px" }}>{summary.averageScore}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Confidence milestone</div>
              <strong style={{ fontSize: "20px" }}>{summary.confidenceMilestone}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Practice area</div>
              <strong style={{ fontSize: "20px" }}>{summary.practiceArea}</strong>
            </div>
            <div style={{ borderRadius: "16px", background: "#ffffff", padding: "16px" }}>
              <div style={{ color: "#475569", fontSize: "15px" }}>Measured time</div>
              <strong style={{ fontSize: "20px" }}>{summary.measuredSeconds}s</strong>
            </div>
          </div>

          <p style={{ margin: "18px 0 0", fontSize: "19px", lineHeight: 1.6, color: "#334155" }}>
            <strong>Recommended next step:</strong> {summary.recommendedNextStep}
          </p>

          <button
            type="button"
            onClick={handleReplay}
            style={{
              marginTop: "20px",
              minHeight: "52px",
              border: "1px solid #0f172a",
              borderRadius: "14px",
              padding: "12px 20px",
              background: "#0f172a",
              color: "#ffffff",
              fontSize: "18px",
              fontWeight: 700,
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
    <section aria-labelledby="seniors-gameplay-heading" style={{ marginTop: "30px" }}>
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 8px", color: "#475569", fontSize: "16px" }}>
          Challenge {questionIndex + 1} of {sessionItems.length} - {activeItem.categoryName}
        </p>
        <h2 id="seniors-gameplay-heading" style={{ margin: 0, fontSize: "28px" }}>
          Guided practice
        </h2>
      </div>

      <article
        style={{
          border: "1px solid #cbd5e1",
          borderRadius: "20px",
          padding: "24px",
          background: "#ffffff"
        }}
      >
        <p style={{ margin: "0 0 12px", color: "#475569", fontSize: "18px", lineHeight: 1.6 }}>
          {activeItem.objective}
        </p>
        <h3 style={{ margin: "0 0 20px", fontSize: "24px", lineHeight: 1.4 }}>
          {activeItem.prompt}
        </h3>

        <div style={{ display: "grid", gap: "12px" }}>
          {activeItem.options.map((option) => {
            const isSelected = selectedAnswer === option;

            return (
              <button
                key={option}
                type="button"
                disabled={hasAnswered}
                onClick={() => handleAnswer(option)}
                style={{
                  minHeight: "54px",
                  textAlign: "left",
                  border: isSelected ? "2px solid #0f172a" : "1px solid #cbd5e1",
                  borderRadius: "14px",
                  padding: "14px 16px",
                  background: isSelected ? "#e2e8f0" : "#f8fafc",
                  color: "#0f172a",
                  fontSize: "18px",
                  lineHeight: 1.4,
                  cursor: hasAnswered ? "default" : "pointer"
                }}
              >
                {option}
              </button>
            );
          })}
        </div>

        <button
          type="button"
          disabled={hasAnswered}
          onClick={handleHint}
          style={{
            marginTop: "16px",
            minHeight: "48px",
            border: "1px solid #94a3b8",
            borderRadius: "14px",
            padding: "10px 16px",
            background: "#ffffff",
            color: "#334155",
            fontSize: "17px",
            cursor: hasAnswered ? "default" : "pointer"
          }}
        >
          {hintVisible ? "Hide hint" : "Show a helpful hint"}
        </button>

        {hintVisible && !hasAnswered && (
          <div
            style={{
              marginTop: "14px",
              padding: "14px 16px",
              borderRadius: "14px",
              background: "#eff6ff",
              color: "#1e3a8a",
              fontSize: "18px",
              lineHeight: 1.6
            }}
          >
            {activeItem.hint}
          </div>
        )}

        {!hasAnswered && (
          <p style={{ margin: "16px 0 0", color: "#475569", fontSize: "18px" }}>
            Take your time. Choose one answer when you are ready.
          </p>
        )}

        {hasAnswered && roundScore && (
          <>
            <div
              aria-live="polite"
              style={{
                marginTop: "20px",
                padding: "16px",
                borderRadius: "14px",
                background: isCorrect ? "#ecfdf5" : "#fff7ed",
                color: isCorrect ? "#065f46" : "#9a3412",
                fontSize: "18px",
                lineHeight: 1.6
              }}
            >
              <strong>{isCorrect ? "Nice work." : "Review and continue when ready."}</strong>{" "}
              {isCorrect
                ? activeItem.insight
                : `${activeItem.hint} Correct answer: ${activeItem.correctAnswer}.`}
            </div>

            <SeniorsPostSessionInsightPanel
              scoreResult={roundScore}
              isCorrect={isCorrect}
              itemInsight={activeItem.insight}
            />

            <button
              type="button"
              onClick={handleContinue}
              style={{
                marginTop: "20px",
                minHeight: "52px",
                border: "1px solid #0f172a",
                borderRadius: "14px",
                padding: "12px 20px",
                background: "#0f172a",
                color: "#ffffff",
                fontSize: "18px",
                fontWeight: 700,
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
