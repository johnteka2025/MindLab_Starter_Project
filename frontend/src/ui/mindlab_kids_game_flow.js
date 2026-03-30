import { trackProgress } from "./mindlab_kids_progress.js";

export function startMindLabKidsGame(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Game container not found");

    let currentPuzzle = 1;

    function loadPuzzle(index) {
        const fnName = "renderCertifiedKidsPuzzle" + String(index).padStart(2, "0");

        if (window[fnName]) {
            window[fnName](containerId);

            trackProgress(index, "started");
        } else {
            host.innerHTML = "<p>Game Complete!</p>";
        }
    }

    loadPuzzle(currentPuzzle);
}
