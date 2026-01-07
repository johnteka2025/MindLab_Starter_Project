export const asyncWrap = fn => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

export function errorHandler(err, req, res, _next) {
  const status = err.status || 500;
  const body = {
    ok: false,
    error: 'server',
    detail: process.env.NODE_ENV === 'production' ? undefined : String(err.message || err)
  };
  res.status(status).json(body);
}
