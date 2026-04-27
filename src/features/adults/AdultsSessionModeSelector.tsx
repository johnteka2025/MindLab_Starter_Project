"use client";

import React from "react";
import { adultsSessionModes, defaultAdultsSessionMode } from "./adultsSessionModes";

type AdultsSessionModeSelectorProps = {
  selectedMode?: string;
  onSelectMode?: (modeId: string) => void;
};

export default function AdultsSessionModeSelector({
  selectedMode = defaultAdultsSessionMode,
  onSelectMode
}: AdultsSessionModeSelectorProps) {
  return (
    <section aria-labelledby="adults-session-mode-heading" style={{ marginTop: "28px" }}>
      <div style={{ marginBottom: "16px" }}>
        <h2 id="adults-session-mode-heading" style={{ margin: "0 0 8px", fontSize: "26px" }}>
          Choose your session style
        </h2>
        <p style={{ margin: 0, color: "#475569", lineHeight: 1.6 }}>
          Select the pace that fits your focus today.
        </p>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(210px, 1fr))", gap: "16px" }}>
        {adultsSessionModes.map((mode) => {
          const isSelected = selectedMode === mode.id;

          return (
            <button
              key={mode.id}
              type="button"
              aria-pressed={isSelected}
              onClick={() => onSelectMode?.(mode.id)}
              style={{
                textAlign: "left",
                border: isSelected ? "2px solid #111827" : "1px solid #e5e7eb",
                borderRadius: "18px",
                padding: "18px",
                background: isSelected ? "#f1f5f9" : "#f9fafb",
                color: "#111827",
                cursor: "pointer"
              }}
            >
              <span style={{ display: "block", fontSize: "20px", fontWeight: 700, marginBottom: "8px" }}>
                {mode.label}
              </span>
              <span style={{ display: "block", fontSize: "14px", color: "#64748b", marginBottom: "10px" }}>
                {mode.duration} Ã‚Â· {mode.cognitiveLoad}
              </span>
              <span style={{ display: "block", lineHeight: 1.5, color: "#475569" }}>
                {mode.description}
              </span>
            </button>
          );
        })}
      </div>
    </section>
  );
}
