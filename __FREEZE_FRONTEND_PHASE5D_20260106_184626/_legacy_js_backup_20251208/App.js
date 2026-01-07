import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { HealthPanel } from "./components/HealthPanel";
import ProgressPanel from "./components/ProgressPanel";
import { GamePanel } from "./GamePanel";
export default function App() {
    return (_jsxs("main", { children: [_jsx("h1", { children: "MindLab Frontend" }), _jsx(HealthPanel, {}), _jsx(GamePanel, {}), _jsx(ProgressPanel, {})] }));
}
