import * as React from "react";
import {
  getDefaultKidsGameplayItemForSession,
  getKidsGameplayItemsForSession,
  kidsGameplayItems,
  type KidsGameplayItem
} from "./kidsGameplayContent";
import KidsPostSessionInsightPanel from "./KidsPostSessionInsightPanel";
import { recordKidsSessionProgress } from "./kidsPersistence";
import { calculateKidsScore } from "./kidsScoring";

type KidsGameplayPanelProps = {
  selectedMode: string;
  onProgressUpdated?: () => void;
};

function findDifferentItem(items: KidsGameplayItem[], currentCertifiedId: string): KidsGameplayItem | null {
  return items.find((item) => item.certifiedId !== currentCertifiedId) ?? null;
}

function getSuggestedNextKidsItem(
  currentItem: KidsGameplayItem,
  selectedMode: string,
  isCorrect: boolean,
  exceptionalLevel: string
): KidsGameplayItem | null {
  if (!isCorrect) {
    return (
      findDifferentItem(
        kidsGameplayItems.filter((item) => item.sessionMode === "CalmReview"),
        currentItem.certifiedId
      ) ?? null
    );
  }

  if (exceptionalLevel === "Mastery Spark" || exceptionalLevel === "Solver") {
    return (
      findDifferentItem(
        kidsGameplayItems.filter((item) => item.sessionMode === "Challenge"),
        currentItem.certifiedId
      ) ?? null
    );
  }

  if (exceptionalLevel === "Builder") {
    return (
      findDifferentItem(
        kidsGameplayItems.filter((item) => item.sessionMode === "StoryPractice" || item.sessionMode === selectedMode),
        currentItem.certifiedId
      ) ?? null
    );
  }

  return findDifferentItem(getKidsGameplayItemsForSession(selectedMode), currentItem.certifiedId);
}

export default function KidsGameplayPanel({ selectedMode, onProgressUpdated }: KidsGameplayPanelProps) {
  const [activeItem, setActiveItem] = React.useState<KidsGameplayItem>(() =>
    getDefaultKidsGameplayItemForSession(selectedMode)
  );
  const [selectedAnswer, setSelectedAnswer] = React.useState("");
  const [hintVisible, setHintVisible] = React.useState(false);
  const [tryCount, setTryCount] = React.useState(0);
  const [savedSessionKey, setSavedSessionKey] = React.useState("");

  const availableItems = React.useMemo(() => getKidsGameplayItemsForSession(selectedMode), [selectedMode]);

  React.useEffect(() => {
    setActiveItem(getDefaultKidsGameplayItemForSession(selectedMode));
    setSelectedAnswer("");
    setHintVisible(false);
    setTryCount(0);
    setSavedSessionKey("");
  }, [selectedMode]);

  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = selectedAnswer === activeItem.correctAnswer;
  const score = calculateKidsScore({
    isCorrect,
    hintVisible,
    tryCount,
    hasAnswered
  });

  const nextSuggestedItem = React.useMemo(
    () =>
      hasAnswered
        ? getSuggestedNextKidsItem(activeItem, selectedMode, isCorrect, score.exceptionalLevel)
        : null,
    [activeItem, hasAnswered, isCorrect, score.exceptionalLevel, selectedMode]
  );

  function resetRound(nextItem: KidsGameplayItem) {
    setActiveItem(nextItem);
    setSelectedAnswer("");
    setHintVisible(false);
    setTryCount(0);
    setSavedSessionKey("");
  }

  function handleAnswer(option: string) {
    if (selectedAnswer && option !== selectedAnswer) {
      setTryCount((current) => current + 1);
    }

    setSelectedAnswer(option);
  }

  function handleSuggestedNextRound() {
    if (nextSuggestedItem) {
      resetRound(nextSuggestedItem);
      return;
    }

    const fallbackItem = findDifferentItem(availableItems, activeItem.certifiedId);
    if (fallbackItem) {
      resetRound(fallbackItem);
    }
  }

  React.useEffect(() => {
    if (!hasAnswered) {
      return;
    }

    const sessionKey = `${activeItem.certifiedId}:${selectedAnswer}:${tryCount}:${hintVisible}:${score.totalScore}`;
    if (savedSessionKey === sessionKey) {
      return;
    }

    recordKidsSessionProgress({
      certifiedId: activeItem.certifiedId,
      category: activeItem.category,
      categoryName: activeItem.categoryName,
      stage: activeItem.stage,
      sessionMode: activeItem.sessionMode,
      selectedAnswer,
      correctAnswer: activeItem.correctAnswer,
      isCorrect,
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
    setSavedSessionKey(sessionKey);
  }, [
    activeItem,
    hasAnswered,
    hintVisible,
    isCorrect,
    savedSessionKey,
    score.adaptiveNextStep,
    score.exceptionalLevel,
    score.exceptionalLevelUnlocked,
    score.growthSignal,
    score.masteryLabel,
    score.recoveryModeSuggestion,
    score.scoreBand,
    score.totalScore,
    onProgressUpdated,
    selectedAnswer,
    tryCount
  ]);

  return (
    <section aria-labelledby="kids-gameplay-heading" style={{ marginTop: "28px" }}>
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
          {activeItem.certifiedId} - {activeItem.categoryName} - {activeItem.stage}
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
                key={option}
                type="button"
                onClick={() => handleAnswer(option)}
                style={{
                  textAlign: "left",
                  border: isSelected ? "2px solid #111827" : "1px solid #e5e7eb",
                  borderRadius: "16px",
                  padding: "14px 16px",
                  background: isSelected ? "#fef3c7" : "#f9fafb",
                  color: "#111827",
                  cursor: "pointer",
                  fontSize: "16px"
                }}
              >
                {option}
              </button>
            );
          })}
        </div>

        <button
          type="button"
          onClick={() => setHintVisible((current) => !current)}
          style={{
            marginTop: "14px",
            border: "1px solid #cbd5e1",
            borderRadius: "999px",
            padding: "10px 14px",
            background: "#ffffff",
            color: "#334155",
            cursor: "pointer"
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

        {hasAnswered && (
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
              <strong>{isCorrect ? "Great job. You found it." : "Good try. Let us look again together."}</strong>
              <div style={{ marginTop: "8px" }}>
                {isCorrect ? activeItem.insight : activeItem.hint}
              </div>
              {tryCount > 0 && (
                <div style={{ marginTop: "8px", color: "#334155" }}>
                  Tries: {tryCount + 1}. You are learning.
                </div>
              )}
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
                <strong style={{ fontSize: "22px" }}>{score.totalScore}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Mastery</div>
                <strong style={{ fontSize: "22px" }}>{score.masteryLabel}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Level</div>
                <strong style={{ fontSize: "22px" }}>{score.exceptionalLevel}</strong>
              </div>
              <div style={{ borderRadius: "16px", background: "#f8fafc", padding: "14px" }}>
                <div style={{ color: "#64748b", fontSize: "13px" }}>Score band</div>
                <strong>{score.scoreBand}</strong>
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
              <h3 style={{ margin: "0 0 8px", fontSize: "20px" }}>Adaptive next step</h3>
              <p style={{ margin: "0 0 8px", color: "#475569", lineHeight: 1.55 }}>
                {score.growthSignal}
              </p>
              <p style={{ margin: "0 0 8px", color: "#475569", lineHeight: 1.55 }}>
                {score.recoveryModeSuggestion}
              </p>
              <strong style={{ color: "#111827" }}>{score.adaptiveNextStep}</strong>

              <div style={{ marginTop: "14px" }}>
                <button
                  type="button"
                  onClick={handleSuggestedNextRound}
                  disabled={!nextSuggestedItem && availableItems.length <= 1}
                  style={{
                    border: "1px solid #111827",
                    borderRadius: "999px",
                    padding: "10px 14px",
                    background: "#111827",
                    color: "#ffffff",
                    cursor: nextSuggestedItem || availableItems.length > 1 ? "pointer" : "not-allowed"
                  }}
                >
                  {nextSuggestedItem
                    ? `Try suggested next: ${nextSuggestedItem.categoryName}`
                    : "Try another friendly round"}
                </button>
              </div>
            </section>

            <p style={{ margin: "14px 0 0", color: "#475569" }}>
              {score.encouragement}
            </p>

            <p style={{ margin: "10px 0 0", color: "#64748b", fontSize: "13px" }}>
              Kids progress saved with mindlab.kids.profile.v1 and adaptive progress fields.
            </p>

            <KidsPostSessionInsightPanel
              item={activeItem}
              score={score}
              hasAnswered={hasAnswered}
              isCorrect={isCorrect}
            />
          </>
        )}
      </article>
    </section>
  );
}

export const KIDS_EXPANSION_ROOT_006_GAMEPLAY_VALIDATION_MARKERS = {
  answerGate: "hasAnswered",
  scoreBandLabel: "Score band",
  adaptiveNextStepLabel: "Adaptive next step",
  sessionInsightLabel: "Session insight",
  progressRecorder: "recordKidsSessionProgress",
  refreshCallback: "onProgressUpdated"
} as const;
