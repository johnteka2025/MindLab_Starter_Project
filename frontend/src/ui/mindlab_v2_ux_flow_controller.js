const { renderKidsPuzzle49 } = require("./mindlab_kids_puzzle_49");
const { renderKidsPuzzle48 } = require("./mindlab_kids_puzzle_48");
const { renderKidsPuzzle47 } = require("./mindlab_kids_puzzle_47");
const { renderKidsPuzzle46 } = require("./mindlab_kids_puzzle_46");
const { renderKidsPuzzle45 } = require("./mindlab_kids_puzzle_45");
const { renderKidsPuzzle44 } = require("./mindlab_kids_puzzle_44");
const { renderKidsPuzzle43 } = require("./mindlab_kids_puzzle_43");
const { renderKidsPuzzle42 } = require("./mindlab_kids_puzzle_42");
const { renderKidsPuzzle41 } = require("./mindlab_kids_puzzle_41");
const { renderKidsPuzzle40 } = require("./mindlab_kids_puzzle_40");
const { renderKidsPuzzle39 } = require("./mindlab_kids_puzzle_39");
const { renderKidsPuzzle38 } = require("./mindlab_kids_puzzle_38");
const { renderKidsPuzzle37 } = require("./mindlab_kids_puzzle_37");
const { renderKidsPuzzle36 } = require("./mindlab_kids_puzzle_36");
const { renderKidsPuzzle35 } = require("./mindlab_kids_puzzle_35");
const { renderKidsPuzzle34 } = require("./mindlab_kids_puzzle_34");
const { renderKidsPuzzle33 } = require("./mindlab_kids_puzzle_33");
const { renderKidsPuzzle32 } = require("./mindlab_kids_puzzle_32");
const { renderKidsPuzzle31 } = require("./mindlab_kids_puzzle_31");
const { renderKidsPuzzle30 } = require("./mindlab_kids_puzzle_30");
const { renderKidsPuzzle29 } = require("./mindlab_kids_puzzle_29");
const { renderKidsPuzzle28 } = require("./mindlab_kids_puzzle_28");
const { renderKidsPuzzle27 } = require("./mindlab_kids_puzzle_27");
const { renderKidsPuzzle26 } = require("./mindlab_kids_puzzle_26");
const { renderKidsPuzzle25 } = require("./mindlab_kids_puzzle_25");
const { renderKidsPuzzle24 } = require("./mindlab_kids_puzzle_24");
const { renderKidsPuzzle23 } = require("./mindlab_kids_puzzle_23");
const { renderKidsPuzzle22 } = require("./mindlab_kids_puzzle_22");
const { renderKidsPuzzle21 } = require("./mindlab_kids_puzzle_21");
const { renderKidsPuzzle20 } = require("./mindlab_kids_puzzle_20");
const { renderKidsPuzzle19 } = require("./mindlab_kids_puzzle_19");
const { renderKidsPuzzle18 } = require("./mindlab_kids_puzzle_18");
const { renderKidsPuzzle17 } = require("./mindlab_kids_puzzle_17");
const { renderKidsPuzzle16 } = require("./mindlab_kids_puzzle_16");
const { renderKidsPuzzle15 } = require("./mindlab_kids_puzzle_15");
const { renderKidsPuzzle14 } = require("./mindlab_kids_puzzle_14");
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

// MINDLAB_KIDS_PUZZLE_14_START
function mountMindLabKidsPuzzle14(rootContainerId) {
    const root = document.getElementById(rootContainerId);
    if (!root) throw new Error("Kids puzzle 14 root container not found.");

    renderKidsModeShell(rootContainerId);
    renderKidsPuzzle14("mindlab-kids-puzzle-host");

    const retryButton = document.getElementById("mindlab-kids-retry-button");
    if (retryButton) {
        retryButton.addEventListener("click", () => {
            renderKidsPuzzle14("mindlab-kids-puzzle-host");
        });
    }

    return true;
}

if (typeof window !== "undefined") {
    window.mountMindLabKidsPuzzle14 = mountMindLabKidsPuzzle14;
}

if (typeof module !== "undefined") {
    module.exports.mountMindLabKidsPuzzle14 = mountMindLabKidsPuzzle14;
}
// MINDLAB_KIDS_PUZZLE_14_END

// MINDLAB_KIDS_PUZZLE_15_START
function mountMindLabKidsPuzzle15(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 15 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle15("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle15=mountMindLabKidsPuzzle15;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle15=mountMindLabKidsPuzzle15;}
// MINDLAB_KIDS_PUZZLE_15_END

// MINDLAB_KIDS_PUZZLE_16_START
function mountMindLabKidsPuzzle16(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 16 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle16("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle16=mountMindLabKidsPuzzle16;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle16=mountMindLabKidsPuzzle16;}
// MINDLAB_KIDS_PUZZLE_16_END

// MINDLAB_KIDS_PUZZLE_17_START
function mountMindLabKidsPuzzle17(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 17 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle17("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle17=mountMindLabKidsPuzzle17;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle17=mountMindLabKidsPuzzle17;}
// MINDLAB_KIDS_PUZZLE_17_END

// MINDLAB_KIDS_PUZZLE_18_START
function mountMindLabKidsPuzzle18(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 18 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle18("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle18=mountMindLabKidsPuzzle18;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle18=mountMindLabKidsPuzzle18;}
// MINDLAB_KIDS_PUZZLE_18_END

// MINDLAB_KIDS_PUZZLE_19_START
function mountMindLabKidsPuzzle19(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 19 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle19("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle19=mountMindLabKidsPuzzle19;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle19=mountMindLabKidsPuzzle19;}
// MINDLAB_KIDS_PUZZLE_19_END

// MINDLAB_KIDS_PUZZLE_20_START
function mountMindLabKidsPuzzle20(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 20 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle20("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle20=mountMindLabKidsPuzzle20;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle20=mountMindLabKidsPuzzle20;}
// MINDLAB_KIDS_PUZZLE_20_END

// MINDLAB_KIDS_PUZZLE_21_START
function mountMindLabKidsPuzzle21(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 21 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle21("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle21=mountMindLabKidsPuzzle21;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle21=mountMindLabKidsPuzzle21;}
// MINDLAB_KIDS_PUZZLE_21_END

// MINDLAB_KIDS_PUZZLE_22_START
function mountMindLabKidsPuzzle22(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 22 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle22("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle22=mountMindLabKidsPuzzle22;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle22=mountMindLabKidsPuzzle22;}
// MINDLAB_KIDS_PUZZLE_22_END

// MINDLAB_KIDS_PUZZLE_23_START
function mountMindLabKidsPuzzle23(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 23 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle23("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle23=mountMindLabKidsPuzzle23;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle23=mountMindLabKidsPuzzle23;}
// MINDLAB_KIDS_PUZZLE_23_END

// MINDLAB_KIDS_PUZZLE_24_START
function mountMindLabKidsPuzzle24(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 24 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle24("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle24=mountMindLabKidsPuzzle24;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle24=mountMindLabKidsPuzzle24;}
// MINDLAB_KIDS_PUZZLE_24_END

// MINDLAB_KIDS_PUZZLE_25_START
function mountMindLabKidsPuzzle25(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 25 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle25("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle25=mountMindLabKidsPuzzle25;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle25=mountMindLabKidsPuzzle25;}
// MINDLAB_KIDS_PUZZLE_25_END

// MINDLAB_KIDS_PUZZLE_26_START
function mountMindLabKidsPuzzle26(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 26 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle26("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle26=mountMindLabKidsPuzzle26;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle26=mountMindLabKidsPuzzle26;}
// MINDLAB_KIDS_PUZZLE_26_END

// MINDLAB_KIDS_PUZZLE_27_START
function mountMindLabKidsPuzzle27(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 27 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle27("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle27=mountMindLabKidsPuzzle27;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle27=mountMindLabKidsPuzzle27;}
// MINDLAB_KIDS_PUZZLE_27_END

// MINDLAB_KIDS_PUZZLE_28_START
function mountMindLabKidsPuzzle28(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 28 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle28("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle28=mountMindLabKidsPuzzle28;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle28=mountMindLabKidsPuzzle28;}
// MINDLAB_KIDS_PUZZLE_28_END

// MINDLAB_KIDS_PUZZLE_29_START
function mountMindLabKidsPuzzle29(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 29 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle29("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle29=mountMindLabKidsPuzzle29;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle29=mountMindLabKidsPuzzle29;}
// MINDLAB_KIDS_PUZZLE_29_END

// MINDLAB_KIDS_PUZZLE_30_START
function mountMindLabKidsPuzzle30(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 30 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle30("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle30=mountMindLabKidsPuzzle30;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle30=mountMindLabKidsPuzzle30;}
// MINDLAB_KIDS_PUZZLE_30_END

// MINDLAB_KIDS_PUZZLE_31_START
function mountMindLabKidsPuzzle31(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 31 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle31("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle31=mountMindLabKidsPuzzle31;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle31=mountMindLabKidsPuzzle31;}
// MINDLAB_KIDS_PUZZLE_31_END

// MINDLAB_KIDS_PUZZLE_32_START
function mountMindLabKidsPuzzle32(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 32 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle32("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle32=mountMindLabKidsPuzzle32;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle32=mountMindLabKidsPuzzle32;}
// MINDLAB_KIDS_PUZZLE_32_END

// MINDLAB_KIDS_PUZZLE_33_START
function mountMindLabKidsPuzzle33(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 33 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle33("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle33=mountMindLabKidsPuzzle33;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle33=mountMindLabKidsPuzzle33;}
// MINDLAB_KIDS_PUZZLE_33_END

// MINDLAB_KIDS_PUZZLE_34_START
function mountMindLabKidsPuzzle34(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 34 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle34("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle34=mountMindLabKidsPuzzle34;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle34=mountMindLabKidsPuzzle34;}
// MINDLAB_KIDS_PUZZLE_34_END

// MINDLAB_KIDS_PUZZLE_35_START
function mountMindLabKidsPuzzle35(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 35 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle35("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle35=mountMindLabKidsPuzzle35;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle35=mountMindLabKidsPuzzle35;}
// MINDLAB_KIDS_PUZZLE_35_END

// MINDLAB_KIDS_PUZZLE_36_START
function mountMindLabKidsPuzzle36(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 36 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle36("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle36=mountMindLabKidsPuzzle36;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle36=mountMindLabKidsPuzzle36;}
// MINDLAB_KIDS_PUZZLE_36_END

// MINDLAB_KIDS_PUZZLE_37_START
function mountMindLabKidsPuzzle37(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 37 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle37("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle37=mountMindLabKidsPuzzle37;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle37=mountMindLabKidsPuzzle37;}
// MINDLAB_KIDS_PUZZLE_37_END

// MINDLAB_KIDS_PUZZLE_37_START
function mountMindLabKidsPuzzle37(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 37 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle37("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle37=mountMindLabKidsPuzzle37;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle37=mountMindLabKidsPuzzle37;}
// MINDLAB_KIDS_PUZZLE_37_END

// MINDLAB_KIDS_PUZZLE_38_START
function mountMindLabKidsPuzzle38(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 38 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle38("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle38=mountMindLabKidsPuzzle38;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle38=mountMindLabKidsPuzzle38;}
// MINDLAB_KIDS_PUZZLE_38_END

// MINDLAB_KIDS_PUZZLE_39_START
function mountMindLabKidsPuzzle39(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 39 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle39("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle39=mountMindLabKidsPuzzle39;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle39=mountMindLabKidsPuzzle39;}
// MINDLAB_KIDS_PUZZLE_39_END

// MINDLAB_KIDS_PUZZLE_40_START
function mountMindLabKidsPuzzle40(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 40 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle40("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle40=mountMindLabKidsPuzzle40;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle40=mountMindLabKidsPuzzle40;}
// MINDLAB_KIDS_PUZZLE_40_END

// MINDLAB_KIDS_PUZZLE_41_START
function mountMindLabKidsPuzzle41(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 41 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle41("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle41=mountMindLabKidsPuzzle41;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle41=mountMindLabKidsPuzzle41;}
// MINDLAB_KIDS_PUZZLE_41_END

// MINDLAB_KIDS_PUZZLE_42_START
function mountMindLabKidsPuzzle42(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 42 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle42("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle42=mountMindLabKidsPuzzle42;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle42=mountMindLabKidsPuzzle42;}
// MINDLAB_KIDS_PUZZLE_42_END

// MINDLAB_KIDS_PUZZLE_43_START
function mountMindLabKidsPuzzle43(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 43 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle43("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle43=mountMindLabKidsPuzzle43;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle43=mountMindLabKidsPuzzle43;}
// MINDLAB_KIDS_PUZZLE_43_END

// MINDLAB_KIDS_PUZZLE_44_START
function mountMindLabKidsPuzzle44(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 44 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle44("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle44=mountMindLabKidsPuzzle44;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle44=mountMindLabKidsPuzzle44;}
// MINDLAB_KIDS_PUZZLE_44_END

// MINDLAB_KIDS_PUZZLE_45_START
function mountMindLabKidsPuzzle45(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 45 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle45("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle45=mountMindLabKidsPuzzle45;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle45=mountMindLabKidsPuzzle45;}
// MINDLAB_KIDS_PUZZLE_45_END

// MINDLAB_KIDS_PUZZLE_46_START
function mountMindLabKidsPuzzle46(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 46 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle46("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle46=mountMindLabKidsPuzzle46;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle46=mountMindLabKidsPuzzle46;}
// MINDLAB_KIDS_PUZZLE_46_END

// MINDLAB_KIDS_PUZZLE_47_START
function mountMindLabKidsPuzzle47(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 47 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle47("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle47=mountMindLabKidsPuzzle47;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle47=mountMindLabKidsPuzzle47;}
// MINDLAB_KIDS_PUZZLE_47_END

// MINDLAB_KIDS_PUZZLE_48_START
function mountMindLabKidsPuzzle48(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 48 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle48("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle48=mountMindLabKidsPuzzle48;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle48=mountMindLabKidsPuzzle48;}
// MINDLAB_KIDS_PUZZLE_48_END

// MINDLAB_KIDS_PUZZLE_49_START
function mountMindLabKidsPuzzle49(rootContainerId){
 const root=document.getElementById(rootContainerId);
 if(!root) throw new Error("Puzzle 49 root not found");
 renderKidsModeShell(rootContainerId);
 renderKidsPuzzle49("mindlab-kids-puzzle-host");
 return true;
}
if(typeof window!=="undefined"){window.mountMindLabKidsPuzzle49=mountMindLabKidsPuzzle49;}
if(typeof module!=="undefined"){module.exports.mountMindLabKidsPuzzle49=mountMindLabKidsPuzzle49;}
// MINDLAB_KIDS_PUZZLE_49_END
