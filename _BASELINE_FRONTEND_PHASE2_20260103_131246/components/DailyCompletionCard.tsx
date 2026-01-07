import React from "react";

export type DailyResultStatus = "correct" | "incorrect";

export interface DailyCompletionCardProps {
  status: DailyResultStatus;
  correctAnswer?: number | string;
  userAnswer?: number | string;
}

/**
 * DailyCompletionCard
 * -------------------
 * UI-only card that shows the result of a Daily Challenge answer.
 * - Uses a temporary local streak value (backend integration will replace this later)
 * - Accepts optional correctAnswer / userAnswer so it can be reused in places
 *   where we don't have the exact values yet.
 */
export function DailyCompletionCard({
  status,
  correctAnswer,
  userAnswer,
}: DailyCompletionCardProps) {
  const isCorrect = status === "correct";

  // Temporary UI-only streak value (backend version will replace this later)
  const streak = isCorrect ? 1 : 0;

  // Friendly messages (safe, no backend impact)
  const messages = {
    correct: [
      "Great job! 🎉",
      "You’re building strong thinking skills.",
      "Keep it up — consistency builds mastery!",
    ],
    incorrect: [
      "Nice try — learning happens even when you miss!",
      "You can do it — come back tomorrow and try again.",
      "Every mistake is a step toward improvement.",
    ],
  };

  const selectedMessages = isCorrect ? messages.correct : messages.incorrect;

  return (
    <div
      style={{
        border: "1px solid #ddd",
        padding: "20px",
        borderRadius: "10px",
        maxWidth: "450px",
        marginTop: "32px",
        backgroundColor: isCorrect ? "#e8ffe8" : "#ffecec",
      }}
    >
      <h2>Daily Challenge Result</h2>

      <p
        style={{
          fontSize: "20px",
          fontWeight: "bold",
          color: isCorrect ? "green" : "red",
        }}
      >
        {isCorrect ? "Correct! 🎉" : "Not quite ❌"}
      </p>

      {typeof userAnswer !== "undefined" && (
        <p>
          <strong>Your answer:</strong> {userAnswer}
        </p>
      )}

      {typeof correctAnswer !== "undefined" && (
        <p>
          <strong>Correct answer:</strong> {correctAnswer}
        </p>
      )}

      <hr />

      <div style={{ marginTop: "16px" }}>
        {selectedMessages.map((msg, i) => (
          <p key={i} style={{ marginBottom: "6px" }}>
            {msg}
          </p>
        ))}
      </div>

      <hr />

      <p style={{ fontSize: "18px", marginTop: "16px" }}>
        <strong>Streak:</strong> {streak} 🔥
      </p>
    </div>
  );
}

// Keep a default export for flexibility, in case any code uses the default form.
export default DailyCompletionCard;
