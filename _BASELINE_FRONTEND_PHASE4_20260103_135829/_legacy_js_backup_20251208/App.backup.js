import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import HealthPanel from "./components/HealthPanel";
import { DailyChallengeHomeCard } from "./daily-challenge/DailyChallengeHomeCard";
export default function App() {
    const apiBase = import.meta.env.VITE_API_BASE;
    return (_jsxs("main", { className: "p-8", children: [_jsx("h1", { className: "text-4xl font-bold mb-4", children: "MindLab Frontend" }), _jsxs("p", { className: "mb-4 text-sm", children: ["API base: ", apiBase] }), _jsx(HealthPanel, {}), _jsx(DailyChallengeHomeCard, {})] }));
}
