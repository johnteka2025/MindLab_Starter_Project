function renderCertifiedKidsPuzzle16(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 16 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>If it is raining, what should you use?</p>' +
        '<button data-choice="umbrella">Umbrella</button>' +
        '<button data-choice="sunglasses">Sunglasses</button>' +
        '<button data-choice="book">Book</button>' +
        '<div id="p16-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p16-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "umbrella" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle16 };
}

