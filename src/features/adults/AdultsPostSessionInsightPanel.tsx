import React from "react";
import type { AdultsScoreResult } from "./adultsScoring";
import { getAdultsPostSessionInsight } from "./adultsPostSessionInsights";

type AdultsPostSessionInsightPanelProps = {
  scoreResult: AdultsScoreResult | null;
  isCorrect: boolean;
  itemInsight: string;
};

export default function AdultsPostSessionInsightPanel({
  scoreResult,
  isCorrect,
  itemInsight
}: AdultsPostSessionInsightPanelProps) {
  if (!scoreResult) return null;

  const insight = getAdultsPostSessionInsight(scoreResult, isCorrect, itemInsight);

  return (
    <section
      aria-labelledby="adults-post-session-heading"
      style={{
        marginTop: "18px",
        padding: "18px",
        borderRadius: "18px",
        background: "#f8fafc",
        border: "1px solid #e2e8f0"
      }}
    >
      <p style={{ margin: "0 0 6px", color: "#64748b", fontSize: "14px" }}>
        Session insight · {insight.tone}
      </p>
      <h3 id="adults-post-session-heading" style={{ margin: "0 0 10px", fontSize: "22px" }}>
        {insight.title}
      </h3>
      <p style={{ margin: "0 0 14px", color: "#475569", lineHeight: 1.6 }}>
        {insight.message}
      </p>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
          gap: "10px"
        }}
      >
        <div style={{ padding: "12px", borderRadius: "14px", background: "#ffffff" }}>
          <span style={{ display: "block", color: "#64748b", fontSize: "13px" }}>Overall score</span>
          <strong>{scoreResult.overallScore}</strong>
        </div>
        <div style={{ padding: "12px", borderRadius: "14px", background: "#ffffff" }}>
          <span style={{ display: "block", color: "#64748b", fontSize: "13px" }}>Mastery</span>
          <strong>{scoreResult.masteryLevel}</strong>
        </div>
        <div style={{ padding: "12px", borderRadius: "14px", background: "#ffffff" }}>
          <span style={{ display: "block", color: "#64748b", fontSize: "13px" }}>Recommended next step</span>
          <strong>{insight.recommendationLabel}</strong>
        </div>
      </div>
    </section>
  );
}
