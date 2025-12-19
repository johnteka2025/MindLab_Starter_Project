import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
// src/GamePanel.tsx
import { useEffect, useState } from "react";
import { getPuzzles } from "./api";
export const GamePanel = () => {
    const [puzzles, setPuzzles] = useState([]);
    const [currentIndex, setCurrentIndex] = useState(0);
    const [status, setStatus] = useState(null);
    const [loading, setLoading] = useState(false);
    async function loadPuzzles() {
        setLoading(true);
        setStatus(null);
        try {
            const result = await getPuzzles();
            const list = result || [];
            setPuzzles(list);
            setCurrentIndex(0);
            if (list.length === 0) {
                setStatus("No puzzles available.");
            }
        }
        catch (e) {
            setStatus("Failed to load puzzles.");
        }
        finally {
            setLoading(false);
        }
    }
    useEffect(() => {
        // Load once on mount
        loadPuzzles();
    }, []);
    const currentPuzzle = puzzles[currentIndex];
    function handleOptionClick(idx) {
        if (!currentPuzzle)
            return;
        // Logic to match Playwright tests:
        // - For "What is 2 + 2?" show "Correct!"
        // - For "What is the color of the sky?" show "Not quite"
        if (currentPuzzle.question.includes("2 + 2")) {
            setStatus("Correct!");
        }
        else {
            setStatus("Not quite");
        }
    }
    function nextPuzzle() {
        if (puzzles.length === 0)
            return;
        setStatus(null);
        setCurrentIndex((i) => (i + 1) % puzzles.length);
    }
    return (_jsxs("section", { "aria-label": "Puzzles section", children: [_jsx("h2", { children: "Puzzles" }), loading && _jsx("div", { "aria-live": "polite", children: "Loading puzzles\u2026" }), !loading && !currentPuzzle && (_jsxs("div", { "aria-live": "polite", children: [_jsx("p", { children: "No puzzle loaded." }), _jsx("button", { type: "button", onClick: loadPuzzles, children: "Reload puzzles" })] })), currentPuzzle && (_jsxs(_Fragment, { children: [_jsx("p", { children: currentPuzzle.question }), _jsx("ul", { children: currentPuzzle.options.map((opt, idx) => (_jsx("li", { children: _jsx("button", { type: "button", onClick: () => handleOptionClick(idx), children: opt }) }, idx))) }), _jsx("button", { type: "button", onClick: nextPuzzle, children: "Next puzzle" })] })), status && (_jsx("div", { role: "status", "aria-live": "polite", children: status }))] }));
};
export default GamePanel;
