const KEY = 'mindlab_token';
export const saveToken = (t:string)=> localStorage.setItem(KEY, t);
export const getToken  = ()=> localStorage.getItem(KEY);
export const clearToken= ()=> localStorage.removeItem(KEY);
