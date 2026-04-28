import * as React from "react";
import KidsGameplayPanel from "./KidsGameplayPanel";
import {
  createKidsProgressReviewSummary,
  loadKidsProfile
} from "./kidsPersistence";
import {
  defaultKidsSessionMode,
  kidsSessionModes,
  type KidsSessionModeId
} from "./kidsSessionModes";

type KidsProgressReviewPanelProps = {
  refreshKey: number;
  onRefresh: () => void;
};

function KidsProgressReviewPanel({ refreshKey, onRefresh }: KidsProgressReviewPanelProps) {
  const summary = React.useMemo(
    () => createKidsProgressReviewSummary(loadKidsProfile()),
    [refreshKey]
  );

  return (
    <section
      aria-labelledby="kids-progress-review-heading"
      style={{
        marginTop: "28px",
        borderRadius: "22px",
        border: "1px solid #dbeafe",
        background: "#eff6ff",
        padding: "20px"
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          gap: "16px",
          alignItems: "flex-start",
          flexWrap: "wrap"
        }}
      >
        <div>
          <p style={{ margin: "0 0 6px", color: "#2563eb", fontSize: "14px" }}>
            Kids progress review
          </p>
          <h2 id="kids-progress-review-heading" style={{ margin: 0, fontSize: "24px" }}>
            Calm progress snapshot
          </h2>
        </div>

        <button
          type="button"
          onClick={onRefresh}
          style={{
            border: "1px solid #1d4ed8",
            borderRadius: "999px",
            padding: "10px 14px",
            background: "#ffffff",
            color: "#1d4ed8",
            cursor: "pointer"
          }}
        >
          Refresh progress
        </button>
      </div>

      <p style={{ margin: "12px 0 16px", color: "#334155", lineHeight: 1.6 }}>
        {summary.childSafeSummary}
      </p>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
          gap: "10px"
        }}
      >
        <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
          <div style={{ color: "#64748b", fontSize: "13px" }}>Rounds</div>
          <strong style={{ fontSize: "22px" }}>{summary.totalSessions}</strong>
        </div>

        <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
          <div style={{ color: "#64748b", fontSize: "13px" }}>Accuracy</div>
          <strong style={{ fontSize: "22px" }}>{summary.accuracyPercent}%</strong>
        </div>

        <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
          <div style={{ color: "#64748b", fontSize: "13px" }}>Last score</div>
          <strong style={{ fontSize: "22px" }}>{summary.lastScore}</strong>
        </div>

        <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
          <div style={{ color: "#64748b", fontSize: "13px" }}>Level</div>
          <strong>{summary.lastExceptionalLevel}</strong>
        </div>
      </div>

      <div
        style={{
          marginTop: "12px",
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
          gap: "10px"
        }}
      >
        <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
          <div style={{ color: "#64748b", fontSize: "13px" }}>Strongest category</div>
          <strong>{summary.strongestCategory}</strong>
        </div>

        <div style={{ borderRadius: "16px", background: "#ffffff", padding: "14px" }}>
          <div style={{ color: "#64748b", fontSize: "13px" }}>Practice category</div>
          <strong>{summary.practiceCategory}</strong>
        </div>
      </div>

      <div
        style={{
          marginTop: "12px",
          borderRadius: "16px",
          background: "#ffffff",
          padding: "14px",
          color: "#334155",
          lineHeight: 1.6
        }}
      >
        <strong style={{ color: "#111827" }}>Next step: </strong>
        {summary.lastAdaptiveNextStep}
        <br />
        <strong style={{ color: "#111827" }}>Recovery support: </strong>
        {summary.lastRecoveryModeSuggestion}
      </div>
    </section>
  );
}

export default function KidsLanding() {
  const [selectedMode, setSelectedMode] = React.useState<KidsSessionModeId>(defaultKidsSessionMode);
  const [progressRefreshKey, setProgressRefreshKey] = React.useState(0);

  function refreshProgressReview() {
    setProgressRefreshKey((value) => value + 1);
  }

  return (
    <main
      style={{
        minHeight: "100vh",
        padding: "32px",
        background: "#f8fafc",
        color: "#111827"
      }}
    >
      <section style={{ maxWidth: "980px", margin: "0 auto" }}>
        <header style={{ marginBottom: "28px" }}>
          <p style={{ margin: "0 0 8px", color: "#64748b", fontSize: "15px" }}>
            Kids practice - playful focus - calm learning
          </p>
          <h1 style={{ margin: 0, fontSize: "40px", lineHeight: 1.1 }}>
            Kids cognitive training
          </h1>
          <p style={{ maxWidth: "680px", color: "#475569", lineHeight: 1.7 }}>
            Short, friendly games for attention, matching, stories, patterns, memory, reasoning, and calm review.
          </p>
        </header>

        <section aria-labelledby="kids-session-mode-heading">
          <h2 id="kids-session-mode-heading" style={{ marginBottom: "14px", fontSize: "24px" }}>
            Choose a play mode
          </h2>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(210px, 1fr))",
              gap: "14px"
            }}
          >
            {kidsSessionModes.map((mode) => {
              const isSelected = selectedMode === mode.id;

              return (
                <button
                  key={mode.id}
                  type="button"
                  onClick={() => setSelectedMode(mode.id)}
                  style={{
                    textAlign: "left",
                    border: isSelected ? "2px solid #111827" : "1px solid #e5e7eb",
                    borderRadius: "20px",
                    padding: "18px",
                    background: isSelected ? "#fef3c7" : "#ffffff",
                    cursor: "pointer",
                    boxShadow: "0 8px 18px rgba(15, 23, 42, 0.06)"
                  }}
                >
                  <h3 style={{ margin: "0 0 8px", fontSize: "20px" }}>{mode.label}</h3>
                  <p style={{ margin: "0 0 8px", color: "#475569", lineHeight: 1.5 }}>
                    {mode.purpose}
                  </p>
                  <p style={{ margin: 0, color: "#64748b", fontSize: "14px" }}>
                    {mode.duration} - {mode.childSafety}
                  </p>
                </button>
              );
            })}
          </div>
        </section>

        <KidsProgressReviewPanel
          refreshKey={progressRefreshKey}
          onRefresh={refreshProgressReview}
        />

        <KidsGameplayPanel
          selectedMode={selectedMode}
          onProgressUpdated={refreshProgressReview}
        />
      </section>
    </main>
  );
}
