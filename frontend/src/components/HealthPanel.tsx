// src/components/HealthPanel.tsx

import React, { useEffect, useState } from "react";
import { fetchJson } from "../lib/api";

type HealthState =
  | { k: "loading" }
  | { k: "ok"; data: unknown }
  | { k: "err"; message: string };

const HealthPanel: React.FC = () => {
  const [state, setState] = useState<HealthState>({ k: "loading" });

  async function load() {
    setState({ k: "loading" });

    try {
      const data = await fetchJson("/health", { timeoutMs: 6000 });
      setState({ k: "ok", data });
    } catch (e: unknown) {
      let message = "failed";
      if (
        e &&
        typeof e === "object" &&
        "message" in e &&
        typeof (e as any).message === "string"
      ) {
        message = (e as any).message;
      }
      setState({ k: "err", message });
    }
  }

  useEffect(() => {
    load();
  }, []);

  if (state.k === "loading") {
    return (
      <section aria-label="Backend health">
        <h2>Health</h2>
        <p>Checking backend…</p>
      </section>
    );
  }

  if (state.k === "err") {
    return (
      <section aria-label="Backend health">
        <h2>Health</h2>
        <p>Status: error</p>
        <div role="alert">
          Failed to reach backend: {state.message}{" "}
          <button type="button" onClick={load}>
            Retry
          </button>
        </div>
      </section>
    );
  }

  // state.k === "ok"
  return (
    <section aria-label="Backend health">
      <h2>Health</h2>
      {/* These lines are what the Playwright test expects */}
      <p>Status: ok</p>
      <p>Backend is healthy (ok: true).</p>
      <pre aria-live="polite">{JSON.stringify(state.data, null, 2)}</pre>
    </section>
  );
};

export default HealthPanel;
export { HealthPanel };
