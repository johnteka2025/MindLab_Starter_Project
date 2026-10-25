import * as React from "react";
import { describeMastery, type MasteryState, type MasteryDomain } from "./masteryProgression";

export default function MasteryProgressPanel({state, saved, focus}:
  { state: MasteryState; saved: boolean; focus?: MasteryDomain | null }) {
  const domains = describeMastery(state);
  const next = domains.find(row => row.domain === focus) ?? domains.find(row => row.sessions > 0) ?? domains[0];
  return (
    <section aria-label="Earned skill mastery" style={{marginTop:20,padding:18,border:"1px solid #cbd5e1",borderRadius:16,background:"#fff",color:"#0f172a"}}>
      <h3 style={{margin:"0 0 8px",fontSize:20}}>Your skill journey</h3>
      <p style={{margin:"0 0 12px",lineHeight:1.5}}>Earned levels reflect practice across different game sessions. A harder day does not erase an earned level.</p>
      <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(145px,1fr))",gap:8}}>
        {domains.map(row => (
          <div key={row.domain} style={{background:row.domain===focus?"#eff6ff":"#f8fafc",borderRadius:12,padding:12}}>
            <div style={{fontSize:14,fontWeight:600}}>{row.label}</div>
            <strong style={{display:"block",marginTop:4,fontSize:18}}>{row.level}</strong>
            <div style={{fontSize:13,color:"#475569"}}>{row.sessions} sessions · {row.uniqueCorrect} distinct correct</div>
          </div>
        ))}
      </div>
      <p style={{margin:"12px 0 0",lineHeight:1.5}}><strong>Next goal — {next.label}:</strong> {next.objective}</p>
      {!saved && <p role="status" style={{color:"#9a3412",margin:"10px 0 0"}}>Progress is visible now but could not be saved on this device.</p>}
      <p style={{fontSize:12,color:"#64748b",margin:"10px 0 0"}}>Prototype goals are provisional. In-game progress is not a health or cognitive diagnosis.</p>
    </section>
  );
}
