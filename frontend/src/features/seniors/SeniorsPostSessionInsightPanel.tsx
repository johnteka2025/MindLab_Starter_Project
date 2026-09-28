import React from "react";
import type { SeniorsScoreResult } from "./seniorsScoring";
import { getSeniorsPostSessionInsight } from "./seniorsPostSessionInsights";

type SeniorsPostSessionInsightPanelProps = {
  scoreResult: SeniorsScoreResult | null;
  isCorrect: boolean;
  itemInsight: string;
};

export default function SeniorsPostSessionInsightPanel({
  scoreResult,
  isCorrect,
  itemInsight
}: SeniorsPostSessionInsightPanelProps) {
  if (!scoreResult) return null;

  const insight = getSeniorsPostSessionInsight(scoreResult, isCorrect, itemInsight);

  return (
    <section
      aria-labelledby="seniors-post-session-heading"
      style={{
        marginTop: "18px",
        padding: "20px",
        borderRadius: "18px",
        background: "#f8fafc",
        border: "1px solid #cbd5e1"
      }}
    >
      <h3
        id="seniors-post-session-heading"
        style={{ margin: "0 0 10px", fontSize: "24px", lineHeight: 1.25 }}
      >
        {insight.title}
      </h3>
      <p style={{ margin: "0 0 10px", fontSize: "18px", lineHeight: 1.6, color: "#334155" }}>
        {insight.message}
      </p>
      <p style={{ margin: 0, fontSize: "18px", lineHeight: 1.6, color: "#334155" }}>
        <strong>Next step:</strong> {insight.nextStep}
      </p>
    </section>
  );
}
