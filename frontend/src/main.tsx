import AdultsLanding from "./features/adults/AdultsLanding";
import "./styles/mindlab_runtime.css";
import "./env_probe";
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import { startMindLabKidsRuntime } from "./app/mindlab_kids_runtime.js";

const rootElement = document.getElementById("root");
const runtimeHost = document.getElementById("app");

if (!rootElement) {
  throw new Error("Root element #root not found in index.html");
}

if (!runtimeHost) {
  throw new Error("Runtime host #app not found in index.html");
}

const root = ReactDOM.createRoot(rootElement);

root.render(
  <React.StrictMode>
    <BrowserRouter>
      {window.location.pathname.startsWith("/adults") ? <AdultsLanding /> : <App />}
    </BrowserRouter>
  </React.StrictMode>
);

async function bootMindLabKidsRuntime() {
  try {
    await startMindLabKidsRuntime("#app");
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown runtime error";
    runtimeHost.innerHTML = `
      <div class="mindlab-card">
        <h2>MindLab runtime blocker</h2>
        <p id="mindlab-feedback">${message}</p>
      </div>
    `;
    console.error(error);
  }
}

if (typeof window !== "undefined") {
  window.requestAnimationFrame(() => {
    void bootMindLabKidsRuntime();
  });
}
