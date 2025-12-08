import React from "react";
import { HealthPanel } from "./components/HealthPanel";
import ProgressPanel from "./components/ProgressPanel";
import { GamePanel } from "./GamePanel";

export default function App() {
  return (
    <main>
      <h1>MindLab Frontend</h1>
      <HealthPanel />
      <GamePanel />
      <ProgressPanel />
    </main>
  );
}
