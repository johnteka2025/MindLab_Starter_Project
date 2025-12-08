import React from "react";

interface Props {
    result: "correct" | "incorrect";
    correctAnswer: number;
    userAnswer: number;
}

export default function DailyCompletionCard({ result, correctAnswer, userAnswer }: Props) {
    
    // Temporary UI-only streak value (backend version will replace this later)
    const streak = result === "correct" ? 1 : 0;

    // Friendly messages (safe, no backend impact)
    const messages = {
        correct: [
            "Great job! 🎉",
            "You’re building strong thinking skills.",
            "Keep it up — consistency builds mastery!"
        ],
        incorrect: [
            "Nice try — learning happens even when you miss!",
            "You can do it — come back tomorrow and try again.",
            "Every mistake is a step toward improvement."
        ]
    };

    const selectedMessages = result === "correct"
        ? messages.correct
        : messages.incorrect;

    return (
        <div style={{
            border: "1px solid #ddd",
            padding: "20px",
            borderRadius: "10px",
            maxWidth: "450px",
            marginTop: "32px",
            backgroundColor: result === "correct" ? "#e8ffe8" : "#ffecec"
        }}>
            <h2>Daily Challenge Result</h2>

            <p style={{ fontSize: "20px", fontWeight: "bold", color: result === "correct" ? "green" : "red" }}>
                {result === "correct" ? "Correct! 🎉" : "Not quite ❌"}
            </p>

            <p><strong>Your answer:</strong> {userAnswer}</p>
            <p><strong>Correct answer:</strong> {correctAnswer}</p>

            <hr />

            <div style={{ marginTop: "16px" }}>
                {selectedMessages.map((msg, i) => (
                    <p key={i} style={{ marginBottom: "6px" }}>{msg}</p>
                ))}
            </div>

            <hr />

            <p style={{ fontSize: "18px", marginTop: "16px" }}>
                <strong>Streak:</strong> {streak} 🔥
            </p>
        </div>
    );
}
