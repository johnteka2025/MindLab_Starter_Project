function renderCertifiedKidsPuzzle23(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 23 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>What comes next: 2, 4, 6, ?</p>' +
        '<button data-choice="8">8</button>' +
        '<button data-choice="7">7</button>' +
        '<button data-choice="9">9</button>' +
        '<div id="p23-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p23-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "8" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle23 };
}


