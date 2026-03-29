function renderCertifiedKidsPuzzle15(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 15 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>What comes next: 2, 4, ?</p>' +
        '<button data-choice="6">6</button>' +
        '<button data-choice="5">5</button>' +
        '<button data-choice="3">3</button>' +
        '<div id="p15-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p15-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "6" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle15 };
}
