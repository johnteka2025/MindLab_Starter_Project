export function trackProgress(puzzleId, result) {

    const key = "mindlab_kids_progress";
    const data = JSON.parse(localStorage.getItem(key) || "{}");

    data[puzzleId] = result;

    localStorage.setItem(key, JSON.stringify(data));
}

