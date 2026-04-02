function renderCertifiedKidsPuzzle19(containerId) {

    const host = document.getElementById(containerId);
    if (!host) throw new Error("Puzzle 19 host not found");

    host.innerHTML = '<div class="mindlab-kids-puzzle">' +
        '<p>Which one is used for both writing and drawing?</p>' +
        '<button data-choice="pencil">Pencil</button>' +
        '<button data-choice="plate">Plate</button>' +
        '<button data-choice="shoe">Shoe</button>' +
        '<div id="p19-feedback"></div>' +
    '</div>';

    const feedback = host.querySelector("#p19-feedback");

    host.querySelectorAll("button").forEach(btn => {
        btn.addEventListener("click", () => {
            feedback.textContent = btn.dataset.choice === "pencil" ? "Correct!" : "Try again.";
        });
    });
}

if (typeof module !== "undefined") {
    module.exports = { renderCertifiedKidsPuzzle19 };
}


