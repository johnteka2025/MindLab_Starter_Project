import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { useEffect, useState } from 'react';
export default function GamePanel() {
    const [loading, setLoading] = useState(true);
    const [err, setErr] = useState('');
    const [p, setP] = useState(null);
    async function load() {
        try {
            setLoading(true);
            setErr('');
            setP(null);
            // placeholder until backend adds puzzles/next
            setP({ key: 'demo', q: '2 + 2 = ?', options: ['3', '4', '5'] });
        }
        catch (e) {
            setErr(e?.message ?? 'network');
        }
        finally {
            setLoading(false);
        }
    }
    useEffect(() => { load(); }, []);
    if (loading)
        return _jsx("div", { "aria-busy": "true", children: "Loading puzzle\u2026" });
    if (err)
        return _jsxs("div", { role: "alert", style: { color: '#b00' }, children: ["Error: ", err, " ", _jsx("button", { onClick: load, children: "Retry" })] });
    if (!p)
        return null;
    return (_jsxs("section", { "aria-labelledby": "game-title", children: [_jsx("h2", { id: "game-title", children: "Game" }), _jsx("p", { children: p.q }), _jsx("div", { role: "group", "aria-label": "Answer choices", children: p.options.map((o, i) => _jsx("button", { style: { marginRight: 8 }, onClick: () => alert(o === '4' ? '✅ Correct!' : '❌ Try again.'), children: o }, i)) })] }));
}
