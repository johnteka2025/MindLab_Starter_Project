function renderCertifiedKidsPuzzle08(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 08 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>Which animal barks?</p>' +
        '<button data-choice="dog">Dog</button>' +
        '<button data-choice="cat">Cat</button>' +
        '<button data-choice="fish">Fish</button>' +
        '<div id="p08-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p08-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "dog" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle08 };
}
