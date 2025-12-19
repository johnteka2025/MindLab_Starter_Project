import { useEffect, useState } from 'react';
import { api } from '../api';

export default function ProgressPanel() {
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string>('');
  const [p, setP] = useState<any>(null);

  async function refresh() {
    try { setLoading(true); setErr(''); setP(await api('/progress')); }
    catch (e: any) { setErr(e?.message ?? 'network'); }
    finally { setLoading(false); }
  }

  useEffect(() => { refresh(); }, []);

  return (
    <section aria-labelledby="progress-title">
      <h2 id="progress-title">Progress</h2>

      {loading && <div aria-busy="true">Loading…</div>}
      {err && <div role="alert" style={{ color: '#b00' }}>Error: {err} <button onClick={refresh}>Retry</button></div>}

      {!loading && !err && p && (
        <ul>
          <li>Level: {p.level ?? 1}</li>
          <li>XP: {p.xp ?? 0}</li>
          <li>Streak: {p.streak ?? 0}</li>
        </ul>
      )}
    </section>
  );
}
