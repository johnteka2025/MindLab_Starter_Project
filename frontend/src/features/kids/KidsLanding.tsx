import { useState } from "react";
import KidsGameplayPanel from "./KidsGameplayPanel";
import {
  defaultKidsSessionMode,
  kidsSessionModes,
  type KidsSessionModeId
} from "./kidsSessionModes";

export default function KidsLanding() {
  const [selectedMode, setSelectedMode] = useState<KidsSessionModeId>(defaultKidsSessionMode);

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
            Kids practice ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· playful focus ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· calm learning
          </p>
          <h1 style={{ margin: 0, fontSize: "40px", lineHeight: 1.1 }}>
            Kids cognitive training
          </h1>
          <p style={{ maxWidth: "680px", color: "#475569", lineHeight: 1.7 }}>
            Short, friendly games for attention, matching, stories, patterns, and calm review.
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
                    {mode.duration} ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â· {mode.childSafety}
                  </p>
                </button>
              );
            })}
          </div>
        </section>

        <KidsGameplayPanel selectedMode={selectedMode} />
      </section>
    </main>
  );
}
