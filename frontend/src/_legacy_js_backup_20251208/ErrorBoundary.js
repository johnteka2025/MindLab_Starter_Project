import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { Component } from 'react';
export default class ErrorBoundary extends Component {
    constructor() {
        super(...arguments);
        this.state = { hasError: false };
    }
    static getDerivedStateFromError(err) {
        return { hasError: true, msg: String(err?.message || err) };
    }
    render() {
        if (this.state.hasError) {
            return (_jsxs("div", { role: "alert", "aria-live": "assertive", style: { background: '#fee', padding: 12, border: '1px solid #f88' }, children: [_jsx("strong", { children: "Something went wrong." }), _jsx("div", { children: this.state.msg }), _jsx("button", { onClick: () => location.reload(), children: "Reload" })] }));
        }
        return this.props.children;
    }
}
