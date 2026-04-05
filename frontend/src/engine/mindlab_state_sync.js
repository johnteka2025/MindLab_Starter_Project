export function loadMindLabState(storageKey = "mindlab-progress") {
  const raw = window.localStorage.getItem(storageKey);

  if (!raw) {
    return { totalScore: 0, completedPuzzles: [], lastResult: null };
  }

  try {
    return JSON.parse(raw);
  } catch (error) {
    return { totalScore: 0, completedPuzzles: [], lastResult: null };
  }
}

export function saveMindLabState(state, storageKey = "mindlab-progress") {
  window.localStorage.setItem(storageKey, JSON.stringify(state));
  return state;
}
