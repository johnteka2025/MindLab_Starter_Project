const KEY = "mindlab_token";
export function saveToken(t: string){ localStorage.setItem(KEY, t); }
export function getToken(){ return localStorage.getItem(KEY); }
export function clearToken(){ localStorage.removeItem(KEY); }
