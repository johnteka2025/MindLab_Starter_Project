import { Link, Routes, Route, Navigate } from "react-router-dom";
import HealthPanel from "./components/HealthPanel";
import DailyChallengeDetailPage from "./daily-challenge/DailyChallengeDetailPage";
import ProgressPage from "./progress/ProgressPage";
import SolvePuzzle from "./pages/SolvePuzzle";

function Home() {
  return (
    <div>
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
      <HealthPanel />
    </div>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/app/daily" element={<DailyChallengeDetailPage />} />
      <Route path="/app/progress" element={<ProgressPage />} />

      {/* Option 6A: canonical Solve route */}
      <Route path="/app/solve" element={<SolvePuzzle />} />

      {/* Back-compat: if something still links /solve, redirect to canonical */}
      <Route path="/solve" element={<Navigate to="/app/solve" replace />} />
    </Routes>
  );
}
