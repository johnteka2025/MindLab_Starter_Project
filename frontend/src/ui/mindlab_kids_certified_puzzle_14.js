function renderCertifiedKidsPuzzle14(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 14 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>Which one is used to cut?</p>' +
        '<button data-choice="scissors">Scissors</button>' +
        '<button data-choice="book">Book</button>' +
        '<button data-choice="cup">Cup</button>' +
        '<div id="p14-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p14-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "scissors" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle14 };
}
