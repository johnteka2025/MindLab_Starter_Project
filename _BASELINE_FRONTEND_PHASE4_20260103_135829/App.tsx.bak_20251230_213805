import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import HealthPanel from "./components/HealthPanel";
import DailyChallengeDetailPage from "./daily-challenge/DailyChallengeDetailPage";
import ProgressPage from "./progress/ProgressPage";

function Home() {
  return (
    <div style={{ padding: "1.5rem" }}>
      <h1>MindLab Frontend</h1>
      <p>Choose an area:</p>
      <ul>
        <li>
          <Link to="/app/daily">Daily UI</Link>
        </li>
        <li>
          <Link to="/app/progress">Progress</Link>
        </li>
      </ul>

      {/* Show the Health / Puzzles / Progress dashboard here */}
      <HealthPanel />
    </div>
  );
}

export default function App() {
  return (
    <Router>
      <Routes>
        {/* Root and /app use the Home dashboard */}
        <Route path="/" element={<Home />} />
        <Route path="/app" element={<Home />} />

        {/* Daily UI page used by Playwright tests */}
        <Route path="/app/daily" element={<DailyChallengeDetailPage />} />

        {/* Progress page */}
        <Route path="/app/progress" element={<ProgressPage />} />
      </Routes>
    </Router>
  );
}
