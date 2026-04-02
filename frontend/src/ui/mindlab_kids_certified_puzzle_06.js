function renderCertifiedKidsPuzzle06(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 06 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>Which one is used to write?</p>' +
        '<button data-choice="pen">Pen</button>' +
        '<button data-choice="apple">Apple</button>' +
        '<button data-choice="shoe">Shoe</button>' +
        '<div id="p06-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p06-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "pen" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle06 };
}


