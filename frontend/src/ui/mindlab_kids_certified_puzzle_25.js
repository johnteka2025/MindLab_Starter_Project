function renderCertifiedKidsPuzzle25(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 25 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>If you want to draw and erase mistakes, what should you use?</p>' +
        '<button data-choice="pencil">Pencil</button>' +
        '<button data-choice="pen">Pen</button>' +
        '<button data-choice="brush">Brush</button>' +
        '<div id="p25-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p25-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "pencil" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle25 };
}


