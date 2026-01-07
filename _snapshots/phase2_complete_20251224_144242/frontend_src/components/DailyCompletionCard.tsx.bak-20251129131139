import React from "react";

interface Props {
    result: "correct" | "incorrect";
    correctAnswer: number;
    userAnswer: number;
}

/**
 * SAFE VERSION — FRONTEND-ONLY STREAK DISPLAY
 * This does NOT affect backend, only UI.
 */
export default function DailyCompletionCard({ result, correctAnswer, userAnswer }: Props) {
    
    // Temporary UI-only streak logic — always increases by 1
    // Later we replace this with backend streak API
    const streak = result === "correct" ? 1 : 0;

    return (
        <div style={{
            border: "1px solid #ddd",
            padding: "16px",
            borderRadius: "8px",
            maxWidth: "400px",
            marginTop: "24px"
        }}>
            <h2>Daily Result</h2>

            {result === "correct" ? (
                <p style={{ color: "green" }}>Correct! 🎉</p>
            ) : (
                <p style={{ color: "red" }}>Incorrect ❌</p>
            )}

            <p><strong>Your answer:</strong> {userAnswer}</p>
            <p><strong>Correct answer:</strong> {correctAnswer}</p>

            <hr />

            <p style={{ fontSize: "18px" }}>
                <strong>Streak: </strong> {streak} 🔥
            </p>
        </div>
    );
}
