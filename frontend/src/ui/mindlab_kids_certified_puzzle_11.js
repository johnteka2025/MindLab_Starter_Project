function renderCertifiedKidsPuzzle11(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 11 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>Which one is bigger?</p>' +
        '<button data-choice="elephant">Elephant</button>' +
        '<button data-choice="cat">Cat</button>' +
        '<button data-choice="mouse">Mouse</button>' +
        '<div id="p11-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p11-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "elephant" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle11 };
}

