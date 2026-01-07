import React from "react";

export default function ErrorBanner({ error }:{ error:string }){
  return (
    <div style={{
      background:"#fee2e2",
      color:"#991b1b",
      padding:"12px 16px",
      border:"1px solid #fecaca",
      borderRadius:"8px",
      marginBottom:"12px"
    }}>
      <strong>Frontend Error:</strong> {error}
    </div>
  );
}
