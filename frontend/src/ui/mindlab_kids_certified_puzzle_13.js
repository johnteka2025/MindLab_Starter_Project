function renderCertifiedKidsPuzzle13(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 13 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>Which one can fly?</p>' +
        '<button data-choice="bird">Bird</button>' +
        '<button data-choice="dog">Dog</button>' +
        '<button data-choice="fish">Fish</button>' +
        '<div id="p13-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p13-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "bird" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle13 };
}


