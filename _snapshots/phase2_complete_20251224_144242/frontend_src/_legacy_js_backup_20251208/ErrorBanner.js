import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
export default function ErrorBanner({ error }) {
    return (_jsxs("div", { style: {
            background: "#fee2e2",
            color: "#991b1b",
            padding: "12px 16px",
            border: "1px solid #fecaca",
            borderRadius: "8px",
            marginBottom: "12px"
        }, children: [_jsx("strong", { children: "Frontend Error:" }), " ", error] }));
}
