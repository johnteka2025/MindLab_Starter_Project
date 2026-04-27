import React, { useEffect, useMemo, useState } from "react";
import {
  getDefaultAdultsGameplayItemForSession,
  getAdultsGameplayItemsForSession
} from "./adultsGameplayContent";
import AdultsPostSessionInsightPanel from "./AdultsPostSessionInsightPanel";
import { recordAdultSessionResult } from "./adultsPersistence";
import { calculateAdultsScore } from "./adultsScoring";

type AdultsGameplayPanelProps = {
  selectedMode: string;
};

export default function AdultsGameplayPanel({ selectedMode }: AdultsGameplayPanelProps) {
  const availableItems = useMemo(() => getAdultsGameplayItemsForSession(selectedMode), [selectedMode]);
  const fallbackItem = useMemo(() => getDefaultAdultsGameplayItemForSession(selectedMode), [selectedMode]);
  const [selectedAnswer, setSelectedAnswer] = useState("");
  const [retryCount, setRetryCount] = useState(0);
  const [hintUse, setHintUse] = useState(0);
  const [savedProfileLabel, setSavedProfileLabel] = useState("");

  const activeItem = availableItems[0] ?? fallbackItem;
  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = selectedAnswer === activeItem.correctAnswer;
  const scoreResult = hasAnswered
    ? calculateAdultsScore({
        isCorrect,
        selectedAnswer,
        correctAnswer: activeItem.correctAnswer,
        hintUse,
        retryCount,
        completed: hasAnswered,
        expectedTimeSeconds: selectedMode === "Deep" ? 120 : 60,
        actualTimeSeconds: selectedMode === "Deep" ? 110 : 55,
        firstTrySuccess: isCorrect && retryCount === 0
      })
    : null;

  useEffect(() => {
    if (!scoreResult || !selectedAnswer) return;

    const savedProfile = recordAdultSessionResult({
      certifiedId: activeItem.certifiedId,
      category: activeItem.category,
      stage: activeItem.stage,
      sessionMode: selectedMode,
      selectedAnswer,
      correctAnswer: activeItem.correctAnswer,
      isCorrect,
      scoreResult
    });

    setSavedProfileLabel(`${savedProfile.currentStage} · ${savedProfile.currentCategory}`);
  }, [activeItem, isCorrect, scoreResult, selectedAnswer, selectedMode]);

  function handleAnswer(option: string) {
    if (selectedAnswer && option !== selectedAnswer) {
      setRetryCount((current) => current + 1);
    }

    setSelectedAnswer(option);
  }

  function handleHint() {
    setHintUse((current) => current + 1);
  }

  return (
    <section aria-labelledby="adults-gameplay-heading" style={{ marginTop: "28px" }}>
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
          {activeItem.certifiedId} · {activeItem.categoryName} · {activeItem.stage}
        </p>
        <h2 id="adults-gameplay-heading" style={{ margin: 0, fontSize: "26px" }}>
          Starter challenge
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
                key={option}
                type="button"
                onClick={() => handleAnswer(option)}
                style={{
                  textAlign: "left",
                  border: isSelected ? "2px solid #111827" : "1px solid #e5e7eb",
                  borderRadius: "14px",
                  padding: "14px 16px",
                  background: isSelected ? "#f1f5f9" : "#f9fafb",
                  color: "#111827",
                  cursor: "pointer"
                }}
              >
                {option}
              </button>
            );
          })}
        </div>

        <button
          type="button"
          onClick={handleHint}
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
          Use hint
        </button>

        {hasAnswered && (
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
            {isCorrect ? activeItem.insight : "Use the hint policy and try the best-supported answer."}
            {savedProfileLabel && (
              <div style={{ marginTop: "10px", color: "#334155" }}>
                Progress saved: <strong>{savedProfileLabel}</strong>
              </div>
            )}
          </div>
        )}

        <AdultsPostSessionInsightPanel
          scoreResult={scoreResult}
          isCorrect={isCorrect}
          itemInsight={activeItem.insight}
        />
      </article>
    </section>
  );
}
