import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { useEffect, useState } from 'react';
import { api } from '../api';
export default function ProgressPanel() {
    const [loading, setLoading] = useState(true);
    const [err, setErr] = useState('');
    const [p, setP] = useState(null);
    async function refresh() {
        try {
            setLoading(true);
            setErr('');
            setP(await api('/progress'));
        }
        catch (e) {
            setErr(e?.message ?? 'network');
        }
        finally {
            setLoading(false);
        }
    }
    useEffect(() => { refresh(); }, []);
    return (_jsxs("section", { "aria-labelledby": "progress-title", children: [_jsx("h2", { id: "progress-title", children: "Progress" }), loading && _jsx("div", { "aria-busy": "true", children: "Loading\u2026" }), err && _jsxs("div", { role: "alert", style: { color: '#b00' }, children: ["Error: ", err, " ", _jsx("button", { onClick: refresh, children: "Retry" })] }), !loading && !err && p && (_jsxs("ul", { children: [_jsxs("li", { children: ["Level: ", p.level ?? 1] }), _jsxs("li", { children: ["XP: ", p.xp ?? 0] }), _jsxs("li", { children: ["Streak: ", p.streak ?? 0] })] }))] }));
}
