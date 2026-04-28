import * as React from "react";
import type { KidsGameplayItem } from "./kidsGameplayContent";
import { createKidsPostSessionInsight } from "./kidsPostSessionInsights";
import type { KidsScoreResult } from "./kidsScoring";

type KidsPostSessionInsightPanelProps = {
  item: KidsGameplayItem;
  score: KidsScoreResult;
  hasAnswered: boolean;
  isCorrect: boolean;
};

export default function KidsPostSessionInsightPanel({
  item,
  score,
  hasAnswered,
  isCorrect
}: KidsPostSessionInsightPanelProps) {
  const insight = React.useMemo(
    () => createKidsPostSessionInsight(item, score, isCorrect),
    [item, score, isCorrect]
  );

  if (!hasAnswered) {
    return null;
  }

  return (
    <section
      aria-labelledby="kids-session-insight-heading"
      style={{
        marginTop: "18px",
        borderRadius: "18px",
        background: "#f0fdf4",
        border: "1px solid #bbf7d0",
        padding: "16px"
      }}
    >
      <h3 id="kids-session-insight-heading" style={{ margin: "0 0 10px", fontSize: "20px" }}>
        {insight.title}
      </h3>
      <p style={{ margin: "0 0 8px", color: "#166534", lineHeight: 1.55 }}>
        {insight.summary}
      </p>
      <p style={{ margin: "0 0 8px", color: "#166534", lineHeight: 1.55 }}>
        {insight.celebration}
      </p>
      <p style={{ margin: "0 0 8px", color: "#334155", lineHeight: 1.55 }}>
        {insight.practiceFocus}
      </p>
      <strong style={{ color: "#14532d" }}>{insight.nextStep}</strong>
    </section>
  );
}
