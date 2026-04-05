export function getMindLabNextState(currentState = {}, scoreResponse = {}) {
  const totalScore = Number(scoreResponse.totalScore ?? currentState.totalScore ?? 0);

  return {
    ...currentState,
    totalScore,
    lastResult: scoreResponse.lastResult ?? currentState.lastResult ?? null,
    completedPuzzles: Array.isArray(scoreResponse.completedPuzzles)
      ? scoreResponse.completedPuzzles
      : (currentState.completedPuzzles ?? [])
  };
}

export function shouldAdvancePuzzle(scoreResponse = {}) {
  return String(scoreResponse.result ?? "").toLowerCase() === "correct";
}
