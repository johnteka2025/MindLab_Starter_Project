export function getToken() { return localStorage.getItem("token"); }
export function clearAuth() { localStorage.removeItem("token"); window.location.href = "/login"; }
