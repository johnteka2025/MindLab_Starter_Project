import React from "react";
import { BrowserRouter, Routes, Route, Link, useLocation } from "react-router-dom";
import GamePanel from "./GamePanel";
import DailyChallengeDetailPage from "./daily-challenge/DailyChallengeDetailPage";

function DebugShell(props: { children: React.ReactNode }) {
  const location = useLocation();

  return (
    <div style={{ fontFamily: "system-ui", padding: "16px" }}>
      <h1>MindLab Frontend (DEV Router)</h1>
      <p>
        Current path: <code>{location.pathname}</code>
      </p>
      <nav style={{ marginBottom: "12px" }}>
        <Link to="/app" style={{ marginRight: "12px" }}>Home /app</Link>
        <Link to="/app/daily">Daily /app/daily</Link>
      </nav>
      <hr />
      {props.children}
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Home route */}
        <Route
          path="/app"
          element={
            <DebugShell>
              <GamePanel />
            </DebugShell>
          }
        />

        {/* Daily challenge route */}
        <Route
          path="/app/daily"
          element={
            <DebugShell>
              <DailyChallengeDetailPage />
            </DebugShell>
          }
        />

        {/* Fallback */}
        <Route
          path="*"
          element={
            <DebugShell>
              <GamePanel />
            </DebugShell>
          }
        />
      </Routes>
    </BrowserRouter>
  );
}
