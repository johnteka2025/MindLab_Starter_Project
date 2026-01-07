import { jsx as _jsx } from "react/jsx-runtime";
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import DailyChallengeDetailPage from "./daily-challenge/DailyChallengeDetailPage";
import "./index.css";
const path = window.location.pathname;
// Support both plain /daily and /app/daily (for different deployments)
const isDailyRoute = path === "/daily" ||
    path === "/daily/" ||
    path === "/app/daily" ||
    path === "/app/daily/";
ReactDOM.createRoot(document.getElementById("root")).render(_jsx(React.StrictMode, { children: isDailyRoute ? _jsx(DailyChallengeDetailPage, {}) : _jsx(App, {}) }));
