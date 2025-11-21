import { useState } from "react";
import { api } from "./api";
import { saveToken, getToken, clearToken } from "./auth";
import ErrorBanner from "./components/ErrorBanner";
import "./index.css";

export default function App() {
  const [email, setEmail] = useState("you@example.com");
  const [password, setPassword] = useState("pass1234");
  const [out, setOut] = useState<string>("");
  const [err, setErr] = useState<string>("");

  async function run<T>(f: () => Promise<T>) {
    setErr(""); setOut("");
    try { const r = await f(); setOut(JSON.stringify(r, null, 2)); }
    catch(e:any){ setErr(e?.message || String(e)); }
  }

  return (
    <div style={{padding:24,maxWidth:1000,margin:"0 auto"}}>
      <h1>MindLab Frontend</h1>
      <p>API base: <code>{import.meta.env.VITE_API_BASE}</code></p>
      <ErrorBanner message={err}/>
      <button onClick={()=>run(api.health)}>Check /health</button>

      <h3 style={{marginTop:24}}>Authentication</h3>
      <input value={email} onChange={e=>setEmail(e.target.value)} placeholder="you@example.com" />
      <input type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="••••••••" />
      <button onClick={()=>run(()=>api.register(email,password))}>Register</button>
      <button onClick={()=>run(async()=>{
        const r:any = await api.login(email,password);
        saveToken(r.token); return { saved:true };
      })}>Login</button>
      <button onClick={()=>{ clearToken(); setOut("logged out"); }}>Logout</button>

      <h3 style={{marginTop:24}}>Game</h3>
      <button onClick={()=>run(()=>api.nextPuzzle(getToken()||""))}>Get Next Puzzle</button>
      <button onClick={()=>run(()=>api.world(getToken()||""))}>World State</button>

      <pre style={{background:"#0b1220",color:"#eef1f7",padding:16,borderRadius:8,marginTop:16,overflow:"auto"}}>
{out}
      </pre>
    </div>
  );
}
