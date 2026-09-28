import React, { useState } from "react";
import { seniorsAgeModeFoundation } from "../../ageModes/seniorsAgeModeFoundation";
import { seniorsGameplayAccessibilityProgress } from "../../ageModes/seniorsGameplayAccessibilityProgress";
import SeniorsGameplayPanel from "./SeniorsGameplayPanel";
import {
  defaultSeniorsSessionMode,
  seniorsSessionModes,
  type SeniorsSessionModeId
} from "./seniorsSessionModes";

export default function SeniorsLanding() {
  const [selectedMode, setSelectedMode] = useState<SeniorsSessionModeId>(
    defaultSeniorsSessionMode
  );

  return (
    <main
      aria-label="Seniors cognitive confidence"
      style={{
        minHeight: "100vh",
        padding: "40px 22px",
        fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
        background: "#f8fafc",
        color: "#0f172a"
      }}
    >
      <section
        style={{
          maxWidth: "960px",
          margin: "0 auto",
          background: "#ffffff",
          border: "1px solid #cbd5e1",
          borderRadius: "24px",
          padding: "30px",
          boxShadow: "0 14px 36px rgba(15, 23, 42, 0.06)"
        }}
      >
        <p
          style={{
            margin: 0,
            fontSize: "15px",
            fontWeight: 700,
            letterSpacing: "0.06em",
            textTransform: "uppercase",
            color: "#475569"
          }}
        >
          MindLab Seniors
        </p>
        <h1 style={{ margin: "12px 0", fontSize: "40px", lineHeight: 1.15 }}>
          Seniors cognitive confidence
        </h1>
        <p style={{ margin: "0 0 12px", fontSize: "20px", lineHeight: 1.6, color: "#334155" }}>
          Clear, respectful practice for memory, focus, attention, patterns, and steady confidence.
        </p>
        <p style={{ margin: "0 0 26px", fontSize: "18px", lineHeight: 1.6, color: "#475569" }}>
          {seniorsGameplayAccessibilityProgress.progressSummary}
        </p>

        <section aria-labelledby="seniors-session-mode-heading">
          <h2 id="seniors-session-mode-heading" style={{ margin: "0 0 10px", fontSize: "28px" }}>
            Choose your practice style
          </h2>
          <p style={{ margin: "0 0 16px", fontSize: "18px", lineHeight: 1.6, color: "#475569" }}>
            Take your time. There is no speed penalty.
          </p>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(210px, 1fr))",
              gap: "14px"
            }}
          >
            {seniorsSessionModes.map((mode) => {
              const isSelected = selectedMode === mode.id;

              return (
                <button
                  key={mode.id}
                  type="button"
                  aria-pressed={isSelected}
                  onClick={() => setSelectedMode(mode.id)}
                  style={{
                    minHeight: "150px",
                    textAlign: "left",
                    border: isSelected ? "2px solid #0f172a" : "1px solid #cbd5e1",
                    borderRadius: "18px",
                    padding: "18px",
                    background: isSelected ? "#eef2f7" : "#ffffff",
                    color: "#0f172a",
                    cursor: "pointer"
                  }}
                >
                  <span style={{ display: "block", fontSize: "21px", fontWeight: 700, marginBottom: "8px" }}>
                    {mode.label}
                  </span>
                  <span style={{ display: "block", fontSize: "16px", color: "#475569", marginBottom: "10px" }}>
                    {mode.duration} - {mode.supportStyle}
                  </span>
                  <span style={{ display: "block", fontSize: "17px", lineHeight: 1.5, color: "#334155" }}>
                    {mode.description}
                  </span>
                </button>
              );
            })}
          </div>
        </section>

        <div
          aria-live="polite"
          style={{
            marginTop: "22px",
            padding: "16px 18px",
            borderRadius: "16px",
            background: "#eef6ff",
            color: "#1e3a8a",
            fontSize: "18px"
          }}
        >
          Selected practice mode: <strong>{selectedMode}</strong>
        </div>

        <div
          data-testid="seniors-accessibility-contract"
          style={{
            marginTop: "16px",
            padding: "14px 18px",
            borderRadius: "16px",
            background: "#f8fafc",
            color: "#475569",
            fontSize: "16px",
            lineHeight: 1.6
          }}
        >
          {seniorsAgeModeFoundation.uxTone.replaceAll("_", " ")}.{" "}
          {seniorsAgeModeFoundation.accessibilityModel.replaceAll("_", " ")}.
        </div>

        <SeniorsGameplayPanel selectedMode={selectedMode} />
      </section>
    </main>
  );
}
