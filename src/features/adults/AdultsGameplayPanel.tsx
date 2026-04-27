import React, { useMemo, useState } from "react";
import {
  getDefaultAdultsGameplayItemForSession,
  getAdultsGameplayItemsForSession
} from "./adultsGameplayContent";

type AdultsGameplayPanelProps = {
  selectedMode: string;
};

export default function AdultsGameplayPanel({ selectedMode }: AdultsGameplayPanelProps) {
  const availableItems = useMemo(() => getAdultsGameplayItemsForSession(selectedMode), [selectedMode]);
  const fallbackItem = useMemo(() => getDefaultAdultsGameplayItemForSession(selectedMode), [selectedMode]);
  const [selectedAnswer, setSelectedAnswer] = useState("");

  const activeItem = availableItems[0] ?? fallbackItem;
  const hasAnswered = selectedAnswer.length > 0;
  const isCorrect = selectedAnswer === activeItem.correctAnswer;

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
                onClick={() => setSelectedAnswer(option)}
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
          </div>
        )}
      </article>
    </section>
  );
}
