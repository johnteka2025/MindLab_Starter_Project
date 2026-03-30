function renderCertifiedKidsPuzzle18(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 18 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>What comes next: 1, 3, 5, ?</p>' +
        '<button data-choice="7">7</button>' +
        '<button data-choice="6">6</button>' +
        '<button data-choice="8">8</button>' +
        '<div id="p18-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p18-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "7" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle18 };
}
