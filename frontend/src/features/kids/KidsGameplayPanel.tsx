import React, { useMemo, useState } from "react";
import {
  getDefaultKidsGameplayItemForSession,
  getKidsGameplayItemsForSession
} from "./kidsGameplayContent";
import { calculateKidsScore } from "./kidsScoring";

type KidsGameplayPanelProps = {
  selectedMode: string;
};

export default function KidsGameplayPanel({ selectedMode }: KidsGameplayPanelProps) {
  const availableItems = useMemo(() => getKidsGameplayItemsForSession(selectedMode), [selectedMode]);
  const fallbackItem = useMemo(() => getDefaultKidsGameplayItemForSession(selectedMode), [selectedMode]);
  const [selectedAnswer, setSelectedAnswer] = useState("");
  const [hintVisible, setHintVisible] = useState(false);
  const [tryCount, setTryCount] = useState(0);

  const activeItem = availableItems[0] ?? fallbackItem;
  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = selectedAnswer === activeItem.correctAnswer;
  const score = calculateKidsScore({
    isCorrect,
    hintVisible,
    tryCount,
    hasAnswered
  });

  function handleAnswer(option: string) {
    if (selectedAnswer && option !== selectedAnswer) {
      setTryCount((current) => current + 1);
    }

    setSelectedAnswer(option);
  }

  return (
    <section aria-labelledby="kids-gameplay-heading" style={{ marginTop: "28px" }}>
      <div style={{ marginBottom: "16px" }}>
        <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
          {activeItem.certifiedId} Â· {activeItem.categoryName} Â· {activeItem.stage}
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

        {hasAnswered && (
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
        )}

        <aside
          aria-label="Kids score and mastery"
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
            <div style={{ color: "#64748b", fontSize: "13px" }}>Next step</div>
            <strong>{score.nextStep}</strong>
          </div>
        </aside>

        <p style={{ margin: "14px 0 0", color: "#475569" }}>
          {score.encouragement}
        </p>
      </article>
    </section>
  );
}
