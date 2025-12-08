import React from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import GamePanel from "./GamePanel";
import DailyChallengeDetailPage from "./daily-challenge/DailyChallengeDetailPage";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Homepage puzzle */}
        <Route path="/app" element={<GamePanel />} />

        {/* Daily Challenge UI */}
        <Route path="/app/daily" element={<DailyChallengeDetailPage />} />

        {/* Default fallback */}
        <Route path="*" element={<GamePanel />} />
      </Routes>
    </BrowserRouter>
  );
}
