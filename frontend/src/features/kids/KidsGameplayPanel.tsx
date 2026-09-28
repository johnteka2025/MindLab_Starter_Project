import * as React from "react";
import {
  getKidsGameplayItemsForSession,
  type KidsGameplayItem
} from "./kidsGameplayContent";
import KidsPostSessionInsightPanel from "./KidsPostSessionInsightPanel";
import { recordKidsSessionProgress } from "./kidsPersistence";
import {
  calculateKidsScore,
  type KidsScoreResult
} from "./kidsScoring";

const KIDS_SESSION_LENGTH = 3;

type KidsGameplayPanelProps = {
  selectedMode: string;
  onProgressUpdated?: () => void;
};

type KidsRoundResult = {
  certifiedId: string;
  isCorrect: boolean;
  score: number;
};

export function buildKidsSessionItems(
  items: KidsGameplayItem[],
  cycle: number,
  sessionLength = KIDS_SESSION_LENGTH
): KidsGameplayItem[] {
  if (items.length === 0 || sessionLength <= 0) {
    return [];
  }

  const length = Math.min(sessionLength, items.length);
  const startIndex = Math.abs(cycle) % items.length;

  return Array.from({ length }, (_, index) => items[(startIndex + index) % items.length]!);
}

export default function KidsGameplayPanel({ selectedMode, onProgressUpdated }: KidsGameplayPanelProps) {
  const [sessionCycle, setSessionCycle] = React.useState(0);
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [selectedAnswer, setSelectedAnswer] = React.useState("");
  const [hintVisible, setHintVisible] = React.useState(false);
  const [roundScore, setRoundScore] = React.useState<KidsScoreResult | null>(null);
  const [sessionResults, setSessionResults] = React.useState<KidsRoundResult[]>([]);
  const [sessionComplete, setSessionComplete] = React.useState(false);
  const answerLockedRef = React.useRef(false);

  const availableItems = React.useMemo(
    () => getKidsGameplayItemsForSession(selectedMode),
    [selectedMode]
  );

  const sessionItems = React.useMemo(
    () => buildKidsSessionItems(availableItems, sessionCycle),
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
  }, [selectedMode]);

  function resetQuestionState() {
    setSelectedAnswer("");
    setHintVisible(false);
    setRoundScore(null);
    answerLockedRef.current = false;
  }

  function handleAnswer(option: string) {
    if (!activeItem || answerLockedRef.current) {
      return;
    }

    answerLockedRef.current = true;

    const answerIsCorrect = option === activeItem.correctAnswer;
    const score = calculateKidsScore({
      isCorrect: answerIsCorrect,
      hintVisible,
      tryCount: 0,
      hasAnswered: true
    });

    setSelectedAnswer(option);
    setRoundScore(score);
    setSessionResults((current) => [
      ...current,
      {
        certifiedId: activeItem.certifiedId,
        isCorrect: answerIsCorrect,
        score: score.totalScore
      }
    ]);

    recordKidsSessionProgress({
      certifiedId: activeItem.certifiedId,
      category: activeItem.category,
      categoryName: activeItem.categoryName,
      stage: activeItem.stage,
      sessionMode: activeItem.sessionMode,
      selectedAnswer: option,
      correctAnswer: activeItem.correctAnswer,
      isCorrect: answerIsCorrect,
      score: score.totalScore,
      masteryLabel: score.masteryLabel,
      exceptionalLevel: score.exceptionalLevel,
      exceptionalLevelUnlocked: score.exceptionalLevelUnlocked,
      scoreBand: score.scoreBand,
      growthSignal: score.growthSignal,
      recoveryModeSuggestion: score.recoveryModeSuggestion,
      adaptiveNextStep: score.adaptiveNextStep,
      completedAt: new Date().toISOString()
    });

    onProgressUpdated?.();
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
      <section aria-labelledby="kids-gameplay-heading" style={{ marginTop: "28px" }}>
        <h2 id="kids-gameplay-heading">Play round</h2>
        <p>No gameplay items are available for this play mode.</p>
      </section>
    );
  }

  if (sessionComplete) {
    const correctCount = sessionResults.filter((result) => result.isCorrect).length;
    const averageScore = sessionResults.length > 0
      ? Math.round(sessionResults.reduce((sum, result) => sum + result.score, 0) / sessionResults.length)
      : 0;

    return (
      <section aria-labelledby="kids-session-result-heading" style={{ marginTop: "28px" }}>
        <article
          style={{
            border: "1px solid #bbf7d0",
            borderRadius: "22px",
            padding: "22px",
            background: "#f0fdf4"
          }}
        >
          <p style={{ margin: "0 0 6px", color: "#166534", fontSize: "14px" }}>
            Session complete
          </p>
          <h2 id="kids-session-result-heading" style={{ margin: "0 0 14px", fontSize: "28px" }}>
            Nice work. You finished this play round.
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
    <section aria-labelledby="kids-gameplay-heading" style={{ marginTop: "28px" }}>
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
          Challenge {questionIndex + 1} of {sessionItems.length} - {activeItem.categoryName} - {activeItem.stage}
        </p>
        <h2 id="kids-gameplay-heading" style={{ margin: 0, fontSize: "26px" }}>
          Play round
        </h2>
      </div>

      <article
        style={{
          border: "1px solid #e5e7eb",
          borderRadius: "22px",
          padding: "22px",
          background: "#ffffff"
        }}
      >
        <p style={{ margin: "0 0 10px", color: "#475569", lineHeight: 1.6 }}>
          Pick the best answer. Take your time.
        </p>

        <h3 style={{ margin: "0 0 18px", fontSize: "22px", lineHeight: 1.35 }}>
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
                  borderRadius: "16px",
                  padding: "14px 16px",
                  background: isSelected ? "#fef3c7" : "#f9fafb",
                  color: "#111827",
                  cursor: hasAnswered ? "default" : "pointer",
                  fontSize: "16px"
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
          onClick={() => setHintVisible((current) => !current)}
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
          {hintVisible ? "Hide clue" : "Show a small clue"}
        </button>

        {hintVisible && (
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
            Choose an answer when you are ready.
          </p>
        )}

        {hasAnswered && roundScore && (
          <>
            <div
              aria-live="polite"
              style={{
                marginTop: "18px",
                padding: "14px 16px",
                borderRadius: "16px",
                background: isCorrect ? "#ecfdf5" : "#fff7ed",
                color: isCorrect ? "#065f46" : "#9a3412"
              }}
            >
              <strong>{isCorrect ? "Great job. You found it." : "Good try. Review the clue and keep going."}</strong>
              <div style={{ marginTop: "8px" }}>
                {isCorrect
                  ? activeItem.insight
                  : `${activeItem.hint} Correct answer: ${activeItem.correctAnswer}.`}
              </div>
            </div>

            <aside
              aria-label="Kids score, mastery, and adaptive guidance"
              style={{
                marginTop: "18px",
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(170px, 1fr))",
                gap: "10px"
              }}
            >
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Score</div>
                <strong style={{ fontSize: "22px" }}>{roundScore.totalScore}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Mastery</div>
                <strong style={{ fontSize: "22px" }}>{roundScore.masteryLabel}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Level</div>
                <strong style={{ fontSize: "22px" }}>{roundScore.exceptionalLevel}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Score band</div>
                <strong>{roundScore.scoreBand}</strong>
              </div>
            </aside>

            <section
              aria-label="Adaptive next step"
              style={{
                marginTop: "18px",
                borderRadius: "18px",
                background: "#f8fafc",
                border: "1px solid #e5e7eb",
                padding: "16px"
              }}
            >
              <h3 style={{ margin: "0 0 8px", fontSize: "20px" }}>Adaptive guidance</h3>
              <p style={{ margin: "0 0 8px", color: "#475569", lineHeight: 1.55 }}>
                {roundScore.growthSignal}
              </p>
              <strong style={{ color: "#111827" }}>{roundScore.adaptiveNextStep}</strong>
            </section>

            <KidsPostSessionInsightPanel
              item={activeItem}
              score={roundScore}
              hasAnswered={hasAnswered}
              isCorrect={isCorrect}
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

export const KIDS_EXPANSION_ROOT_006_GAMEPLAY_VALIDATION_MARKERS = {
  answerGate: "answerLockedRef",
  scoreBandLabel: "Score band",
  adaptiveNextStepLabel: "Adaptive guidance",
  sessionInsightLabel: "Session insight",
  progressRecorder: "recordKidsSessionProgress",
  sessionCompletion: "View session result"
} as const;
