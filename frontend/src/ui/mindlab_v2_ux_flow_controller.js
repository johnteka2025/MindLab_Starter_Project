const { renderKidsPuzzle05 } = require("./mindlab_kids_puzzle_05");
const { renderKidsPuzzle04 } = require("./mindlab_kids_puzzle_04");
const { renderKidsPuzzle03 } = require("./mindlab_kids_puzzle_03");
const { renderKidsPuzzle02 } = require("./mindlab_kids_puzzle_02");
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

// MINDLAB_KIDS_PUZZLE_02_START
function mountMindLabKidsPuzzle02(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 02 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle02("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle02("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle02 = mountMindLabKidsPuzzle02;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle02 = mountMindLabKidsPuzzle02;
}
// MINDLAB_KIDS_PUZZLE_02_END

// MINDLAB_KIDS_PUZZLE_03_START
function mountMindLabKidsPuzzle03(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 03 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle03("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle03("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle03 = mountMindLabKidsPuzzle03;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle03 = mountMindLabKidsPuzzle03;
}
// MINDLAB_KIDS_PUZZLE_03_END

// MINDLAB_KIDS_PUZZLE_04_START
function mountMindLabKidsPuzzle04(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 04 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle04("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle04("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle04 = mountMindLabKidsPuzzle04;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle04 = mountMindLabKidsPuzzle04;
}
// MINDLAB_KIDS_PUZZLE_04_END

// MINDLAB_KIDS_PUZZLE_05_START
function mountMindLabKidsPuzzle05(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 05 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle05("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle05("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle05 = mountMindLabKidsPuzzle05;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle05 = mountMindLabKidsPuzzle05;
}
// MINDLAB_KIDS_PUZZLE_05_END

