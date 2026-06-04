import React from "react";
import AppBase from "./AppBase.jsx";
import LocalProfileGate from "./LocalProfileGate.jsx";

export default function App() {
  return (
    <LocalProfileGate>
      <AppBase />
    </LocalProfileGate>
  );
}
