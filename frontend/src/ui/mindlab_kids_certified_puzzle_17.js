function renderCertifiedKidsPuzzle17(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 17 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>If you are hungry, what should you do?</p>' +
        '<button data-choice="eat">Eat</button>' +
        '<button data-choice="sleep">Sleep</button>' +
        '<button data-choice="run">Run</button>' +
        '<div id="p17-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p17-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "eat" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle17 };
}
