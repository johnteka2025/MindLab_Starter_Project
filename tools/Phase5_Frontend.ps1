<# Phase5_Frontend.ps1
   UX polish for the frontend:
   - Robust API client with timeout + retry + 401(expired) auto-logout
   - ErrorBoundary + ARIA & focus management
   - Clear loading/error states
   - Sanity checks (starts or verifies Vite and opens the app)
#>

param(
  [int]$Port    = 5177,
  [int]$ApiPort = 8085
)

$ErrorActionPreference = 'Stop'
function Say  ($m,$c='Cyan'){ Write-Host $m -ForegroundColor $c }
function Ok   ($m){ Write-Host $m -ForegroundColor Green }
function Warn ($m){ Write-Warning $m }
function Fail ($m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

# --- Resolve repo paths (this file is under /tools) ---
$here = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$Root  = Split-Path -Parent $here
$Front = Join-Path $Root 'frontend'
if (-not (Test-Path $Front)) { Fail "Frontend folder not found at $Front" }

$API = "http://127.0.0.1:$ApiPort"
Say "Project root  : $Root"  'DarkGray'
Say "Frontend path : $Front" 'DarkGray'
Say "API base      : $API"   'DarkGray'

# --- Safe PostCSS config ---
$postcss = Join-Path $Front 'postcss.config.cjs'
if (-not (Test-Path $postcss)) {
@"
/** Safe default PostCSS config for Vite **/
module.exports = { plugins: { autoprefixer: {} } };
"@ | Set-Content -Encoding UTF8 $postcss
  Say "Created $postcss" Yellow
}

# --- Ensure VITE_API_BASE for dev ---
$envLocal = Join-Path $Front '.env.local'
@"
VITE_API_BASE=$API
"@ | Set-Content -Encoding UTF8 $envLocal
Say "Wrote $envLocal (VITE_API_BASE=$API)" 'DarkGray'

# --- Write api.ts (robust client) ---
$apiPath = Join-Path $Front 'src\api.ts'
$apiDir  = Split-Path $apiPath -Parent
if (-not (Test-Path $apiDir)) { New-Item -ItemType Directory -Force -Path $apiDir | Out-Null }

@'
export const API_BASE: string =
  (typeof import.meta !== "undefined" && (import.meta as any).env?.VITE_API_BASE) ||
  "http://127.0.0.1:8085";

function delay(ms: number) { return new Promise(res => setTimeout(res, ms)); }

export function getToken(): string {
  try { return localStorage.getItem("token") ?? ""; } catch { return ""; }
}
export function setToken(t: string) {
  try { localStorage.setItem("token", t); } catch {}
}
export function clearToken() {
  try { localStorage.removeItem("token"); } catch {}
}

type HttpInit = RequestInit & { retry?: number; timeoutMs?: number };

export async function http<T=any>(path: string, init: HttpInit = {}): Promise<T> {
  const url = `${API_BASE}${path}`;
  const retry = Math.max(0, init.retry ?? 1);  // 1 retry by default
  const timeoutMs = Math.max(1, init.timeoutMs ?? 10000);

  let lastErr: any = null;
  for (let attempt = 0; attempt <= retry; attempt++) {
    const headers: Record<string,string> = {
      "Content-Type": "application/json",
      ...(init.headers as any || {})
    };
    const tok = getToken();
    if (tok) headers["Authorization"] = `Bearer ${tok}`;

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const res = await fetch(url, { ...init, headers, signal: controller.signal });
      clearTimeout(timer);

      // Auto logout on 401 or on {error:"expired"} body
      if (res.status === 401) {
        clearToken();
        window.dispatchEvent(new CustomEvent("auth-expired"));
        throw new Error("unauthorized");
      }
      const raw = await res.text();
      const body = raw ? (JSON.parse(raw) as any) : null;

      if (!res.ok) {
        if (body?.error === "expired") {
          clearToken();
          window.dispatchEvent(new CustomEvent("auth-expired"));
        }
        throw new Error(body?.error || res.statusText || "request failed");
      }
      return body as T;
    } catch (e: any) {
      lastErr = e;
      if (attempt < retry) await delay(300 * (attempt + 1)); // backoff
    }
  }
  throw lastErr ?? new Error("network");
}
'@ | Set-Content -Encoding UTF8 $apiPath
Ok "Wrote $apiPath"

# --- ErrorBoundary.tsx ---
$errDir = Join-Path $Front 'src\components'
if (-not (Test-Path $errDir)) { New-Item -ItemType Directory -Force -Path $errDir | Out-Null }

$errPath = Join-Path $errDir 'ErrorBoundary.tsx'
@'
import React from "react";

type Props = { children: React.ReactNode };
type State = { hasError: boolean; message?: string };

export default class ErrorBoundary extends React.Component<Props, State> {
  state: State = { hasError: false };
  static getDerivedStateFromError(err: any) {
    return { hasError: true, message: err?.message || "Something went wrong." };
  }
  componentDidCatch(err: any) { console.error("[UI] error", err); }
  render() {
    if (this.state.hasError) {
      return (
        <div role="alert" aria-live="assertive" style={{padding:12, border:"1px solid #f99", borderRadius:8}}>
          <div style={{fontWeight:600, marginBottom:6}}>Something went wrong</div>
          <div style={{marginBottom:8}}>{this.state.message}</div>
          <button onClick={()=>location.reload()} aria-label="Reload page">Reload</button>
        </div>
      );
    }
    return this.props.children;
  }
}
'@ | Set-Content -Encoding UTF8 $errPath
Ok "Wrote $errPath"

# --- GamePanel.tsx (loading/error/retry + A11y) ---
$gamePath = Join-Path $Front 'src\components\GamePanel.tsx'
@'
import { useEffect, useRef, useState } from "react";
import { http } from "../api";

type Puzzle = { key: string; q: string; options: string[] };

export default function GamePanel() {
  const [puzzle, setPuzzle] = useState<Puzzle | null>(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const firstBtn = useRef<HTMLButtonElement | null>(null);

  async function load() {
    setErr(null); setLoading(true);
    try {
      const p = await http<Puzzle>("/puzzles/next", { retry: 2 });
      setPuzzle(p);
      setTimeout(()=>firstBtn.current?.focus(), 0);
    } catch (e:any) {
      setErr(e?.message || "server");
    } finally {
      setLoading(false);
    }
  }
  useEffect(()=>{ load(); }, []);

  async function answer(opt: string) {
    setErr(null); setLoading(true);
    try {
      await http("/puzzles/answer", {
        method: "POST",
        body: JSON.stringify({ answer: opt }),
        retry: 1
      });
      await load();
    } catch (e:any) {
      setErr(e?.message || "server");
      setLoading(false);
    }
  }

  return (
    <section aria-labelledby="game-h">
      <h2 id="game-h" style={{marginBottom:8}}>Game</h2>

      {loading && (
        <div role="status" aria-live="polite" style={{marginBottom:8}}>Loading puzzle...</div>
      )}

      {err && (
        <div role="alert" aria-live="assertive" style={{marginBottom:8, color:"#c00"}}>
          {`Game error: ${JSON.stringify(err)}`}{" "}
          <button onClick={load} aria-label="Retry loading puzzle">Retry</button>
        </div>
      )}

      {!loading && puzzle && (
        <div>
          <div style={{marginBottom:10}}>{puzzle.q}</div>
          <div style={{display:"grid", gap:8}}>
            {puzzle.options.map((o, i) => (
              <button
                key={o}
                ref={i===0 ? firstBtn : undefined}
                onClick={()=>answer(o)}
                aria-label={`Answer: ${o}`}
                style={{padding:"10px 12px"}}
              >
                {o}
              </button>
            ))}
          </div>
          <div style={{marginTop:10}}>
            <button onClick={load} aria-label="Skip puzzle">Skip / Next</button>
          </div>
        </div>
      )}
    </section>
  );
}
'@ | Set-Content -Encoding UTF8 $gamePath
Ok "Wrote $gamePath"

# --- ProgressPanel.tsx (loading/error/retry) ---
$progPath = Join-Path $Front 'src\components\ProgressPanel.tsx'
@'
import { useEffect, useState } from "react";
import { http } from "../api";

type Attempt = { id: number|string; correct: boolean; at: string };
type Prog = { level: number; xp: number; streak: number; history: Attempt[] };

export default function ProgressPanel(){
  const [data, setData] = useState<Prog|null>(null);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string|null>(null);

  async function load(){
    setErr(null); setLoading(true);
    try{
      const p = await http<Prog>("/progress", { retry: 1 });
      setData(p);
    }catch(e:any){
      setErr(e?.message || "server");
    }finally{
      setLoading(false);
    }
  }
  useEffect(()=>{ load(); }, []);

  return (
    <section aria-labelledby="prog-h" style={{marginTop:16}}>
      <h2 id="prog-h" style={{marginBottom:8}}>Progress</h2>

      {loading && <div role="status" aria-live="polite">Loading progress…</div>}
      {err && (
        <div role="alert" aria-live="assertive" style={{color:"#c00"}}>
          {`Progress: ${JSON.stringify(err)}`}{" "}
          <button onClick={load} aria-label="Retry loading progress">Retry</button>
        </div>
      )}

      {data && !loading && !err && (
        <div style={{border:"1px solid #eee", borderRadius:8, padding:12}}>
          <div>Level: {data.level}</div>
          <div>XP: {data.xp}</div>
          <div>Streak: {data.streak}</div>
          {data.history?.length>0 && (
            <div style={{marginTop:8}}>
              <div style={{fontWeight:600, marginBottom:4}}>Recent Attempts</div>
              <ul>
                {data.history.slice(0,10).map(h=>(
                  <li key={String(h.id)} aria-label={`Attempt ${h.correct ? "correct" : "wrong"}`}>
                    {h.correct ? "✓" : "✗"} — {new Date(h.at).toLocaleString()}
                  </li>
                ))}
              </ul>
            </div>
          )}
          <button onClick={load} style={{marginTop:8}} aria-label="Refresh progress">Refresh</button>
        </div>
      )}
    </section>
  );
}
'@ | Set-Content -Encoding UTF8 $progPath
Ok "Wrote $progPath"

# --- App.tsx (auto-logout + ErrorBoundary + A11y auth) ---
$appPath = Join-Path $Front 'src\App.tsx'
@'
import { useEffect, useState } from "react";
import ErrorBoundary from "./components/ErrorBoundary";
import GamePanel from "./components/GamePanel";
import ProgressPanel from "./components/ProgressPanel";
import { http, setToken, clearToken, getToken } from "./api";

export default function App(){
  const [email, setEmail] = useState("you@example.com");
  const [pass, setPass]   = useState("password");
  const [authMsg, setAuthMsg] = useState<string>("");

  const loggedIn = !!getToken();

  async function register(){ setAuthMsg(""); try{
    const r = await http<{token:string}>("/auth/register", { method: "POST", body: JSON.stringify({email, password:pass}) });
    setToken(r.token); setAuthMsg("registered");
  }catch(e:any){ setAuthMsg(JSON.stringify({error:e?.message||"server"})); } }

  async function login(){ setAuthMsg(""); try{
    const r = await http<{token:string}>("/auth/login", { method: "POST", body: JSON.stringify({email, password:pass}) });
    setToken(r.token); setAuthMsg("logged in");
  }catch(e:any){ setAuthMsg(JSON.stringify({error:e?.message||"server"})); } }

  function logout(){ clearToken(); setAuthMsg("logged out"); }

  // Auto logout on expired token event
  useEffect(()=>{
    const onExp = () => { clearToken(); setAuthMsg(JSON.stringify({error:"expired"})); };
    window.addEventListener("auth-expired", onExp);
    return () => window.removeEventListener("auth-expired", onExp);
  },[]);

  return (
    <ErrorBoundary>
      <div style={{maxWidth:820, margin:"0 auto", padding:16}}>
        <h1>MindLab Frontend</h1>
        <div style={{fontSize:12, color:"#666", marginBottom:10}}>
          API base: {(import.meta as any).env?.VITE_API_BASE}
        </div>

        <section aria-labelledby="auth-h" style={{border:"1px solid #eee", borderRadius:8, padding:12, marginBottom:16}}>
          <div id="auth-h" style={{fontWeight:600, marginBottom:8}}>Authentication</div>
          <div style={{display:"flex", gap:8, flexWrap:"wrap", alignItems:"center"}}>
            <input aria-label="Email" value={email} onChange={e=>setEmail(e.target.value)} style={{minWidth:220}}/>
            <input aria-label="Password" type="password" value={pass} onChange={e=>setPass(e.target.value)} style={{minWidth:160}}/>
            <button onClick={register} aria-label="Register account">Register</button>
            <button onClick={login} aria-label="Login">Login</button>
            <button onClick={logout} aria-label="Logout">Logout</button>
          </div>
          <div aria-live="polite" style={{marginTop:8, background:"#eefdff", padding:"6px 8px", borderRadius:6}}>
            {authMsg || (loggedIn ? "logged in" : "not logged in")}
          </div>
        </section>

        <GamePanel/>
        <ProgressPanel/>
      </div>
    </ErrorBoundary>
  );
}
'@ | Set-Content -Encoding UTF8 $appPath
Ok "Wrote $appPath"

# --- Start or verify Vite ---
$listen = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | ? LocalPort -eq $Port
if (-not $listen) {
  Say "Starting Vite on :$Port ..." Yellow
  Start-Process -FilePath "npm" -ArgumentList "run","dev","--","--port",$Port,"--strictPort" -WorkingDirectory $Front
  Start-Sleep -Seconds 3
} else {
  Say "Vite already listening on :$Port" 'DarkGray'
}

# --- Poll homepage ---
$deadline = (Get-Date).AddSeconds(60)
$ok = $false
while(-not $ok -and (Get-Date) -lt $deadline){
  try{
    $r = Invoke-WebRequest "http://127.0.0.1:$Port/" -UseBasicParsing -TimeoutSec 3
    if ($r.StatusCode -eq 200) { $ok = $true; break }
  }catch{}
  Start-Sleep -Seconds 1
}
if ($ok) {
  Ok "Frontend reachable -> http://127.0.0.1:$Port/"
  Start-Process "http://127.0.0.1:$Port/"
} else {
  Fail "Frontend NOT reachable on :$Port. Check the Vite window."
}
