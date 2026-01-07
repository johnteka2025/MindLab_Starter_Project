import { useEffect, useState } from 'react';
import { api } from '../api';

type Puzzle = { key: string; q: string; options: string[] };

export default function GamePanel() {
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string>('');
  const [p, setP] = useState<Puzzle | null>(null);

  async function load() {
    try { setLoading(true); setErr(''); setP(null);
      // placeholder until backend adds puzzles/next
      setP({ key: 'demo', q: '2 + 2 = ?', options: ['3', '4', '5'] });
    } catch (e: any) { setErr(e?.message ?? 'network'); }
    finally { setLoading(false); }
  }

  useEffect(() => { load(); }, []);

  if (loading) return <div aria-busy="true">Loading puzzle…</div>;
  if (err) return <div role="alert" style={{ color: '#b00' }}>Error: {err} <button onClick={load}>Retry</button></div>;
  if (!p) return null;

  return (
    <section aria-labelledby="game-title">
      <h2 id="game-title">Game</h2>
      <p>{p.q}</p>
      <div role="group" aria-label="Answer choices">
        {p.options.map((o, i) =>
          <button key={i} style={{ marginRight: 8 }} onClick={() => alert(o === '4' ? '✅ Correct!' : '❌ Try again.')}>{o}</button>
        )}
      </div>
    </section>
  );
}

