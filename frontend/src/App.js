import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { HealthPanel } from "./components/HealthPanel";
import GamePanel from "./GamePanel";
function App() {
    return (_jsxs("main", { children: [_jsx("h1", { children: "MindLab Frontend" }), _jsx("section", { "aria-label": "Health section", children: _jsx(HealthPanel, {}) }), _jsx("section", { "aria-label": "Puzzles section", children: _jsx(GamePanel, {}) })] }));
}
export default App;
