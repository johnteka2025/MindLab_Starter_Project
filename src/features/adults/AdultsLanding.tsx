import React, { useState } from "react";
import AdultsSessionModeSelector from "./AdultsSessionModeSelector";
import { defaultAdultsSessionMode } from "./adultsSessionModes";

export default function AdultsLanding() {
  const [selectedMode, setSelectedMode] = useState(defaultAdultsSessionMode);

  return (
    <main
      aria-label="Adults cognitive training"
      style={{
        minHeight: "100vh",
        padding: "48px 24px",
        fontFamily: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
        background: "#f8fafc",
        color: "#111827"
      }}
    >
      <section
        style={{
          maxWidth: "960px",
          margin: "0 auto",
          background: "#ffffff",
          border: "1px solid #e5e7eb",
          borderRadius: "24px",
          padding: "32px",
          boxShadow: "0 18px 45px rgba(15, 23, 42, 0.08)"
        }}
      >
        <p style={{ margin: 0, fontSize: "14px", letterSpacing: "0.08em", textTransform: "uppercase", color: "#475569" }}>
          MindLab Adults
        </p>
        <h1 style={{ margin: "12px 0", fontSize: "40px", lineHeight: 1.1 }}>
          Adult cognitive training
        </h1>
        <p style={{ margin: "0 0 24px", fontSize: "18px", lineHeight: 1.6, color: "#475569" }}>
          Choose a calm, focused training style built for adult reasoning, attention, decision-making, and mastery.
        </p>

        <AdultsSessionModeSelector selectedMode={selectedMode} onSelectMode={setSelectedMode} />

        <div
          aria-live="polite"
          style={{
            marginTop: "24px",
            padding: "16px 18px",
            borderRadius: "16px",
            background: "#eef2ff",
            color: "#312e81"
          }}
        >
          Selected session mode: <strong>{selectedMode}</strong>
        </div>
      </section>
    </main>
  );
}
