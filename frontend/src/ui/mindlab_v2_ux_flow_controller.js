const { renderKidsModeShell } = require("./mindlab_kids_mode_shell");
const { renderKidsFirstPuzzle } = require("./mindlab_kids_first_puzzle");
const { loadRecommendationScreen } = require("./mindlab_v2_recommendation_screen");
const { loadPuzzleGenerationScreen } = require("./mindlab_v2_generation_screen");

async function loadMindLabV2Experience(input) {
    if (!input) throw new Error("STOP: UX flow input missing");

    if (input.mode === "recommendation") {
        return loadRecommendationScreen(input.candidatePuzzles || []);
    }

    if (input.mode === "generation") {
        return loadPuzzleGenerationScreen(input.payload || {});
    }

    throw new Error("STOP: unsupported UX flow mode");
}

module.exports = {
    loadMindLabV2Experience
};

// MINDLAB_KIDS_FIRST_SLICE_START
function mountMindLabKidsFirstSlice(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids first slice root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsFirstPuzzle("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsFirstPuzzle("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsFirstSlice = mountMindLabKidsFirstSlice;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsFirstSlice = mountMindLabKidsFirstSlice;
}
// MINDLAB_KIDS_FIRST_SLICE_END

