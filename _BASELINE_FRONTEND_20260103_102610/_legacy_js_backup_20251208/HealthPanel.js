import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
// src/components/HealthPanel.tsx
import { useEffect, useState } from "react";
import { fetchJson } from "../lib/api";
const HealthPanel = () => {
    const [state, setState] = useState({ k: "loading" });
    async function load() {
        setState({ k: "loading" });
        try {
            const data = await fetchJson("/health", { timeoutMs: 6000 });
            setState({ k: "ok", data });
        }
        catch (e) {
            let message = "failed";
            if (e &&
                typeof e === "object" &&
                "message" in e &&
                typeof e.message === "string") {
                message = e.message;
            }
            setState({ k: "err", message });
        }
    }
    useEffect(() => {
        load();
    }, []);
    if (state.k === "loading") {
        return (_jsxs("section", { "aria-label": "Backend health", children: [_jsx("h2", { children: "Health" }), _jsx("p", { children: "Checking backend\u2026" })] }));
    }
    if (state.k === "err") {
        return (_jsxs("section", { "aria-label": "Backend health", children: [_jsx("h2", { children: "Health" }), _jsx("p", { children: "Status: error" }), _jsxs("div", { role: "alert", children: ["Failed to reach backend: ", state.message, " ", _jsx("button", { type: "button", onClick: load, children: "Retry" })] })] }));
    }
    // state.k === "ok"
    return (_jsxs("section", { "aria-label": "Backend health", children: [_jsx("h2", { children: "Health" }), _jsx("p", { children: "Status: ok" }), _jsx("p", { children: "Backend is healthy (ok: true)." }), _jsx("pre", { "aria-live": "polite", children: JSON.stringify(state.data, null, 2) })] }));
};
export default HealthPanel;
export { HealthPanel };
