import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
import { useEffect, useState } from "react";
import { fetchDailyInstance, submitDailyAnswer, } from "./DailyChallengeApi";
const demoAnswerHint = "demo-answer";
/**
 * Full Daily Challenge detail page.
 * - Fetches today"s challenge from /daily
 * - Shows puzzle list
 * - Lets the user submit an answer for a puzzle
 * - Updates progress after an answer is accepted
 */
export const DailyChallengeDetailPage = () => {
    const [instance, setInstance] = useState(null);
    const [loadState, setLoadState] = useState("idle");
    const [loadError, setLoadError] = useState(null);
    const [selectedPuzzleId, setSelectedPuzzleId] = useState(null);
    const [answerText, setAnswerText] = useState("");
    const [answerState, setAnswerState] = useState("idle");
    const [answerError, setAnswerError] = useState(null);
    const [answerResult, setAnswerResult] = useState(null);
    // Load the full instance on mount
    useEffect(() => {
        let cancelled = false;
        const load = async () => {
            setLoadState("loading");
            setLoadError(null);
            try {
                const data = await fetchDailyInstance();
                if (cancelled)
                    return;
                setInstance(data);
                setLoadState("loaded");
                // Default to first puzzle if any are available
                if (data.puzzles.length > 0) {
                    setSelectedPuzzleId(data.puzzles[0].id);
                }
            }
            catch (err) {
                if (cancelled)
                    return;
                setLoadState("error");
                setLoadError(err?.message ?? "Failed to load daily challenge.");
            }
        };
        load();
        return () => {
            cancelled = true;
        };
    }, []);
    const selectedPuzzle = instance?.puzzles.find((p) => p.id === selectedPuzzleId) ?? null;
    const handleSubmit = async (evt) => {
        evt.preventDefault();
        if (!instance || !selectedPuzzle)
            return;
        if (!answerText.trim()) {
            setAnswerError("Please enter an answer.");
            return;
        }
        setAnswerState("submitting");
        setAnswerError(null);
        setAnswerResult(null);
        try {
            const response = await submitDailyAnswer({
                dailyChallengeId: instance.dailyChallengeId,
                puzzleId: selectedPuzzle.id,
                answer: answerText.trim(),
            });
            setAnswerState("submitted");
            setAnswerResult(response);
            // Shallow update of high-level progress fields
            setInstance({
                ...instance,
                completedCount: response.completedCount,
                status: response.status,
            });
        }
        catch (err) {
            setAnswerState("error");
            setAnswerError(err?.message ?? "Failed to submit answer.");
        }
    };
    const headline = instance
        ? `Daily Challenge for ${instance.challengeDate} (band ${instance.band})`
        : "Daily Challenge";
    return (_jsxs("div", { style: { maxWidth: 900, margin: "0 auto", padding: "1.5rem" }, children: [_jsx("h1", { children: "Daily Challenge" }), _jsx("p", { style: { color: "#555" }, children: headline }), loadState === "loading" && _jsx("p", { children: "Loading daily challenge\u2026" }), loadState === "error" && (_jsxs("p", { style: { color: "red" }, children: ["Error loading daily challenge: ", loadError] })), instance && (_jsxs(_Fragment, { children: [_jsxs("section", { style: { marginTop: "1rem", marginBottom: "1.5rem" }, children: [_jsx("strong", { children: "Status:" }), " ", instance.status, " \u00B7", " ", _jsx("strong", { children: "Progress:" }), " ", instance.completedCount, " /", " ", instance.totalPuzzles] }), _jsxs("div", { style: { display: "flex", gap: "1.5rem", alignItems: "flex-start" }, children: [_jsxs("section", { style: { flex: 1 }, children: [_jsx("h2", { children: "Puzzles" }), instance.puzzles.length === 0 && _jsx("p", { children: "No puzzles for today." }), _jsx("ul", { style: { listStyle: "none", padding: 0 }, children: instance.puzzles.map((puzzle) => (_jsxs("li", { style: {
                                                padding: "0.5rem 0.75rem",
                                                marginBottom: "0.25rem",
                                                borderRadius: 8,
                                                border: puzzle.id === selectedPuzzleId
                                                    ? "2px solid #2563eb"
                                                    : "1px solid #ddd",
                                                cursor: "pointer",
                                                background: puzzle.id === selectedPuzzleId ? "#eff6ff" : "white",
                                            }, onClick: () => setSelectedPuzzleId(puzzle.id), children: [_jsx("div", { style: { fontWeight: 600 }, children: puzzle.title }), _jsxs("div", { style: { fontSize: "0.85rem", color: "#666" }, children: ["Difficulty: ", puzzle.difficulty] })] }, puzzle.id))) })] }), _jsxs("section", { style: { flex: 1 }, children: [_jsx("h2", { children: "Answer" }), !selectedPuzzle && _jsx("p", { children: "Select a puzzle to answer." }), selectedPuzzle && (_jsxs("form", { onSubmit: handleSubmit, children: [_jsxs("p", { children: ["Answering: ", _jsx("strong", { children: selectedPuzzle.title })] }), _jsxs("label", { style: { display: "block", marginBottom: "0.5rem" }, children: ["Your answer", _jsx("input", { type: "text", value: answerText, onChange: (e) => setAnswerText(e.target.value), style: {
                                                            width: "100%",
                                                            marginTop: "0.25rem",
                                                            padding: "0.5rem",
                                                            borderRadius: 6,
                                                            border: "1px solid #ccc",
                                                        } })] }), _jsxs("p", { style: { fontSize: "0.8rem", color: "#888" }, children: ["Hint for the demo backend: try ", _jsx("code", { children: demoAnswerHint }), "."] }), answerError && (_jsx("p", { style: { color: "red", marginTop: "0.5rem" }, children: answerError })), answerResult && (_jsx("p", { style: {
                                                    color: answerResult.correct ? "green" : "red",
                                                    marginTop: "0.5rem",
                                                }, children: answerResult.correct
                                                    ? "Correct! Progress updated."
                                                    : "That answer was not correct." })), _jsx("button", { type: "submit", disabled: answerState === "submitting", style: {
                                                    marginTop: "0.75rem",
                                                    padding: "0.5rem 1rem",
                                                    borderRadius: 999,
                                                    border: "none",
                                                    backgroundColor: "#2563eb",
                                                    color: "white",
                                                    fontWeight: 600,
                                                    cursor: answerState === "submitting" ? "wait" : "pointer",
                                                }, children: answerState === "submitting"
                                                    ? "Submitting…"
                                                    : "Submit answer" })] }))] })] })] }))] }));
};
export default DailyChallengeDetailPage;
