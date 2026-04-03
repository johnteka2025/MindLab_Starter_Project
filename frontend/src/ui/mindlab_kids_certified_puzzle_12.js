function renderCertifiedKidsPuzzle12(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 12 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>What comes after 1?</p>' +
        '<button data-choice="2">2</button>' +
        '<button data-choice="3">3</button>' +
        '<button data-choice="5">5</button>' +
        '<div id="p12-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p12-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "2" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle12 };
}


