export async function mindlabSafeFetch(url, options = {}) {
  const response = await fetch(url, options);
  const text = await response.text();
  let json = null;

  if (text && text.trim().length > 0) {
    try {
      json = JSON.parse(text);
    } catch (error) {
      throw new Error(`Non-JSON response from ${url}: ${text}`);
    }
  }

  if (!response.ok) {
    const message = json && json.error ? json.error : `HTTP ${response.status}`;
    throw new Error(message);
  }

  return json ?? {};
}
