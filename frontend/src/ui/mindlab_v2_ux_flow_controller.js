const { renderKidsPuzzle13 } = require("./mindlab_kids_puzzle_13");
const { renderKidsPuzzle12 } = require("./mindlab_kids_puzzle_12");
const { renderKidsPuzzle11 } = require("./mindlab_kids_puzzle_11");
const { renderKidsPuzzle10 } = require("./mindlab_kids_puzzle_10");
const { renderKidsPuzzle09 } = require("./mindlab_kids_puzzle_09");
const { renderKidsPuzzle08 } = require("./mindlab_kids_puzzle_08");
const { renderKidsPuzzle07 } = require("./mindlab_kids_puzzle_07");
const { renderKidsPuzzle06 } = require("./mindlab_kids_puzzle_06");
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

// MINDLAB_KIDS_PUZZLE_06_START
function mountMindLabKidsPuzzle06(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 06 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle06("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle06("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle06 = mountMindLabKidsPuzzle06;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle06 = mountMindLabKidsPuzzle06;
}
// MINDLAB_KIDS_PUZZLE_06_END

// MINDLAB_KIDS_PUZZLE_07_START
function mountMindLabKidsPuzzle07(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 07 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle07("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle07("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle07 = mountMindLabKidsPuzzle07;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle07 = mountMindLabKidsPuzzle07;
}
// MINDLAB_KIDS_PUZZLE_07_END

// MINDLAB_KIDS_PUZZLE_08_START
function mountMindLabKidsPuzzle08(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 08 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle08("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle08("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle08 = mountMindLabKidsPuzzle08;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle08 = mountMindLabKidsPuzzle08;
}
// MINDLAB_KIDS_PUZZLE_08_END

// MINDLAB_KIDS_PUZZLE_09_START
function mountMindLabKidsPuzzle09(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 09 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle09("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle09("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle09 = mountMindLabKidsPuzzle09;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle09 = mountMindLabKidsPuzzle09;
}
// MINDLAB_KIDS_PUZZLE_09_END

// MINDLAB_KIDS_PUZZLE_10_START
function mountMindLabKidsPuzzle10(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 10 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle10("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle10("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle10 = mountMindLabKidsPuzzle10;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle10 = mountMindLabKidsPuzzle10;
}
// MINDLAB_KIDS_PUZZLE_10_END

// MINDLAB_KIDS_PUZZLE_11_START
function mountMindLabKidsPuzzle11(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 11 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle11("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle11("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle11 = mountMindLabKidsPuzzle11;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle11 = mountMindLabKidsPuzzle11;
}
// MINDLAB_KIDS_PUZZLE_11_END

// MINDLAB_KIDS_PUZZLE_12_START
function mountMindLabKidsPuzzle12(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 12 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle12("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle12("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle12 = mountMindLabKidsPuzzle12;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle12 = mountMindLabKidsPuzzle12;
}
// MINDLAB_KIDS_PUZZLE_12_END

// MINDLAB_KIDS_PUZZLE_13_START
function mountMindLabKidsPuzzle13(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) {
        throw new Error("Kids puzzle 13 root container not found.");
    }

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle13("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle13("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle13 = mountMindLabKidsPuzzle13;
}

if (typeof module !== "undefined" && module.exports) {
    module.exports.mountMindLabKidsPuzzle13 = mountMindLabKidsPuzzle13;
}
// MINDLAB_KIDS_PUZZLE_13_END

