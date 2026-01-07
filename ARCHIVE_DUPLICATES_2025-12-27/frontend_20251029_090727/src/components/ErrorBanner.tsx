import React from "react";
export default function ErrorBanner({ message }: { message?: string }) {
  if (!message) return null;
  return (
    <div style={{background:"#ffdddd",color:"#660000",padding:"8px",borderRadius:6,marginBottom:10}}>
      ⚠️ {message}
    </div>
  );
}
