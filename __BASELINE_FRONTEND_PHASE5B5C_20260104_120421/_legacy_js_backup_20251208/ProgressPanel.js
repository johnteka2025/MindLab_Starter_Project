import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// src/ProgressPanel.tsx
import { useEffect, useState } from "react";
import { getProgress } from "./api";
export const ProgressPanel = () => {
    const [progress, setProgress] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    async function load() {
        setLoading(true);
        setError(null);
        try {
            const r = await getProgress();
            setProgress(r);
        }
        catch (e) {
            setError("Failed to load progress.");
        }
        finally {
            setLoading(false);
        }
    }
    useEffect(() => {
        load();
    }, []);
    return (_jsxs("section", { "aria-label": "Progress", children: [_jsx("h2", { children: "Progress" }), loading && _jsx("div", { "aria-live": "polite", children: "Loading progress\u2026" }), error && (_jsxs("div", { role: "alert", children: [error, " ", _jsx("button", { type: "button", onClick: load, children: "Retry" })] })), !loading && !error && progress && (_jsx("div", { "aria-live": "polite", children: _jsxs("p", { children: ["Solved ", progress.solvedPuzzles, " of ", progress.totalPuzzles, " puzzles."] }) }))] }));
};
export default ProgressPanel;
