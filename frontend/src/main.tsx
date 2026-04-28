import * as React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import AdultsLanding from "./features/adults/AdultsLanding";
import KidsLanding from "./features/kids/KidsLanding";
import "./styles/mindlab_runtime.css";

function MindLabRouteGate() {
  const path = typeof window !== "undefined" ? window.location.pathname : "/";
  if (path.startsWith("/kids")) return <KidsLanding />;
  if (path.startsWith("/adults")) return <AdultsLanding />;
  return <App />;
}

const root = document.getElementById("root");

if (!root) {
  throw new Error("Root element not found.");
}

createRoot(root).render(
  <React.StrictMode>
    <MindLabRouteGate />
  </React.StrictMode>
);
