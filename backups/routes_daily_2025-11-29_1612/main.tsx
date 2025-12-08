import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import DailyChallengeDetailPage from "./daily-challenge/DailyChallengeDetailPage";
import "./index.css";

const path = window.location.pathname;

// Support both plain /daily and /app/daily (for different deployments)
const isDailyRoute =
  path === "/daily" ||
  path === "/daily/" ||
  path === "/app/daily" ||
  path === "/app/daily/";

ReactDOM.createRoot(
  document.getElementById("root") as HTMLElement
).render(
  <React.StrictMode>
    {isDailyRoute ? <DailyChallengeDetailPage /> : <App />}
  </React.StrictMode>
);
