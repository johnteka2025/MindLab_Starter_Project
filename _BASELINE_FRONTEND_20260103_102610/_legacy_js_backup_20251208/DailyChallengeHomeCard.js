import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
import { useEffect, useState } from "react";
import { fetchDailyStatus, } from "./dailyChallengeApi";
/**
 * Small card to show Daily Challenge status on the home page.
 *
 * This component does not depend on any specific router.
 * It uses window.location.href to navigate to /daily.
 */
export function DailyChallengeHomeCard() {
    const [status, setStatus] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    useEffect(() => {
        let cancelled = false;
        async function load() {
            try {
                const result = await fetchDailyStatus();
                if (!cancelled) {
                    setStatus(result);
                    setLoading(false);
                }
            }
            catch (err) {
                if (!cancelled) {
                    setError(err?.message ?? "Unable to load Daily Challenge status.");
                    setLoading(false);
                }
            }
        }
        load();
        return () => {
            cancelled = true;
        };
    }, []);
    const handleOpenClick = () => {
        // Generic navigation – works regardless of React Router version.
        window.location.href = "/daily";
    };
    let body;
    if (loading) {
        body = _jsx("p", { className: "text-sm text-gray-500", children: "Loading Daily Challenge\u2026" });
    }
    else if (error) {
        body = (_jsxs("p", { className: "text-sm text-red-600", children: ["Daily Challenge status unavailable: ", error] }));
    }
    else if (status) {
        const friendlyStatus = status.status === "completed"
            ? "Completed"
            : status.status === "in_progress"
                ? "In progress"
                : "Not started";
        body = (_jsxs(_Fragment, { children: [_jsxs("p", { className: "text-sm text-gray-600", children: ["Today: ", _jsx("strong", { children: status.challengeDate }), " \u00B7 Band", " ", _jsx("strong", { children: status.band })] }), _jsxs("p", { className: "text-sm text-gray-600 mt-1", children: ["Progress:", " ", _jsxs("strong", { children: [status.puzzlesCompletedToday, " / ", status.totalPuzzlesForToday] }), " ", "puzzles"] }), _jsxs("p", { className: "text-sm text-gray-600 mt-1", children: ["Streak: ", _jsx("strong", { children: status.streakCount }), " day", status.streakCount === 1 ? "" : "s"] }), _jsxs("p", { className: "text-sm font-semibold mt-2", children: ["Status: ", _jsx("span", { className: "text-blue-700", children: friendlyStatus })] })] }));
    }
    else {
        body = (_jsx("p", { className: "text-sm text-gray-500", children: "No Daily Challenge information available." }));
    }
    return (_jsxs("section", { className: "daily-challenge-card border rounded-lg p-4 shadow-sm bg-white", children: [_jsx("h2", { className: "text-lg font-bold mb-2", children: "Daily Challenge" }), body, _jsx("button", { type: "button", onClick: handleOpenClick, className: "mt-4 inline-flex items-center px-3 py-2 text-sm font-semibold rounded-md border border-blue-600 text-blue-600 hover:bg-blue-50", children: "Open Daily Challenge" })] }));
}
export default DailyChallengeHomeCard;
