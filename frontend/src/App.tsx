// src/App.tsx

import React from "react";
import { HealthPanel } from "./components/HealthPanel";
import GamePanel from "./GamePanel";

function App() {
  return (
    <main>
      <h1>MindLab Frontend</h1>

      <section aria-label="Health section">
        <HealthPanel />
      </section>

      <section aria-label="Puzzles section">
        <GamePanel />
      </section>
    </main>
  );
}

export default App;
